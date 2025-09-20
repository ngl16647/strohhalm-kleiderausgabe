import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:uuid/uuid.dart';


class BarcodeScannerListener {
  //For Serial
  final Map<String, String> _portStringBuffers = {};
  final Map<String, SerialPortReader> _readers = {};
  final Map<String, Timer> _bufferTimers = {};
  String? _activePort;
  List<String> _lastPorts = [];
  Timer? _newDeviceWatcher;
  bool _checkRunning = false;

  //For HDI
  String _keyEventBuffer = ""; //Since the Scanner "writes" as a keyboard
  Timer? _timer;

  final void Function(String)? onSuccessScan;
  final VoidCallback? onFailedUuIdCheck;
  final BuildContext? context;

  BarcodeScannerListener({this.context, this.onSuccessScan, this.onFailedUuIdCheck});

  void listenForScan() async {
    var ports = SerialPort.availablePorts;
    _lastPorts = ports;
    checkForNewDevice();
    HardwareKeyboard.instance.addHandler(onHDIScan);
  }

  //TODO: research if it works on MAC/Linux?
  void _detectScannerPort() {
    debugPrint("Checking for Scanner-Input");
    final ports = SerialPort.availablePorts;
    if (ports.isEmpty) return;
    for (var portName in ports) {
      final port = SerialPort(portName);
      var config = SerialPortConfig();
      config.baudRate = 9600;
      config.bits = 8;
      config.stopBits = 1;
      config.parity = 0;
      config.xonXoff = 0;
      config.rts = 1;
      config.cts = 0;
      config.dsr = 0;
      config.dtr = 1;
      port.config = config;
      config.dispose();


      if (!port.openReadWrite()) continue;

      _portStringBuffers[portName] = "";
      final reader = SerialPortReader(port);
      _readers[portName] = reader;
      reader.stream.listen((data) {
          final str = utf8.decode(data);
          _portStringBuffers[portName] = (_portStringBuffers[portName]! + str).trim();

          _bufferTimers[portName]?.cancel();
          //Timer fires after reader hasn't received data for 50ms
          _bufferTimers[portName] = Timer(const Duration(milliseconds: 50), () {
          final finishedString = _portStringBuffers[portName]!.trim();
          _portStringBuffers[portName] = "";

          //Check if string is a uuId => if true close other ports and give the string to main_page
          try {
            if (Uuid.isValidUUID(fromString: finishedString)) {
              debugPrint("UUID $finishedString gefunden auf Port $portName");
              _checkRunning = false;
              _activePort = portName;
              //Close all other ports except right one
              _readers.forEach((otherName, reader) {
                if (otherName != portName) {
                  reader.port.close();
                  reader.close();
                }
              });
              onSuccessScan!(finishedString);
              if(_newDeviceWatcher != null) _newDeviceWatcher!.cancel();
            }
          } catch (_) {
            debugPrint("Ungültiger Scan auf Port $portName: $finishedString");
          }});
      },
        onError: (ev){
          debugPrint("Stream error: $ev | $portName $_activePort");
           if (_activePort == portName && !_checkRunning) {
             _activePort = null;
             checkForNewDevice(); //TODO: Check without if port stays open even if disconnected
           }
        },
        onDone: (){
          debugPrint("Stream geschlossen $portName $_activePort");
          if (_activePort == portName && !_checkRunning) {
            _activePort = null;
            checkForNewDevice();
          }
        }
      );
    }
  }

  bool onHDIScan(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      if (key == "Enter") {

        final finishedString = _keyEventBuffer.trim();
        _keyEventBuffer = "";
        if (Uuid.isValidUUID(fromString: finishedString)) {
          onSuccessScan!(finishedString.toLowerCase());
        } else {
          debugPrint("No valid UUID: $finishedString");
        }

      } else {
        _keyEventBuffer += key;

        _timer?.cancel();
        _timer = Timer(Duration(milliseconds: 50), () {
          //debugPrint("Buffer reseting!");
          _keyEventBuffer = "";
        });
      }

    }
    return false;
  }

  ///Starts check for devices new and if it detects a difference in ports it disposes and restarts the detection-process
  void checkForNewDevice(){
    debugPrint("started check for devices");
    dispose();
    _detectScannerPort();
    _checkRunning = true;
    _newDeviceWatcher?.cancel();
    _newDeviceWatcher = Timer.periodic(const Duration(seconds: 2), (ev) {
      var ports = SerialPort.availablePorts;
      if(!listEquals(ports, _lastPorts)){
        debugPrint("Ports changed");
        _lastPorts = List.from(ports);
        dispose();
        _detectScannerPort();
      }
    });
  }

  bool listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void dispose(){
    _readers.forEach((_, reader) {
      try {
        reader.port.close();
        reader.close();
        debugPrint("readers should be closed");
      } catch (ev) {
        debugPrint("$ev");
      }
    });
    _readers.clear();

    _bufferTimers.forEach((_, timer) => timer.cancel());
    _bufferTimers.clear();

    _portStringBuffers.clear();
  }
}

/*
//Listen for specific port
  void listenToPort(String portName) {
      dispose();

      final port = SerialPort(portName);
      var config = SerialPortConfig();
      config.baudRate = 9600;
      config.bits = 8;
      config.stopBits = 1;
      config.parity = 0;
      config.xonXoff = 0;
      config.rts = 1;
      config.cts = 0;
      config.dsr = 0;
      config.dtr = 1;
      port.config = config;
      config.dispose();

      if(!port.openRead()) return;

      final reader = SerialPortReader(port);
      _readers[portName] = reader;
      reader.stream.listen((data) {
        final str = utf8.decode(data);
        _portStringBuffers[portName] = (_portStringBuffers[portName]! + str).trim();

        _bufferTimers[portName]?.cancel();
        //Timer fires after reader hasn't received data for 50ms
        _bufferTimers[portName] = Timer(const Duration(milliseconds: 50), () {
          final finishedString = _portStringBuffers[portName]!.trim();
          _portStringBuffers[portName] = "";

          try {
            if (Uuid.isValidUUID(fromString: finishedString)) {
              debugPrint("UUID $finishedString gefunden auf Port $portName");
              //onSuccessScan!(finishedString);
            }
          } catch (_) {
            debugPrint("Ungültiger Scan auf Port $portName: $finishedString");
          }});
      });
  }
 */