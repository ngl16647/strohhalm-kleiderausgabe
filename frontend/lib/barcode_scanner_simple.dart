import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:strohhalm_app/main.dart';

import 'generated/l10n.dart';

///QR-Code Scanner Seite
class BarcodeScannerSimple extends StatefulWidget {

  const BarcodeScannerSimple({
    super.key,
  });

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;
  bool codeFound = false;

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return Text(
       S.of(context).barCode_scanner_error,
        overflow: TextOverflow.fade,
      );
    }

    return Text(
      S.of(context).barCode_scanner_success,
      overflow: TextOverflow.fade,
    );
  }


  Future<void> _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted && !codeFound) {
        codeFound = true; //Hier, damit der Barcode nicht mehrmals gescannt wird was im Zusammenhang mit dem 1 Sekunden delay zu crashes führt
        _barcode = barcodes.barcodes.firstOrNull;
        setState(() {
          _barcode;
        });
        await Future.delayed(const Duration(seconds: 1)); //Warte 1 Sekunde damit der Nutzer Feedback bekommt, dass es geklappt hat
        returnToPage();
    }
  }

  void returnToPage(){
    if (mounted) Navigator.of(context).pop(_barcode!.displayValue!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double qrSize = MediaQuery.of(context).size.width*0.8;
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
              mainAxisSize: MainAxisSize.min, // nur Höhe die benötigt wird
              children: [
                Stack(
                  children: [
                    ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      width: qrSize,
                      height: qrSize,
                      child: MobileScanner(
                        onDetect: _handleBarcode,
                      ),
                    ),
                  ),
                    Center(
                      child: SizedBox(
                        width: qrSize,
                        height: qrSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Symbols.crop_free,
                            weight: 100,
                            color: Colors.black87.withAlpha(150),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if(codeFound) SizedBox(
                  height: 80,
                  child: Center(
                    child: _buildBarcode(_barcode),
                  ),
                ),
                SizedBox(height: 10,),
                TextButton(
                  onPressed: (){
                    navigatorKey.currentState?.pop();
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 30),
                    backgroundColor: Color.fromRGBO(169, 171, 25, 0.4)
                  ),
                  child: Text(S.of(context).back),
                )
              ],
            )
      ),
    );
  }
}