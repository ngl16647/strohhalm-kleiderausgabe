import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:strohhalm_app/user.dart';
import 'package:pdf/widgets.dart' as wg;
import 'package:pdf/pdf.dart';
import 'package:image/image.dart' as img;

import 'generated/l10n.dart';

///Klasse für alle möglichen nützlichen funktionen, die Appübergreifend genutzt werden können aber keine eigene Klasse rechtfertigen

class CreateQRCode{

  CreateQRCode();

  /// Funktion, die den QR-Code in einem Dialog anzeigt
  void showQrCode(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.7),
          insetPadding: EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final qrSize = (constraints.biggest.shortestSide * 0.7);
              return Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  spacing: 20,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        Expanded(
                          child: Text(
                            "${user.firstName} ${user.lastName}",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    Center(
                      child: Container(
                        width: qrSize,
                        height: qrSize,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 1),
                          color: Colors.white,
                        ),
                        child: QrImageView(
                          backgroundColor: Colors.white,
                          version: QrVersions.auto,
                          data: user.uuId,
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: (){
                          printQrCode(context, user);
                        },
                        label: Text(S.of(context).print_code),
                        icon: Icon(Icons.print),),
                    )
                  ],
                ),
              );
            },
          )
        );
      }
    );
  }

  Future<void> printQrCode(BuildContext context, User user) async {
    final doc = wg.Document();
    final imageData = await rootBundle.load("assets/images/strohalm_header_image.png");

    img.Image image = img.decodeImage(imageData.buffer.asUint8List())!;
    img.grayscale(image);
    Uint8List bwBytes = Uint8List.fromList(img.encodePng(image));

    final pdfImage = wg.MemoryImage(bwBytes);

    doc.addPage(
      wg.Page(
        pageFormat: PdfPageFormat(85 * PdfPageFormat.mm, 54 * PdfPageFormat.mm), //Hier kann man die dimension theoretisch für den Drucker anpassen
        build: (context) {
          return wg.Column(
            mainAxisAlignment: wg.MainAxisAlignment.spaceBetween,
            children: [
              wg.Image(pdfImage),
              wg.Row(
                crossAxisAlignment: wg.CrossAxisAlignment.center,
                mainAxisAlignment: wg.MainAxisAlignment.center,
                children: [
                  wg.SizedBox(width: 10),
                  wg.BarcodeWidget(
                    barcode: wg.Barcode.qrCode(),
                    data: user.uuId,
                    width: 90,
                    height: 90,
                  ),
                  wg.SizedBox(width: 10),
                  wg.Expanded(
                    child: wg.Column(
                      crossAxisAlignment: wg.CrossAxisAlignment.start,
                      mainAxisAlignment: wg.MainAxisAlignment.center,
                      children: [
                        wg.Text(
                          "${user.firstName} ${user.lastName}",
                          style: wg.TextStyle(
                            fontSize: 20,
                            fontWeight: wg.FontWeight.bold,
                          ),
                        ),
                        wg.SizedBox(height: 5),
                        wg.Text(
                          DateFormat("dd.MM.yyyy").format(DateTime.now()), //Birthday OR CreatedOn OR CreationOfCard?
                          style: wg.TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              wg.SizedBox(),
            ]
          );
        },
      ),
    );

    if(context.mounted) {
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
            width: MediaQuery.of(context).size.width*0.6,
            height: MediaQuery.of(context).size.width*0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: PdfPreview(
                  build: (format) async => doc.save(),
                  allowPrinting: false,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child:  ElevatedButton.icon(
                        icon: Icon(Icons.print),
                        label: Text(S.of(context).print),
                        onPressed: () async {
                          await Printing.layoutPdf(
                              onLayout: (format) async => doc.save(),
                              usePrinterSettings: true
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.share),
                        label: Text(S.of(context).share),
                        onPressed: () async {
                          await Printing.sharePdf(
                            bytes: await doc.save(),
                            //TODO: Responsive filename
                            filename: "label.pdf",
                          );
                        },
                      ),)
                  ],
                ),
              ],
            )
        ),
      ),
    );
    }
  }
}