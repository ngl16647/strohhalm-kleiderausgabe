import 'dart:collection';
import 'package:country_picker/country_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'generated/l10n.dart';
import 'main.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  StatisticPageState createState() => StatisticPageState();
}

class StatisticPageState extends State<StatisticPage> {
  bool isMobile = false;
  bool chartLoaded = false;
  int touchedIndex = -1;
  int cutOffNumber = 5;
  int monthBackNumber = 0;
  int overAllThisMonth = 0;
  int overAllVisits = 0;
  Map<String, double> _countryData = {};
  Map<String, int> visitsLastMonth = {};
  final List<Color> presetColors = [
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
    isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    getCountryData();
    super.initState();
  }

  Future<void> getCountryData() async {
      limitCountryNumber();
      visitsLastMonth = await DatabaseHelper().getAllVisitsInLastMonths(monthBackNumber);
      overAllThisMonth = visitsLastMonth.entries.toList().fold(0, (sum, element) => sum + element.value);
      overAllVisits = await DatabaseHelper().countAllVisits(); //TODO: Decide where to put information
      setState(() {
        chartLoaded = true;
      });
  }

  Future<void> limitCountryNumber() async {
    var countryDataLong = await DatabaseHelper().getBirthCountries();
    final sortedEntries = countryDataLong.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (sortedEntries.length-1 > cutOffNumber) {
      final top10 = sortedEntries.take(cutOffNumber).toList();

      //double restSum = 0;
      //for(int i = 10; i < sortedEntries.length; i++){
      //  restSum += sortedEntries[i].value;
      //}
      final rest = sortedEntries.skip(cutOffNumber);
      final restSum = rest.fold<double>(0, (sum, entry) => sum + entry.value);

      final Map<String, double> limited = {
        for (var entry in top10) Country.tryParse(entry.key)!.name : entry.value,
        "Sonstiges": restSum,
      };

      var sortedLimitedList = limited.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      Map<String, double> sortedLimited = LinkedHashMap.fromEntries(sortedLimitedList);

      _countryData = sortedLimited;
    } else {
      final Map<String, double> limited = {
        for (var entry in sortedEntries) Country.tryParse(entry.key)!.name : entry.value
      };
      _countryData = limited;
    }
  }

  PieChartSectionData chartData(double value, String title, int index){
    final isTouched = index == touchedIndex;
    final fontSize = isTouched ? 25.0 : 16.0;
    final radius = isTouched ? 120.0 : 110.0;
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

  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              SizedBox(height: 20,),
              Text(S.of(context).main_page_statistic),
              Expanded(
                child: !chartLoaded ? Center(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ) : Row(
                  spacing: 50,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                          ),
                          centerSpaceRadius: 60,

                          sections: List.generate(_countryData.length, (i) {
                            String countryName = _countryData.keys.elementAt(i);
                            double value = _countryData[countryName] ?? 0;
                            return chartData(value, countryName, i);
                          }),
                        ),
                      ),

                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Slider(
                            min: 1,
                            max: 12,
                            value: cutOffNumber.toDouble(),
                            onChanged: (ev){
                              setState(() {
                                cutOffNumber = ev.toInt();
                                limitCountryNumber();
                              });
                            }),
                        for(int i = 0; i < _countryData.length; i++)...{
                          MouseRegion(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.fromBorderSide(BorderSide(width: 1)),
                                  color: Theme.of(context).listTileTheme.tileColor!.withAlpha(touchedIndex == i ? 255 : 190)
                              ),
                              constraints: BoxConstraints(
                                minWidth: 300
                              ),
                              padding: EdgeInsets.symmetric(vertical: touchedIndex == i ? 10 : 5, horizontal: 5),
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
                                  Text("${_countryData.entries.elementAt(i).value.toStringAsFixed(2)}% ${_countryData.entries.elementAt(i).key}")
                                ],
                              ),
                            ),
                            onHover: (ev){
                              setState(() {
                                touchedIndex = i;
                              });
                            },
                            onExit: (ev){
                              setState(() {
                                touchedIndex = -1;
                              });
                            },
                          )
                        },
                        Spacer()
                      ],
                    )
                  ],
                ),
              ),
               Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                      child: !chartLoaded ? Center(
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ) : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  monthBackNumber++;
                                  var l = await DatabaseHelper().getAllVisitsInLastMonths(monthBackNumber);
                                  setState(() {
                                    visitsLastMonth = l;
                                  });
                                },
                                icon: Icon(Icons.arrow_left)
                            ),
                            Text("${DateFormat.MMMM(MyApp.of(context).getLocale()!.countryCode).format(DateTime.now().subtract(Duration(days: 31 * monthBackNumber)))}: $overAllThisMonth Besuche",),
                            IconButton(
                                onPressed: () async {
                                  monthBackNumber--;
                                  var l = await DatabaseHelper().getAllVisitsInLastMonths(monthBackNumber);
                                  setState(() {
                                    visitsLastMonth = l;
                                  });
                                },
                                icon: Icon(Icons.arrow_right)
                            )
                          ],
                        ),),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(
                            right: 18,
                            left: 12,
                            top: 24,
                            bottom: 12,
                          ),
                          child: LineChart(
                              lineData()
                          ),
                        ))
                      ],
                    ),
                  ),
               ),
            ],
    );
  }

  LineChartData lineData() {
    var visitList = visitsLastMonth.entries.toList();
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
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
          axisNameWidget: Text(S.of(context).statistic_page_dayOfMonth),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (index, tileMeta){
              return SideTitleWidget(
                meta: tileMeta,
                child: Text(visitList[index.toInt()].key.substring(0,2)),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(S.current.statistic_page_numberOfVisits),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
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
      maxY: visitList.reduce((a, b) => a.value > b.value ? a : b).value.toDouble() + 5,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for(int i = 0; i < visitList.length; i++)...{
              FlSpot(i.toDouble(), visitList[i].value.toDouble() ),
            }
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
    );
  }
}
