import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/utilities.dart';
import 'app_settings.dart';
import 'generated/l10n.dart';

class BannerImage{
  File? leftImage;
  File? rightImage;
  String? title;

  BannerImage( {
    this.leftImage,
    this.rightImage,
    this.title,
  });

  String? get headerTitle => title;

  bool get isEmpty =>
      leftImage == null &&
      rightImage == null &&
      (title?.isEmpty ?? true);

  String toJsonString(){
    Map<String, String> bannerMap = {
      "imageLeft": leftImage == null ? "" : leftImage!.uri.pathSegments.last,
      "title": title ?? "",
      "imageRight": rightImage == null ? "" : rightImage!.uri.pathSegments.last
    };
    return jsonEncode(bannerMap);
  }

  static Future<BannerImage> fromJsonString(String jsonString) async {
    Map<String, dynamic> bannerMap = jsonDecode(jsonString);
    final appDir = await getApplicationDocumentsDirectory();
    final bannerDir = join(appDir.path, "bannerImages");

    Future<File?> joinAndCheckFile(String? fileName) async {
      if (fileName == null || fileName.isEmpty) return null;
      final path = join(bannerDir, fileName);
      return await File(path).exists() ? File(path) : null;
    }

    return BannerImage(
      leftImage: await joinAndCheckFile(bannerMap["imageLeft"]),
      rightImage: await joinAndCheckFile(bannerMap["imageRight"]),
      title: bannerMap["title"] == "" ? null : bannerMap["title"],
    );
  }
}

class BannerDesigner extends StatefulWidget{
  final bool useDesigner;
  final BannerImage? bannerDesignerImage;
  final File? wholeBannerImage;

  const BannerDesigner({
    super.key,
    required this.useDesigner,
    this.bannerDesignerImage,
    this.wholeBannerImage
  });

  @override
  State<BannerDesigner> createState() => BannerDesignerState();
}

class BannerDesignerState extends State<BannerDesigner>{
  final TextEditingController _bannerTitleController = TextEditingController();
  File? _bannerWholeImage;
  BannerImage? bannerDesignerImage;
  final Color _selectedColor = Color.fromRGBO(169, 171, 25, 1.0);
  bool _useBannerDesigner = true;
  bool _isMobile = false;

  @override
  void initState() {
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    _useBannerDesigner = widget.useDesigner;
    _bannerWholeImage = widget.wholeBannerImage;
    bannerDesignerImage = widget.bannerDesignerImage ?? BannerImage();
    _bannerTitleController.text = widget.bannerDesignerImage?.title ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _bannerTitleController.dispose();
    super.dispose();
  }

  void saveBanner(){
    var manager = AppSettingsManager.instance;
    manager.setBannerType(_useBannerDesigner);
    manager.setBannerImage(_bannerWholeImage);
    manager.setDynamicBanner(bannerDesignerImage);
  }

