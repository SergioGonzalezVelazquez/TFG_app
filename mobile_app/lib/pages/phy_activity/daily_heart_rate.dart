import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/phy_activity.dart';
import '../../services/phy_activity_service.dart';
import '../../widgets/hear_rate_chart.dart';
import '../../widgets/progress.dart';

class DailyHeartRatePage extends StatefulWidget {
  static const route = "/dailyHeartRate";

  _DailyHeartRatePageState createState() => _DailyHeartRatePageState();
}

class _DailyHeartRatePageState extends State<DailyHeartRatePage> {
  List<PhyActivity> _activities = [];
  PhyActivityService _phyActivityService;
  bool _isLoading = true;
  DateFormat formatter;
  DateTime _currentDate;
  DateTime _currentDateTimeStart;
  DateTime _currentDateTimeEnd;

  String _bpmMax = "-";
  String _bpmMin = "-";
  String _bpmMedian = "-";

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now().toLocal();
    initializeDateFormatting();
    formatter = DateFormat('EEEE, dd-MM-yyyy', 'es');
    _phyActivityService = PhyActivityService();
    _getPhyActivities(_currentDate);
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///https://github.com/jifalops/datetime_picker_formfield
  Widget dateInput(GlobalKey<FormState> inputKey, DateTime initialValue,
      Function onChanged) {
    return Form(
      key: inputKey,
      child: DateTimeField(
        onChanged: onChanged,
        format: dateFormatter,
        initialValue: initialValue,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime.now());
        },
        onSaved: (val) {
          setState(() {});
        },
      ),
    );
  }

  Future<void> _getPhyActivities(DateTime date) async {
    setState(() {
      _isLoading = true;
      _currentDate = date;
    });
    DateTime currentDateTimeStart = DateTime(
        _currentDate.year, _currentDate.month, _currentDate.day, 0, 0, 0);
    DateTime currentDateTimeEnd = DateTime(
        _currentDate.year, _currentDate.month, _currentDate.day, 23, 59, 59);

    List<PhyActivity> listActivities = await _phyActivityService
        .read(currentDateTimeStart, currentDateTimeEnd, fillWithNull: true);

    Map<String, int> result =
        _phyActivityService.calculateMinMaxMedian(listActivities);
    int max = result['max'];
    int median = result['median'];
    int min = result['min'];

    if (mounted) {
      setState(() {
        _bpmMax = max.toString();
        _bpmMedian = median.toString();
        _bpmMin = min.toString();
        _currentDateTimeStart = currentDateTimeStart;
        _currentDateTimeEnd = currentDateTimeEnd;
        _activities = listActivities;
        _isLoading = false;
      });
    }
  }

  Widget _detailsItem(BuildContext context, String title, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(title)
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_left,
                size: 30,
                color: Colors.black38,
              ),
              onPressed: () {
                setState(() {
                  _getPhyActivities(_currentDate.subtract(
                    const Duration(days: 1),
                  ));
                });
              },
            ),
            InkWell(
              onTap: () async {
                DateTime date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: DateTime.now(),
                    helpText: "Selecciona una fecha".toUpperCase(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Theme.of(context).primaryColor,
                          accentColor: Theme.of(context).primaryColor,
                          colorScheme: ColorScheme.light(
                              primary: Theme.of(context).primaryColor),
                          buttonTheme: ButtonThemeData(
                              textTheme: ButtonTextTheme.primary),
                        ),
                        child: child,
                      );
                    },
                    cancelText: "CANCELAR",
                    locale: const Locale('es', 'ES'),
                    lastDate: DateTime.now());
                if (date != null) {
                  setState(() {
                    _currentDate = date;
                    _getPhyActivities(_currentDate);
                  });
                }
              },
              child: Text(
                formatter.format(_currentDate),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_right,
                size: 30,
                color: Colors.black38,
              ),
              onPressed: () {
                print("on pressed");
                setState(() {
                  _getPhyActivities(_currentDate.add(
                    const Duration(days: 1),
                  ));
                });
              },
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height * 0.4,
          child: HeartRateChart.withHeartRateData(
              _activities, _currentDateTimeStart, _currentDateTimeEnd),
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _detailsItem(context, "BPM máximo", _bpmMax),
            _detailsItem(context, "BPM mínimo", _bpmMin),
            _detailsItem(context, "BPM promedio", _bpmMedian),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frecuencia cardiaca'),
      ),
      body: _isLoading
          ? circularProgress(context, text: "Recuperando datos")
          : _buildPage(context),
    );
  }
}
