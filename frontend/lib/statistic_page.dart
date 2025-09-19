import 'dart:collection';
import 'package:country_picker/country_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'generated/l10n.dart';
import 'http_helper.dart';
import 'main.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

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
  bool _isMobile = false;
  int _touchedIndex = -1;
  int _cutOffNumber = 8;
  int _monthBackNumber = 0;
  int _overAllNumberOfCountries = 0;
  bool _showYear = false;
  bool _useServer = false;

  Map<String, dynamic> _countryData = {};
  Map<String, int> _visitsInPeriod = {};

  final List<Color> presetColors = [ //TODO: Change to different approach
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.brown,
  ];


  @override
  void initState() {
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    getData();
    super.initState();
  }

  Future<void> getData() async {
      limitCountryNumber(_useServer);
      //await HttpHelper().getAllVisitsInPeriodNew(_monthBackNumber, _showYear);
      _useServer
          ? _visitsInPeriod  = await HttpHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear)
          : _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);

      setState(() {});
  }

  Future<void> limitCountryNumber(bool useServer) async {
    Map<String, dynamic> countryDataLong;
    if(useServer){
      var result = await HttpHelper().getStats();
      if (result == null) return;

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
    _cutOffNumber = _overAllNumberOfCountries > 8 ? 8 : _overAllNumberOfCountries;

    final sortedEntries = countryDataLong.entries.toList()..sort((a, b) => b.value[0].compareTo(a.value[0]));
    if(!mounted) return;
    if (sortedEntries.length > _cutOffNumber) { //sortedEntries.length-1 so if "Sonstiges" would be comprised of only one country, the actual name would show
      final topList = sortedEntries.take(_cutOffNumber).toList();

      final rest = sortedEntries.skip(_cutOffNumber);
      final restSum = rest.fold<double>(0, (sum, entry) => sum + entry.value);

      final Map<String, dynamic> limited = {
        for (var entry in topList) CountryLocalizations.of(context)?.countryName(countryCode: entry.key) ?? Country.tryParse(entry.key)!.name : entry.value,
        mounted
            ? S.of(context).add_user_miscellaneous
            : S.current.add_user_miscellaneous: restSum,
      };

      var sortedLimitedList = limited.entries.toList()..sort((a, b) => b.value[0].compareTo(a.value[0]));

      Map<String, dynamic> sortedLimited = LinkedHashMap.fromEntries(sortedLimitedList);

      _countryData = sortedLimited;
    } else {
      final Map<String, dynamic> limited = {
        for (var entry in sortedEntries) CountryLocalizations.of(context)?.countryName(countryCode: entry.key) ?? Country.tryParse(entry.key)!.name : entry.value
      };
      _countryData = limited;
    }
  }


  PieChartSectionData chartData(double value, String title, int index, BoxConstraints constrains){
    double normalRadius = _isMobile ? constrains.maxWidth*0.18 : constrains.maxWidth*0.09;
    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 20.0 : 14.0;
    final radius = isTouched ? (normalRadius+10) : normalRadius;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    return PieChartSectionData(
      color: presetColors[index % presetColors.length],
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
    return [
      SizedBox(
        width: _isMobile ? constrains.maxWidth *0.9 : constrains.maxWidth*0.4,
        height: _isMobile ? constrains.maxHeight*0.2 : constrains.maxWidth*0.4,
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
            centerSpaceRadius: constrains.maxWidth*0.03,
            sections: List.generate(_countryData.length, (i) {
              String countryName = _countryData.keys.elementAt(i);
              double value = _countryData[countryName][0] ?? 0;
              return chartData(value, countryName, i, constrains);
            }),
          ),
        ),
      ),
      SizedBox(
        width:_isMobile ? constrains.maxWidth *0.7 : constrains.maxWidth*0.4,
        height:_isMobile ? constrains.maxHeight*0.25 : constrains.maxHeight*0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            _overAllNumberOfCountries > 8 ? Column(
              children: [
                Text(S.of(context).statistic_page_show_top_countries(_cutOffNumber, _overAllNumberOfCountries)),
                Slider(
                    min: 1,
                    max: _overAllNumberOfCountries.toDouble(),
                    value: _cutOffNumber.toDouble(),
                    onChanged: (ev){
                      setState(() {
                        _cutOffNumber = ev.toInt();
                        limitCountryNumber(true);
                      });
                    }),
              ],
            ) : SizedBox(height: 20,),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _countryData.length,
                itemBuilder: (context,i){
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
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
                                  color: presetColors[i % _countryData.length],
                                  borderRadius:  BorderRadius.circular(10)
                              ),
                              height: 20,
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                "${_countryData.entries.elementAt(i).value[0].toStringAsFixed(2)}% ${_countryData.entries.elementAt(i).key}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(_countryData.entries.elementAt(i).value[1].toString()),
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
            ),
            Spacer()
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
                        borderRadius: BorderRadius.circular(12),
                        elevation: 10,
                        child: _countryData.isEmpty ? Center(
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ) : _isMobile ? Column(
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
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: _visitsInPeriod.isEmpty ? Center(
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ) : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if(_isMobile) ActionChip(
                                  label: Text(S.of(context).statistic_page_switchYearDisplay(_showYear)),
                                  avatar: Icon(_showYear ? Icons.calendar_view_month : Icons.calendar_month),
                                  onPressed: () async {
                                    setState(() {
                                      _showYear = !_showYear;
                                      _monthBackNumber = 0;
                                    });
                                    _useServer
                                        ? _visitsInPeriod  = await HttpHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear)
                                        : _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);
                                    setState(() {});
                                  },

                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          _monthBackNumber++;
                                          _useServer
                                              ? _visitsInPeriod  = await HttpHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear)
                                              : _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);
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
                                              _useServer
                                                  ? _visitsInPeriod  = await HttpHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear)
                                                  : _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);
                                              setState(() {});
                                          },
                                        ),
                                        Text(_buildPeriodLabel(context)),
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          _monthBackNumber--;
                                          _useServer
                                              ? _visitsInPeriod  = await HttpHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear)
                                              : _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);
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
                                  child: LineChart(
                                      lineData(constrains)
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                      )
                  ),

                ],
              ),
              Align(
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
    int overAllInPeriod = _visitsInPeriod.entries.toList().fold(0, (sum, element) => sum + element.value);
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
    var visitList = _visitsInPeriod.entries.toList();
    int maxVisits = _visitsInPeriod.values.reduce((a, b) => a > b ? a : b);
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
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: yAxisInterval.toDouble(),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.green,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.green,
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
              //key is in Format "dd.MM.yyyy"
              String dateString = visitList[index.toInt()].key;
              return SideTitleWidget(
                meta: tileMeta,
                child: Text(_showYear ?  DateFormat("MMM").format(DateFormat("MM.yyyy").parse(dateString)) : "${dateString.substring(0,2)}\n${DateFormat("EEE").format(DateFormat("dd.MM.yyyy").parse(dateString))}"),
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
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: visitList.length.toDouble()-1,
      minY: 0,
      maxY: (maxVisits + 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
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
}