  Future<void> _pickImage(BuildContext context, bool? left) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);

      if(left == null){
        final image = await decodeImageFromList(await pickedFile.readAsBytes());
        final aspectRatio = image.width / image.height;
        if (aspectRatio < 6) {
          if(!context.mounted) return;
          Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).banner_designer_wrongAspectRatio, isError: true);
          return;
        }
      }

      final appDir = await getApplicationDocumentsDirectory();
      final bannerDir = Directory(join(appDir.path,"bannerImages"));
      if (!(await bannerDir.exists())) {
        await bannerDir.create(recursive: true);
      }

      final fileName = pickedFile.uri.pathSegments.last;
      final savedImage = await pickedFile.copy(join(bannerDir.path,fileName));

      setState(() {
        if(left == null){
          _bannerWholeImage = savedImage;
        } else {
          if(left){
            bannerDesignerImage?.leftImage = savedImage;
          } else {
            bannerDesignerImage?.rightImage = savedImage;
          }
        }
      });
    }
  }

  Future<List<File>> filterFilesByAspectRatio(List<File> files, int? bannerAspectRatio) async {
    final result = <File>[];
    for (final file in files) {
      final image = await decodeImageFromList(await file.readAsBytes());
      final aspectRatio = image.width / image.height;

      if(bannerAspectRatio != null){
        if (aspectRatio > bannerAspectRatio) {
          result.add(file);
        }
      } else {
        result.add(file);
      }
    }
    return result;
  }

  Future<File?> showExistingImagePicker(BuildContext context, int? aspectRatio) async {
    final appDir = await getApplicationDocumentsDirectory();
    final bannerDir = Directory(join(appDir.path,"bannerImages"));
    if(!await bannerDir.exists()) return null;

    var files = bannerDir.listSync().whereType<File>().toList();
    files = await filterFilesByAspectRatio(files, aspectRatio);

    if(!context.mounted) return null;
    final result = await showDialog<File?>(
        context: context,
        builder: (context){
          return Dialog(
            constraints: BoxConstraints(
                maxWidth: _isMobile ? double.infinity : MediaQuery.of(context).size.width*0.6
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Align(
                    alignment: AlignmentGeometry.centerRight,
                    child: IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: Icon(Icons.close)),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constrains){
                      bool oneRow = constrains.maxWidth < 450;
                      return GridView.count(
                        crossAxisCount:_isMobile || oneRow ? 1 : 2,
                        childAspectRatio: 2,
                        children: [
                          for(int i= 0; i < files.length; i++)...{
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(6),
                                color: Theme.of(context).listTileTheme.tileColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(),
                                    Expanded(child:  Padding(
                                        padding: EdgeInsets.all(5),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(maxHeight: 150),
                                            child:  Image.file(files.elementAt(i), fit: BoxFit.contain,),
                                          ),
                                        )
                                    ),),
                                    aspectRatio == null || _bannerWholeImage == null || files[i].path != _bannerWholeImage!.path ? Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: TextButton.icon(
                                              onPressed: (){
                                                Navigator.of(context).pop(files.elementAt(i));
                                              },
                                              label: Text(S.of(context).banner_designer_pick),
                                              icon: Icon(Icons.hdr_auto_select),
                                              style: TextButton.styleFrom(
                                                  minimumSize: Size(double.infinity, 32)
                                              ),
                                            )),
                                        IconButton(
                                          onPressed: (){
                                            files[i].delete();
                                            setState(() {
                                              files.removeAt(i);
                                            });
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
                                    ) : Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Text(S.of(context).banner_designer_picked),
                                    )
                                  ],
                                ),
                              ),
                            )
                          }
                        ],
                      );
                    },
                  )
                ),
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  style: TextButton.styleFrom(
                      minimumSize: Size(double.infinity, 42)
                  ),
                  child: Text(S.of(context).back),
                )
              ],
            ),
          );
        });
    if(result != null){
      return result;
    }
    return null;
  }

  Widget buildDynamicBannerButtons({
    required BuildContext context,
    required File? dynBannerImage,
    required VoidCallback onAddOrDelete,
    required VoidCallback onPick,
  }){
    double maxWidth = _isMobile ? MediaQuery.of(context).size.width*0.2 : MediaQuery.of(context).size.width*0.3;
    return ConstrainedBox(
        constraints: BoxConstraints(
        maxWidth: maxWidth
    ),
    child:  Stack(
      alignment: AlignmentGeometry.center,
      children: [
        if(dynBannerImage != null) SizedBox(
          child: Image.file(
            dynBannerImage,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        _isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: (){
                      onAddOrDelete();
                    },
                    icon: Icon(dynBannerImage != null ? Icons.delete : Icons.add_a_photo, size: 22,),
                    style: TextButton.styleFrom(
                        minimumSize: Size(20, 25),
                        backgroundColor: Colors.transparent,
                        alignment: AlignmentGeometry.center
                    ),
                  ),
                  if(dynBannerImage == null)IconButton(
                    onPressed: () async {
                      onPick();
                    },
                    icon: Icon(Icons.photo_album, size: 22,),
                    style: TextButton.styleFrom(
                        minimumSize: Size(20, 25),
                        backgroundColor: Colors.transparent
                    ),
                  )
                ],
              )
            :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: (){
                onAddOrDelete();
              },
              icon: Icon(dynBannerImage != null ? Icons.delete : Icons.add_a_photo, size: 22,),
              label :  Text(dynBannerImage != null ? S.of(context).delete : S.of(context).banner_designer_new),
              style: TextButton.styleFrom(
                  minimumSize: Size(20, 25),
                  backgroundColor: Colors.transparent,
                  alignment: AlignmentGeometry.center
              ),
            ),
            if(dynBannerImage == null)TextButton.icon(
              onPressed: () async {
                onPick();
              },
              label: Text(S.of(context).banner_designer_existing),
              icon: Icon(Icons.photo_album, size: 22,),
              style: TextButton.styleFrom(
                  minimumSize: Size(20, 25),
                  backgroundColor: Colors.transparent
              ),
            )
          ],
        )
      ]
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomTabs(
      selectedIndex: _useBannerDesigner ? 1 : 0,
      showSelected: true,
      switchTab: (index){
        _useBannerDesigner = index == 1;
      },
      tabs: [
        CustomTabData(
          title: S.of(context).banner_designer_bannerImageSubTitle,
          child: Column(
            spacing: 10,
            children: [
              Text(S.of(context).banner_designer_bannerImageTitle),
              _bannerWholeImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_bannerWholeImage!, fit: BoxFit.fitHeight),
              )
                  :  Text(S.of(context).banner_designer_noImage),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 0,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(context, null),
                        label:  Text(S.of(context).banner_designer_uploadImage),
                        icon: Icon(Icons.add_photo_alternate),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: ()async{
                          var result = await showExistingImagePicker(context, 6);
                          if(result != null){
                            setState(() {
                              _bannerWholeImage = result;
                            });
                          }
                        },
                        label: Text(S.of(context).banner_designer_existing),
                        icon: Icon(Icons.photo_album),
                      ),
                    ),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete,),
                          onPressed: (){
                            setState(() {
                              _bannerWholeImage = null;
                            });
                          },
                        ))
                  ]
              ),
            ],
          ),
        ),
        CustomTabData(
          title: S.of(context).banner_designer_bannerDesignerSubTitle,
          child: Column(
            spacing: 10,
            children: [
              Text(S.of(context).banner_designer_bannerDesignerTitle),
              Material(
                color: Theme.of(context).listTileTheme.tileColor,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 0.2, color: Colors.black87),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 120),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          spacing: 2,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildDynamicBannerButtons(
                                  context: context,
                                  dynBannerImage: bannerDesignerImage?.leftImage,
                                  onAddOrDelete: (){
                                    if(bannerDesignerImage?.leftImage != null){
                                      bannerDesignerImage?.leftImage = null;
                                    } else {
                                      _pickImage(context, true);
                                    }
                                    setState(() {});
                                  },
                                  onPick: () async {
                                    var result = await showExistingImagePicker(context, null);
                                    if(result != null){
                                      setState(() {
                                        bannerDesignerImage?.leftImage = result;
                                      });
                                    }
                                  },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _bannerTitleController,
                                decoration: InputDecoration(
                                  labelText: S.of(context).banner_designer_titleText,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (text){
                                  bannerDesignerImage?.title = text;
                                },
                              ),
                            ),
                            buildDynamicBannerButtons(
                                context: context,
                                dynBannerImage: bannerDesignerImage?.rightImage,
                                onAddOrDelete: (){
                                  if(bannerDesignerImage?.rightImage != null){
                                    bannerDesignerImage?.rightImage = null;
                                  } else {
                                    _pickImage(context, false);
                                  }
                                  setState(() {});
                                },
                                onPick: () async {
                                  var result = await showExistingImagePicker(context, null);
                                  if(result != null){
                                    setState(() {
                                      bannerDesignerImage?.rightImage = result;
                                    });
                                  }
                                }),
                          ],
                        ),
                        SizedBox(height: 3,),
                        Container(
                          height: 3,
                          width: double.infinity,
                          color: _selectedColor,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//Tab-Widget
class CustomTabData {
  final String title;
  final Widget child;

  CustomTabData({required this.title, required this.child});
}

class CustomTabs extends StatefulWidget {
  final int selectedIndex;
  final List<CustomTabData> tabs;
  final Function(int) switchTab;
  final bool showSelected;

  const CustomTabs({
    super.key,
    required this.selectedIndex,
    required this.tabs,
    required this.switchTab,
    required this.showSelected,
  });

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  int selectedIndex = 0;

  @override
  void initState() {
    selectedIndex = widget.selectedIndex;
    super.initState();
  }

  Widget _buildTabHeader(BuildContext context, int index, String title) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState((){ selectedIndex = index;});
        widget.switchTab(index);
      },
      child: Row(
        children: [
          Expanded(
              child: Material(
                elevation: 10,
                color: Theme.of(context).listTileTheme.tileColor!.withAlpha(isSelected ? 255 : 150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12)
                  ),
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: isSelected ? 35 : 30,
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(isSelected && widget.tabs.length > 1 && widget.showSelected) Icon(Icons.check),
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Tab-Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < widget.tabs.length; i++) ...[
              Expanded(child: _buildTabHeader(context, i, widget.tabs[i].title)),
            ],
          ],
        ),
        //Tab-Body
        Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 160
              ),
              child:Material(
                elevation: 10,
                color: Theme.of(context).listTileTheme.tileColor ?? Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(12)
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: widget.tabs.isNotEmpty ? widget.tabs[selectedIndex].child
                      .animate(key: ValueKey(selectedIndex))
                      .fade(duration: 300.ms)
                      .slide(begin: Offset(0, 0.2)) : SizedBox.expand(),
                ),
              ),
            )
        )
      ],
    );
  }
}