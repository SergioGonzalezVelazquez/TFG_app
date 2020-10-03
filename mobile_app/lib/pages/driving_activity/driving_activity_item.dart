import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/driving_activity.dart';
import '../../themes/custom_icon_icons.dart';
import 'driving_activity_details.dart';

class DrivingActivityItem extends StatelessWidget {
  final DrivingActivity _activity;
  DrivingActivityItem(this._activity);

  Widget _buildStepper(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(CustomIcon.ui, size: 12),
          Expanded(
              child:
                  Container(width: 1.0, color: Theme.of(context).primaryColor)),
          Icon(CustomIcon.pin, size: 18)
        ],
      ),
    );
  }

  Widget _buildActivityInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              timeFormatter.format(_activity.startTime.toDate()),
              style: TextStyle(fontSize: 11),
            ),
            Spacer(),
            Text(
              _activity.endTime != null
                  ? timeFormatter.format(_activity.endTime.toDate())
                  : '',
              style: TextStyle(fontSize: 11),
            )
          ],
        ),
        SizedBox(
          width: 2,
        ),
        _buildStepper(context),
        SizedBox(
          width: 5,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _activity.startLocationDetails.city,
            ),
            Spacer(),
            Text(
              (_activity.distance / 1000).toStringAsFixed(1) + " km",
              style: TextStyle(fontSize: 12),
            ),
            Spacer(),
            Text(_activity.endLocationDetails == null
                ? ''
                : _activity.endLocationDetails.city),
          ],
        ),
      ],
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DrivingActivityDetails(_activity))),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.only(top: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    title: Text(
                      _buildTitle(),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    subtitle: Row(
                      children: <Widget>[
                        buildDistance(),
                        //buildDuration(),
                      ],
                    ))
              ],
            ),
          ),
        ),
        Divider(
          height: 3,
        )
      ],
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DrivingActivityDetails(_activity),
              ),
            ),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.only(top: 2),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildActivityInfo(context),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                            dateFormatter.format(_activity.startTime.toDate())),
                        Spacer(),
                        Text(
                          "Ver detalles",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            height: 1,
          )
        ],
      ),
    );
  }
}
