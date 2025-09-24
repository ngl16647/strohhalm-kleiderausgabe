import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/banner_designer.dart';
import 'package:strohhalm_app/check_connection.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/utilities.dart';
import 'generated/l10n.dart';
import 'http_helper.dart';
import 'main.dart';

class StatisticPage extends StatefulWidget {

  const StatisticPage({
    super.key,
  });

  static Future<void> showStatisticDialog(BuildContext context)async{
    await showDialog(
      context: context,
      builder: (context) {
        return StatisticPage();
      },
    );
  }

  @override
  StatisticPageState createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {
  late var provider = context.read<ConnectionProvider>();
  bool _isMobile = false;
  int _touchedIndex = -1;
  int _cutOffNumber = 6;
  int _monthBackNumber = 0;
  int _overAllNumberOfCountries = 0;
  bool _showYear = false;
  bool _useServer = false;
  bool loading = false;

  Map<String, dynamic>? _countryData;
  Map<String, int>? _visitsInPeriod = {};

  final List<Color> presetColors = [
    Colors.blue.shade800,
    Colors.green.shade600,
    Colors.brown.shade600,
    Colors.purple.shade600,
    Colors.amber.shade600,
    Colors.indigo.shade600,
    Colors.teal.shade600,
    Colors.blueGrey.shade600,
    Colors.deepOrange.shade600,
    Colors.lightBlue.shade600,
    Colors.lime.shade600,
  ];

  bool showTest = false;

  Color colorFromCountry(String country) {
    final hash = country.hashCode;

    final hue = hash % 360;
    final saturation = 0.5 + (hash % 35) / 100.0;
    final lightness  = 0.5 + ((hash) % 35) / 100.0;

    return HSLColor.fromAHSL(1.0, hue.toDouble(), saturation, lightness).toColor();
  }

  @override
  void initState() {
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    getData();
    if (_useServer) {
      provider.addListener(_onProviderChanged);
    }
    super.initState();
  }

  void _onProviderChanged() {
    if (provider.status == ConnectionStatus.connected) {
      getData();
    }
  }

  @override
  void dispose() {
    if (_useServer) {
      provider.removeListener(_onProviderChanged);
    }
    super.dispose();
  }

  Future<void> getData() async {
    if(!mounted) return;
    setState(() => loading = true);
    await limitCountryNumber();
    await getVisits();
    if(!mounted) return;
    setState(() => loading = false);

  }

  Future<void> getVisits() async {
    _useServer
      ? _visitsInPeriod  = await HttpHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear)
      : _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);

