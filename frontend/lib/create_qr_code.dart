import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/banner_designer.dart';
import 'package:strohhalm_app/user.dart';
import 'package:pdf/widgets.dart' as wg;
import 'package:pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:strohhalm_app/utilities.dart';
import 'generated/l10n.dart';

class CreateQRCode{

  CreateQRCode();

  Future<wg.MemoryImage> fileToGrayScaleImage(File file) async {
    final imageData = await file.readAsBytes();

    img.Image image = img.decodeImage(imageData.buffer.asUint8List())!;
    img.grayscale(image);
    Uint8List bwBytes = Uint8List.fromList(img.encodePng(image));
    return wg.MemoryImage(bwBytes);
  }

  Future<Uint8List> buildPdf(User user, PdfPageFormat format) async {
    final doc = wg.Document();
    var settings = AppSettingsManager.instance.settings;

    final maxWidth = format.availableWidth * 0.4;
    final maxHeight = format.availableHeight * 0.6;
    final qrSize = maxWidth < maxHeight ? maxWidth : maxHeight;

    bool? useBannerDesign = settings.useBannerDesigner;
    File? file = settings.bannerSingleImage;
    BannerImage? bannerImage = settings.bannerDesignerImageContainer;
    wg.MemoryImage? pdfImage;
    wg.Column? dynamicBannerHeader;


    if(useBannerDesign != null){
      if(!useBannerDesign){
        if(file != null){
          pdfImage = await fileToGrayScaleImage(file);
        }
      } else if(bannerImage != null){
        wg.MemoryImage? pdfImageLeft;
        wg.MemoryImage? pdfImageRight;

        if(bannerImage.leftImage != null) pdfImageLeft = await fileToGrayScaleImage(bannerImage.leftImage!);
        if(bannerImage.rightImage != null) pdfImageRight = await fileToGrayScaleImage(bannerImage.rightImage!);

        dynamicBannerHeader = wg.Column(
          children: [
            wg.Expanded(
              child: wg.Row(
                  crossAxisAlignment: wg.CrossAxisAlignment.center,
                  children: [
                    if(pdfImageLeft != null)wg.Image(pdfImageLeft),
                    wg.Text("  ${bannerImage.title}", style: wg.TextStyle(fontSize: qrSize*0.1)),
                    wg.Spacer(),
                    if(pdfImageRight != null)wg.Image(pdfImageRight),
                  ]
              ),
            ),
            wg.Container(
              height: 0.2,
              color: PdfColors.black
            )
          ]
        );
      }
    }



    doc.addPage(
      wg.Page(
        pageFormat: format, //Hier kann man die dimension theoretisch für den Drucker anpassen
        build: (context) {
          return wg.Column(
            mainAxisAlignment: wg.MainAxisAlignment.spaceBetween,
            children: [
              if(pdfImage != null)wg.Image(pdfImage),
              if(dynamicBannerHeader != null) wg.Container(
                height: format.availableHeight*0.17,
                child: dynamicBannerHeader
              ),
              if(pdfImage == null && dynamicBannerHeader == null) wg.SizedBox.shrink(),
              wg.Row(
                mainAxisAlignment: wg.MainAxisAlignment.start,
                crossAxisAlignment: wg.CrossAxisAlignment.start,
                children: [
                  wg.SizedBox(width: 10),
                  wg.BarcodeWidget(
                    barcode: wg.Barcode.qrCode(),
                    data: user.uuId,
                    width: qrSize,
                    height: qrSize
                  ),
                  wg.SizedBox(width: 10),
                  wg.Expanded(
                    child: wg.Column(
                      crossAxisAlignment: wg.CrossAxisAlignment.start,
                      mainAxisAlignment: wg.MainAxisAlignment.start,
                      children: [
                        wg.Text(
                          "${user.firstName} ${user.lastName}",
                          style: wg.TextStyle(
                            fontSize: qrSize * 0.2,
                            fontWeight: wg.FontWeight.bold,
                          ),
                        ),
                        wg.SizedBox(height: 5),
                        wg.Text(
                          DateFormat("dd.MM.yyyy").format(DateTime.now()),
                          style: wg.TextStyle(
                            fontSize: qrSize * 0.17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  wg.SizedBox(width: 10)
                ],
              ),
              wg.SizedBox.shrink()
            ],
          );
        },
      ),
    );
    return doc.save();
  }

  Future<void> printQrCode(BuildContext context, User user) async {
    TextEditingController heightController = TextEditingController(text: "54");
    TextEditingController widthController = TextEditingController(text: "85");
    PdfPageFormat pdfPageFormat = PdfPageFormat(85 * PdfPageFormat.mm, 54 * PdfPageFormat.mm);
    //Map<String, PdfPageFormat> formatMap = {};

    if(context.mounted) {
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: StatefulBuilder(builder: (context, setState){
          return SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: MediaQuery.of(context).size.width*0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 7,
                    child: PdfPreview(
                      build: (format) async => buildPdf(user, pdfPageFormat),
                      allowPrinting: false,
                      allowSharing: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      //pageFormats: formatMap,
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: TextField(
                                          controller: widthController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "Breite",
                                            suffixText: "mm",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                          ],
                                        )),
                                    Text(" x ", style: TextStyle(fontSize: 22),),
                                    Expanded(child: TextField(
                                      controller: heightController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Höhe",
                                        suffixText: "mm",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                      ],
                                    )),
                                    IconButton(
                                      onPressed: () {
                                        final w = double.tryParse(widthController.text);
                                        final h = double.tryParse(heightController.text);
                                        if (w != null && h != null) {
                                          setState(() {
                                            pdfPageFormat = PdfPageFormat(w * PdfPageFormat.mm, h * PdfPageFormat.mm);
                                            //formatMap["$w x $h"] = PdfPageFormat(w * PdfPageFormat.mm, h * PdfPageFormat.mm);
                                          });
                                        } else {
                                          Utilities.showToast(context: context, title:  S.of(context).fail, description: S.of(context).number_fail);
                                        }
                                      },
                                      icon:  Icon(Icons.refresh),
                                    ),
                                  ],
                                ),
                            ),
                            Expanded(
                              flex: 2,
                              child:  ElevatedButton.icon(
                                icon: Icon(Icons.print),
                                label: Text(S.of(context).print),
                                onPressed: () async {
                                  await Printing.layoutPdf(
                                      onLayout: (format) async => buildPdf(user, pdfPageFormat),
                                      usePrinterSettings: true
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.share),
                                label: Text(S.of(context).qr_code_share, textAlign: TextAlign.center,),
                                onPressed: () async {
                                  await Printing.sharePdf(
                                    bytes: await buildPdf(user, pdfPageFormat),
                                    filename: "${user.id}_${user.uuId}.pdf",
                                  );
                                },
                              ),)
                          ],
                        ),
                      )
                  ),
                ],
              )
          );
        }),
      ),
    );
    }
  }
}