import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:strohhalm_app/main.dart';

import 'generated/l10n.dart';

///QR-Code Scanner Seite
class BarcodeScannerSmartPhoneCamera extends StatefulWidget {

  const BarcodeScannerSmartPhoneCamera({
    super.key,
  });

  static Future<String?> showBarcodeScannerDialog(BuildContext context)async{
    return await showDialog(
        context: context,
        builder: (context){
          return BarcodeScannerSmartPhoneCamera();
        });
  }

  @override
  State<BarcodeScannerSmartPhoneCamera> createState() => _BarcodeScannerSmartPhoneCameraState();
}

class _BarcodeScannerSmartPhoneCameraState extends State<BarcodeScannerSmartPhoneCamera> {
  Barcode? _barcode;
  bool _codeFound = false;

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
    if (mounted && !_codeFound) {
        _codeFound = true; //Here so code isn't scanned multiple times and throws a error
        _barcode = barcodes.barcodes.firstOrNull;
        setState(() {
          _barcode;
        });
        await Future.delayed(const Duration(seconds: 1)); //Wait a second to show feedback
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
                if(_codeFound) SizedBox(
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