    if(_visitsInPeriod != null) {
      setState(() {
        _visitsInPeriod;
       });
      return;
    }
  }

  Future<void> limitCountryNumber() async {
    Map<String, dynamic> countryDataLong;
    if(_useServer){
      var result = await HttpHelper().getStats();
      if (result == null) {
        _countryData = {};
        return;
      }
      List<dynamic> stats = result["customersByCountry"];
      int totalCounts = result["totalCustomers"];

      countryDataLong = {
        for (var entry in stats)
          entry["country"] as String: [
            (entry["count"] as int) / totalCounts * 100,
            entry["count"] as int
          ]
      };
    } else {
      countryDataLong = await DatabaseHelper().getBirthCountries();
    }
    _overAllNumberOfCountries = countryDataLong.length;

    final sortedEntries = countryDataLong.entries.toList()..sort((a, b) => b.value[0].compareTo(a.value[0]));
    if(!mounted) return;
    if (sortedEntries.length-1 > _cutOffNumber) { //sortedEntries.length-1 so if "Sonstiges" would be comprised of only one country, the actual name would show
      final topList = sortedEntries.take(_cutOffNumber).toList();

      final rest = sortedEntries.skip(_cutOffNumber);
      final restPercent = rest.fold<double>(0, (sum, entry) => sum + entry.value[0]);
      final restSumAbsolut = rest.fold<double>(0, (sum, entry) => sum + entry.value[1]);

      final Map<String, dynamic> limited = {
        for (var entry in topList) Utilities.getLocalizedCountryNameFromCode(context, entry.key) : entry.value,
      };

      var sortedLimitedList = limited.entries.toList()..sort((a, b) => b.value[0].compareTo(a.value[0]));
      //Misc Entry always last
      MapEntry<String, dynamic> miscEntry =  MapEntry(S.of(context).add_user_miscellaneous, [restPercent, restSumAbsolut.toInt()]);
      sortedLimitedList.add(miscEntry);

      Map<String, dynamic> sortedLimited = LinkedHashMap.fromEntries(sortedLimitedList);

      _countryData = sortedLimited;
    } else {
      final Map<String, dynamic> limited = {
        for (var entry in sortedEntries) Utilities.getLocalizedCountryNameFromCode(context, entry.key) : entry.value
      };
      _countryData = limited;
    }
  }


  PieChartSectionData chartData(double value, String title, int index, BoxConstraints constrains){
    double normalRadius = _isMobile ? constrains.maxWidth*0.18 : constrains.maxWidth*0.09; //0.12
    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 20.0 : 14.0;
    final radius = isTouched ? (normalRadius+10) : normalRadius;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    return PieChartSectionData(
      color:  presetColors[index % presetColors.length], //colorFromCountry(title),
      value: value,
      title: "$title\n${value.toStringAsFixed(1)}%",
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        shadows: shadows,
      ),
    );
  }
  
  List<Widget> getPieChartChildren(BoxConstraints constrains){
    if(_countryData == null) return [];
    ScrollController legendScrollController = ScrollController();
    return [
      SizedBox(
        width: _isMobile ? constrains.maxWidth *0.9 : constrains.maxWidth*0.4,
        height: _isMobile ? constrains.maxHeight*0.2 : constrains.maxWidth*0.4, //0.9
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: true,
            ),
            startDegreeOffset: 270,
            centerSpaceRadius: constrains.maxWidth*0.03, //0.05
            sections: List.generate(_countryData!.length, (i) {
              String countryName = _countryData!.keys.elementAt(i);
              double value = _countryData![countryName][0] ?? 0;
              return chartData(value, countryName, i, constrains);
            }),
          ),
        ),
      ),
      SizedBox(
        width:_isMobile ? constrains.maxWidth *0.7 : constrains.maxWidth*0.4,
        height:_isMobile ? constrains.maxHeight*0.25 : constrains.maxHeight*0.5, //0.8
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            SizedBox.shrink(),
            _overAllNumberOfCountries > _cutOffNumber ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.of(context).statistic_page_show_top_countries(
                    _cutOffNumber+1,
                    _overAllNumberOfCountries ,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Text("Min\n1", textAlign: TextAlign.center,),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: (_overAllNumberOfCountries - 1).toDouble(),
                        value: _cutOffNumber.toDouble(),
                        divisions: _overAllNumberOfCountries - 2,
                        label: "${_cutOffNumber+1}",
                        onChanged: (ev) {
                          setState(() {
                            _cutOffNumber = ev.toInt();
                            limitCountryNumber();
                          });
                        },
                      ),
                    ),
                    Text("Max\n${(_overAllNumberOfCountries).toString()}", textAlign: TextAlign.center,),
                    SizedBox(width: 10,)
                  ],
                ),
              ],
            ) : SizedBox(height: 20),
            Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: legendScrollController,
                  child:  ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.05, 0.95, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child:ListView.builder(
                        controller: legendScrollController,
                        shrinkWrap: true,
                        itemCount: _countryData!.length,
                        itemBuilder: (context,i){
                          return Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5, right: 15),
                            child: MouseRegion(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.fromBorderSide(BorderSide(width: 1)),
                                  color: Theme.of(context).listTileTheme.tileColor!.withAlpha(_touchedIndex == i ? 255 : 190),
                                ),
                                constraints: BoxConstraints(
                                    minWidth: double.infinity
                                ),
                                padding: EdgeInsets.symmetric(vertical: _touchedIndex == i ? 10 : 5, horizontal: 5),
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color:   presetColors[i % presetColors.length], //,colorFromCountry(_countryData.entries.elementAt(i).key)
                                          borderRadius:  BorderRadius.circular(10)
                                      ),
                                      height: 20,
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${_countryData!.entries.elementAt(i).value[0].toStringAsFixed(2)}% ${_countryData!.entries.elementAt(i).key}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Text(_countryData!.entries.elementAt(i).value[1].toString()),
                                    SizedBox(width:2,)
                                  ],
                                ),
                              ),
                              onHover: (ev){
                                setState(() {
                                  _touchedIndex = i;
                                });
                              },
                              onExit: (ev){
                                setState(() {
                                  _touchedIndex = -1;
                                });
                              },
                            ),
                          );
                        }
                    )
                  ),
                ),
            ),
            SizedBox(height: 15,)
          ],
        ),
      ),
      SizedBox(width: 10,)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return !_isMobile ? Dialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        ),
      child: pageContent()
    ).animate().slideX(duration: 300.ms, begin: 0.2).fadeIn(duration: 300.ms) : Scaffold(
      appBar: AppBar(),
      body: pageContent(),
    );
  }

  Widget pageContent(){
    return LayoutBuilder(
        builder: (context, constrains){
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Material(
                        color: Theme.of(context).listTileTheme.tileColor ?? Colors.blueGrey,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 10,
                        child: _countryData == null ? Center(
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ) : _countryData!.isEmpty || context.watch<ConnectionProvider>().status != ConnectionStatus.connected
                            ? Center(child: Text(S.of(context).statistic_page_noData))
                                : _isMobile ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: getPieChartChildren(constrains),
                              ) : Row(
                                spacing: 10,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: getPieChartChildren(constrains),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: CustomTabs(
                          selectedIndex: 0,
                          tabs: [
                            _visitsInPeriod == null
                                ?  CustomTabData(title: "", child: Center(child: Text(S.of(context).settings_noConnection)))
                                :_visitsInPeriod!.isEmpty
                                  ? CustomTabData(title: "", child: Center(
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )))
                                  : CustomTabData(
                                  title: S.of(context).statistic_page_visitsPerPeriod,
                                  child:  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(_isMobile) ActionChip(
                                        label: Text(S.of(context).statistic_page_switchYearDisplay(_showYear)),
                                        avatar: Icon(_showYear ? Icons.calendar_view_month : Icons.calendar_month),
                                        onPressed: () async {
                                          _monthBackNumber = 0;
                                          _showYear = !_showYear;
                                          getVisits();
                                          setState(() { });
                                        },

                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                _monthBackNumber++;
                                                getVisits();
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.arrow_left)
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            spacing: 10,
                                            children: [
                                              if(!_isMobile)ActionChip(
                                                label: Text(S.of(context).statistic_page_switchYearDisplay(_showYear)),
                                                avatar: Icon(_showYear ? Icons.calendar_view_month : Icons.calendar_month),
                                                onPressed: () async {
                                                  _showYear = !_showYear;
                                                  _monthBackNumber = 0;
                                                  getVisits();
                                                  setState(() {});
                                                },
                                              ),
                                              Text(_buildPeriodLabel(context)),
                                            ],
                                          ),
                                          IconButton(
                                              onPressed: () async {
                                                _monthBackNumber--;
                                                getVisits();
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.arrow_right)
                                          )
                                        ],
                                      ),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 18,
                                          left: 12,
                                          top: 24,
                                          bottom: 12,
                                        ),
                                        child: LineChart(lineData(constrains)),
                                      ))
                                    ],
                                  )
                              ),
                            if(!_useServer)CustomTabData(
                                title: S.of(context).statistic_page_visitsPerPerson,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: DatabaseHelper().getVisitDistribution(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      if(snapshot.data!.isEmpty) return Center(child: Text(S.of(context).no_data),);
                                      final data = snapshot.data!;
                                      var maxY = (data.map((item) => item["customers"] as int).reduce((a, b) => a > b ? a : b)).toDouble();
                                      final maxX = (data.map((item) => item["visits"] as int).reduce((a,b) => a > b ? a : b)).toInt();
                                      final mapData = data.toList();
                                      List<int> customersList = [];
                                      for (int i = 1; i <= maxX; i++) {
                                        final element = mapData.firstWhere(
                                              (item) => item["visits"] as int == i,
                                          orElse: () => {"customers": 0},
                                        );
                                        customersList.add(element["customers"] as int);
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: BarChart(
                                          BarChartData(
                                            alignment: BarChartAlignment.spaceEvenly,
                                            maxY: maxY + 2,
                                            barTouchData: BarTouchData(
                                                enabled: true,
                                                touchTooltipData: BarTouchTooltipData(
                                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                                    return BarTooltipItem(
                                                      S.of(context).statistic_page_visitsPerVisitor(rod.toY.toInt(), groupIndex+1),//"${rod.toY.toInt()} Besucher\nhaben ${groupIndex+1} ${S.of(context).statistic_page_visit_plural(groupIndex+1)}",
                                                      Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                                                    );
                                                  },
                                                )
                                            ),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                axisNameWidget: Text(S.of(context).statistic_page_visitsPerPerson_Persons),
                                                sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 40,
                                                    interval: (maxY/3).ceil().toDouble()
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                axisNameWidget: Text(S.of(context).visit_plural(2)),
                                                sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (value, meta){
                                                      return Text((value+1).toInt().toString());
                                                    },
                                                    reservedSize: 40
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false), // rechts aus
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false), // oben aus
                                              ),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            barGroups:  customersList.asMap().entries.map((entry) {
                                              int index = entry.key;
                                              final customers = entry.value;
                                              return BarChartGroupData(
                                                x: index,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: customers.toDouble(),
                                                    color: Colors.blue,
                                                    width: 20,
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                            ),
                          ],
                            switchTab: (index){})
                      )
                  ),
                ],
              ),
              if(!_isMobile)Align(
                alignment: AlignmentGeometry.topRight,
                child: IconButton(
                    padding: EdgeInsets.all(5),
                    onPressed: ()=> navigatorKey.currentState!.pop(),
                    icon: Icon(Icons.close)),
              ),
            ],
          );
        }
    );
  }

  String _buildPeriodLabel(BuildContext context) {
    int overAllInPeriod = _visitsInPeriod!.entries.toList().fold(0, (sum, element) => sum + element.value);
    String visits =  S.of(context).statistic_page_visits(overAllInPeriod);
    if (_showYear) {
      return "${DateTime.now().year-_monthBackNumber}: $overAllInPeriod $visits";
    }

    final locale = MyApp.of(context).getLocale()?.countryCode;
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month - _monthBackNumber);

    final monthName = DateFormat.MMMM(locale).format(targetDate);
    return "$monthName ${targetDate.year}: $overAllInPeriod $visits";
  }

  LineChartData lineData(BoxConstraints constraints) {

    var visitList = _visitsInPeriod!.entries.toList();
    int maxVisits = _visitsInPeriod!.values.reduce((a, b) => a > b ? a : b);
    int yAxisInterval = switch (maxVisits) {
      > 500 => 100,
      > 200 => 50,
      > 100 => 25,
      > 50 => 10,
      > 20 => 5,
      > 10 => 2,
      _ => 1, // Default
    };
    int xAxisInterval = switch(constraints.maxWidth){
      > 800 => 1,
      > 600 => 2,
      > 300 => 5,
      > 150 => 10,
      _ => 10
    };
    if(_isMobile && _showYear) xAxisInterval = 3;

    return LineChartData(
      backgroundColor: Theme.of(context).listTileTheme.tileColor!.withAlpha(100),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: yAxisInterval.toDouble(),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.green.withAlpha(120),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.green.withAlpha(120),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(S.of(context).statistic_page_xAxis(_showYear)),
          axisNameSize: 20,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: xAxisInterval.toDouble(),
            getTitlesWidget: (index, tileMeta){
              //key is in Format
              //!_showYear: "dd.MM.yyyy"
              // _showYear: "MM.yyyy"
              String dateString = visitList[index.toInt()].key;
              return SideTitleWidget(
                meta: tileMeta,
                child: Text(_showYear
                    ?  DateFormat("MMM").format(tryParseForCalendar(dateString))
                    : "${dateString.substring(0,2)}\n${DateFormat("EEE").format(tryParseForCalendar(dateString))}",
                    textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(S.current.statistic_page_numberOfVisits),
          sideTitles: SideTitles(
            showTitles: true,
            interval: yAxisInterval.toDouble(),
           // getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Color(0xff37434d)),
      ),
      minX: 0,
      maxX: visitList.length.toDouble()-1,
      minY: 0,
      maxY: (maxVisits + 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          color: AppSettingsManager.instance.settings.selectedColor,
          spots: [
            for (int i = 0; i < visitList.length; i++)
              FlSpot(i.toDouble(), visitList[i].value.toDouble()),
          ],
          isCurved: false,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final index = touchedSpot.x.toInt();
              final visit = visitList[index];
              return LineTooltipItem(
                _showYear
                    ? "${DateFormat("MMMM yyyy").format(DateFormat("MM.yyyy").parse(visit.key))}\n${S.of(context).stat_page_visits}: ${visit.value}"
                    : "${visit.key}\n${S.of(context).stat_page_visits}: ${visit.value}",
                TextStyle(color: Colors.white70),
                textAlign: TextAlign.start
              );
            }).toList();
          },
        ),
      )
    );
  }
  
  DateTime tryParseForCalendar(String dateString){
      try{
        DateFormat("dd.MM.yyyy").parse(dateString);
      } catch(ex){
        //debugPrint("$ex");
      }

      try{
        return DateFormat("MM.yyyy").parse(dateString);
      } catch(ex){
        //debugPrint("$ex");
      }

      return DateTime.parse(dateString);
  }

}