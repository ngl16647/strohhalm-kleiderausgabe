
//Tab-Widget
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomTabData {
  final String title;
  final Widget child;

  CustomTabData({required this.title, required this.child});
}

///Creates a dynamically extendable Tab-Widget
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

  ///Creates a single "Tab" on the top
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
        ///Tab-Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < widget.tabs.length; i++) ...[
              Expanded(child: _buildTabHeader(context, i, widget.tabs[i].title)),
            ],
          ],
        ),
        ///Tab-Body
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