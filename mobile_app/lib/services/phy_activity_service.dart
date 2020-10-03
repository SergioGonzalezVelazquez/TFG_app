import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/phy_activity.dart';
import 'auth.dart';

final CollectionReference phyActivityRef =
    FirebaseFirestore.instance.collection('phy_activity');

final List<int> ignoreValues = [0, 1, 255];

class PhyActivityService {
  // Factory constructor which returns a singleton instance
  // of the service
  PhyActivityService._();
  static final PhyActivityService _instance = PhyActivityService._();
  factory PhyActivityService() => _instance;
  bool _initialized = false;

  final AuthService _authService = AuthService();

  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
    }
  }

  void dispose() {
    _initialized = false;
  }

  /// Given a list of phyActivity object, return a Map with keys for
  /// min, max and median BPM values
  Map<String, int> calculateMinMaxMedian(List<PhyActivity> phyActivities) {
    Map<String, int> result = {};
    result['median'] = 0;
    result['max'] = 0;
    result['min'] = 0;

    if (phyActivities.isNotEmpty) {
      int sum = 0;
      int count = 0;
      int max;
      int min;

      phyActivities.forEach((element) {
        if (element.heartRate != null &&
            !ignoreValues.contains(element.heartRate)) {
          count++;
          sum += element.heartRate;

          if (min == null) {
            min = element.heartRate;
            max = element.heartRate;
          } else {
            min = element.heartRate < min ? element.heartRate : min;
            max = element.heartRate > max ? element.heartRate : max;
          }
        }
      });

      result['median'] = (sum / count).round();
      result['max'] = max;
      result['min'] = min;
    }

    return result;
  }

  /// Read phyActivities between dateFrom and dateTo
  /// If fillWithNull is true, then fill missing  values with a PhyActivity where heartRate is null
  Future<List<PhyActivity>> read(DateTime dateFrom, DateTime dateTo,
      {bool fillWithNull = false}) async {
    List<PhyActivity> activities = [];
    DateTime _currentDateFrom = dateFrom;

    // Iterate for each day between dateFrom and dateTo..
    while (_currentDateFrom.isBefore(dateTo)) {
      // If currentDateFrom is at same day as dateTo
      if (_isSameDay(_currentDateFrom, dateTo)) {
        List<PhyActivity> newActivities =
            await _addPartialDay(_currentDateFrom, dateTo);
        activities = List.from(activities)..addAll(newActivities);
      }
      // For first day..
      else if (_isSameDay(_currentDateFrom, dateFrom)) {
        DateTime limitDate =
            DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 23, 59, 59)
                .toLocal();
        List<PhyActivity> newActivities =
            await _addPartialDay(dateFrom, limitDate);
        activities = List.from(activities)..addAll(newActivities);
      }
      // For any day between dateTo and dateFrom
      else {
        List<PhyActivity> newActivities = await _addAllDay(_currentDateFrom);
        activities = List.from(activities)..addAll(newActivities);
      }

      // Step to next day at 00:00
      _currentDateFrom = DateTime(_currentDateFrom.year, _currentDateFrom.month,
          _currentDateFrom.day + 1, 0, 0);
    }

    if (fillWithNull && activities.isNotEmpty) {
      activities = _fillWithNull(activities, dateFrom, dateTo);
    }

    activities.forEach((element) {
      if (element != null && ignoreValues.contains(element.heartRate)) {
        element.heartRate = null;
      }
    });
    return activities;
  }

  /// Fill missing values with a PhyActivity object where heartRate is null
  List<PhyActivity> _fillWithNull(
      List<PhyActivity> activities, DateTime dateFrom, DateTime dateTo) {
    print("fill with null. Habia: " + activities.length.toString());

    DateTime currentDate = dateFrom;
    int index = 0;
    while (currentDate.isBefore(dateTo)) {
      if (!(activities[index]
          .timestamp
          .toDate()
          .isAtSameMomentAs(currentDate))) {
        activities.insert(
          index,
          PhyActivity(
            timestamp: Timestamp.fromDate(currentDate),
          ),
        );
      } else if (index < activities.length - 1) {
        index++;
      }
      currentDate = currentDate.add(const Duration(minutes: 1));
    }
    print("fill with null. Después: " + activities.length.toString());
    return activities;
  }

  Future<List<PhyActivity>> _addPartialDay(
      DateTime dateFrom, DateTime dateTo) async {
    List<PhyActivity> activities = [];
    String strDate = _dateAsString(dateFrom);
    int hourFrom = dateFrom.hour;
    int hourTo = dateTo.hour;

    // Get physical activities for each hour between
    // dateFrom and dateTo
    for (int i = hourFrom; i <= hourTo; i++) {
      String strHour = _hourAsString(i);
      DocumentSnapshot doc = await phyActivityRef
          .doc(_authService.user.id)
          .collection(strDate)
          .doc(strHour)
          .get();

      if (doc.exists) {
        doc.data()['activities'].forEach((act) {
          if (act['heartRate'] <= 1) {
            act['heartRate'] = null;
          }
          DateTime timestamp = act['timestamp'].toDate();
          if (timestamp.isAtSameMomentAs(dateFrom) ||
              timestamp.isAtSameMomentAs(dateTo)) {
            activities.add(PhyActivity.fromMap(act));
          } else if (timestamp.isBefore(dateTo) &&
              timestamp.isAfter(dateFrom)) {
            activities.add(PhyActivity.fromMap(act));
          }
        });
      }
    }
    return activities;
  }

  Future<List<PhyActivity>> _addAllDay(DateTime date) async {
    List<PhyActivity> activities = [];
    String strDate = _dateAsString(date);

    QuerySnapshot docs = await phyActivityRef
        .doc(_authService.user.id)
        .collection(strDate)
        .get();

    docs.docs.forEach((doc) {
      doc.data()['activities'].forEach((act) {
        activities.add(PhyActivity.fromMap(act));
      });
    });
    return activities;
  }

  bool _isSameDay(DateTime dateFrom, DateTime dateTo) {
    return dateFrom.year == dateTo.year &&
        dateFrom.month == dateTo.month &&
        dateFrom.day == dateTo.day;
  }

  String _hourAsString(int hour) {
    return hour < 10 ? "0" + hour.toString() + "_00" : hour.toString() + "_00";
  }

  String _dateAsString(DateTime date) {
    return date.toIso8601String().split("T")[0].replaceAll("-", "_");
  }
}
