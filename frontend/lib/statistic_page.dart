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
  int _touchedIndex = -1;
  int _cutOffNumber = 8;
  int _monthBackNumber = 0;
  int _overAllNumberOfCountries = 0;
  bool _showYear = false;

  Map<String, double> _countryData = {};
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
    getData();
    super.initState();
  }

  Future<void> getData() async {
      limitCountryNumber();
      _visitsInPeriod = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber,_showYear);
      _cutOffNumber = _overAllNumberOfCountries > 8 ? 8 : _overAllNumberOfCountries;
      setState(() {});
  }

  Future<void> limitCountryNumber() async {
    var countryDataLong = await DatabaseHelper().getBirthCountries();
    _overAllNumberOfCountries = countryDataLong.length;
    final sortedEntries = countryDataLong.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if(!mounted) return;
    if (sortedEntries.length > _cutOffNumber) { //sortedEntries.length-1 so if "Sonstiges" would be comprised of only one country, the actual name would show
      final topList = sortedEntries.take(_cutOffNumber).toList();

      final rest = sortedEntries.skip(_cutOffNumber);
      final restSum = rest.fold<double>(0, (sum, entry) => sum + entry.value);

      print(Country.tryParse(topList.first.key)!.nameLocalized ?? "NOPE");
      final Map<String, double> limited = {
        for (var entry in topList) CountryLocalizations.of(context)?.countryName(countryCode: entry.key) ?? Country.tryParse(entry.key)!.name : entry.value,
        mounted
            ? S.of(context).add_user_miscellaneous
            : S.current.add_user_miscellaneous: restSum,
      };

      var sortedLimitedList = limited.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      Map<String, double> sortedLimited = LinkedHashMap.fromEntries(sortedLimitedList);

      _countryData = sortedLimited;
    } else {
      final Map<String, double> limited = {
        for (var entry in sortedEntries) CountryLocalizations.of(context)?.countryName(countryCode: entry.key) ?? Country.tryParse(entry.key)!.name : entry.value
      };
      _countryData = limited;
    }
  }

  PieChartSectionData chartData(double value, String title, int index, BoxConstraints constrains){
    double normalRadius = constrains.maxWidth*0.09;
    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 25.0 : 16.0;
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
    ),
      child: LayoutBuilder(
          builder: (context, constrains){
            return Column(
              children: [
                SizedBox(height: 20,),
                Text(S.of(context).main_page_statistic),
                Expanded(
                  child: _countryData.isEmpty ? Center(
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ) : Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:  constrains.maxWidth*0.4,
                        height: constrains.maxWidth*0.4,
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
                            centerSpaceRadius: constrains.maxWidth*0.04,
                            sections: List.generate(_countryData.length, (i) {
                              String countryName = _countryData.keys.elementAt(i);
                              double value = _countryData[countryName] ?? 0;
                              return chartData(value, countryName, i, constrains);
                            }),
                          ),
                        ),
                      ),
                       SizedBox(
                          width: constrains.maxWidth*0.4,
                          height: constrains.maxHeight*0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              _overAllNumberOfCountries > 8 ? Column( //TODO: change completely
                                children: [
                                  Text(S.of(context).statistic_page_show_top_countries(_cutOffNumber, _overAllNumberOfCountries)),
                                  Slider(
                                      min: 1,
                                      max: _overAllNumberOfCountries.toDouble(),
                                      value: _cutOffNumber.toDouble(),
                                      onChanged: (ev){
                                        setState(() {
                                          _cutOffNumber = ev.toInt();
                                          limitCountryNumber();
                                        });
                                      }),
                                ],
                              ) : SizedBox(height: 20,),
                              for(int i = 0; i < _countryData.length; i++)...{
                                MouseRegion(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.fromBorderSide(BorderSide(width: 1)),
                                        color: Theme.of(context).listTileTheme.tileColor!.withAlpha(_touchedIndex == i ? 255 : 190)
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
                                        Text("${_countryData.entries.elementAt(i).value.toStringAsFixed(2)}% ${_countryData.entries.elementAt(i).key}")
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
                                )
                              },
                              Spacer()
                            ],
                          ),
                        ),
                      SizedBox(width: 10,)
                    ],
                  ),
                ),
                Expanded(
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
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    _monthBackNumber++;
                                    var l = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber, _showYear);
                                    setState(() {
                                      _visitsInPeriod = l;
                                    });
                                  },
                                  icon: Icon(Icons.arrow_left)
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: [
                                  ActionChip(
                                    label: Text(S.of(context).statistic_page_switchYearDisplay(_showYear)),
                                    avatar: Icon(_showYear ? Icons.calendar_view_month : Icons.calendar_month),
                                    onPressed: () async {
                                      setState(() {
                                        _showYear = !_showYear;
                                        _monthBackNumber = 0;
                                      });

                                      final visits = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber, _showYear);
                                      setState(() {
                                        _visitsInPeriod = visits;
                                      });
                                    },
                                  ),
                                  Text(_buildPeriodLabel(context)),
                                ],
                              ),
                              IconButton(
                                  onPressed: () async {
                                    _monthBackNumber--;
                                    var l = await DatabaseHelper().getAllVisitsInPeriod(_monthBackNumber, _showYear);
                                    setState(() {
                                      _visitsInPeriod = l;
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
                              lineData(constrains)
                          ),
                        ))
                      ],
                    ),
                  ),
                ),

              ],
            );
          }
      )
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
          axisNameWidget: Text(S.of(context).statistic_page_xAxis(_showYear)),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: constraints.maxWidth > 800 ? 1 : 2,
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
