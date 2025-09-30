import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/utilities.dart';
import 'generated/l10n.dart';
import 'http_helper.dart';

///The connection states
enum ConnectionStatus {
  connected,
  noInternet,
  noServer,
}

///Provider that contains and checks the ConnectionStatus
class ConnectionProvider extends ChangeNotifier {
  ConnectionStatus _connectionStatus = ConnectionStatus.connected;
  ConnectionStatus get status => _connectionStatus;

  Timer? timerSub;


  ///Sets the Status manually
  void setStatus(ConnectionStatus newStatus) {
      _connectionStatus = newStatus;
      notifyListeners();

      if (_connectionStatus == ConnectionStatus.connected) {
        cancelCheck();
      }

  }

  ///Checks server/Network connection
  Future<ConnectionStatus> checkConnection() async {
    debugPrint("Checking Connection");
    ConnectionStatus newStatus;
    try {
      final online = await HttpHelper().hasInternet();
      if (!online) {
        newStatus = ConnectionStatus.noInternet;
      } else {
        final serverOnline = await HttpHelper().isServerOnline();
        if(serverOnline){
          newStatus = ConnectionStatus.connected;
        } else {
          newStatus = ConnectionStatus.noServer;
        }
      }

      if(!(AppSettingsManager.instance.settings.useServer ?? true)) return ConnectionStatus.connected;
      if(_connectionStatus != newStatus){
        _connectionStatus = newStatus;
        notifyListeners();
      }
      return _connectionStatus;
    } catch (e) {
      return ConnectionStatus.noInternet;
    }
  }

  ///Cancels check
  void cancelCheck(){
    timerSub?.cancel();
    timerSub = null;
    _connectionStatus = ConnectionStatus.connected;
  }

  ///Checks the connection in intervals of 5Seconds and cancels if connected
  Future<void> periodicCheckConnection() async {
    if (timerSub != null && timerSub!.isActive) return;
    timerSub?.cancel();
    checkConnection();
    timerSub = Timer.periodic(Duration(seconds: 5), (ev) async {
      final newStatus = await checkConnection();

      if (newStatus == ConnectionStatus.connected) {
        cancelCheck();
      }
    });
  }
}

///Shows a toast if connection-Status changes
class ConnectionToastListener extends StatefulWidget {
  final Widget child;
  const ConnectionToastListener({super.key, required this.child});

  @override
  State<ConnectionToastListener> createState() => _ConnectionToastListenerState();
}

class _ConnectionToastListenerState extends State<ConnectionToastListener> {
  ConnectionStatus? _lastStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<ConnectionProvider>();
    provider.addListener(() {
      final status = provider.status;

      if (status != _lastStatus) {
        _lastStatus = status;

        AppSettingsManager.instance.load().then((_) {
          if (!mounted || !AppSettingsManager.instance.settings.useServer!) return;
          switch (status) {
            case ConnectionStatus.noInternet:
              Utilities.showToast(
                context: context,
                title: S.of(context).fail,
                description: S.of(context).no_internet,
                isError: true,
              );
              break;
            case ConnectionStatus.noServer:
              Utilities.showToast(
                context: context,
                title:  S.of(context).fail,
                description: S.of(context).no_server,
                isError: true,
              );
              break;
            case ConnectionStatus.connected:
              Utilities.showToast(
                context: context,
                title: S.of(context).success,
                description: S.of(context).reconnected,
              );
              break;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; //let child through
  }
}