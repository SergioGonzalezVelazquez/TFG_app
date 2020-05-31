/// Example of a numeric combo chart with two series rendered as bars, and a
/// third rendered as a line.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:tfg_app/models/exposure_exercise.dart';

class USAsChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final int originalUsas;

  USAsChart(this.seriesList, this.originalUsas, {this.animate});

  /// Creates a [LineChart]
  factory USAsChart.withExerciseData(
      List<ExposureExercise> data, int originalUsas,
      {bool animate = true}) {
    return new USAsChart(
      _createWithData(data),
      originalUsas,
      // Disable animations for image tests.
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      barGroupingType: charts.BarGroupingType.grouped,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(20),
            charts.TickSpec<num>(40),
            charts.TickSpec<num>(60),
            charts.TickSpec<num>(80),
            charts.TickSpec<num>(100),
          ],
        ),
      ),
      behaviors: [new charts.SeriesLegend(), ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearData, String>> _createWithData(
      List<ExposureExercise> data) {
    List<LinearData> beforeData = [];
    List<LinearData> afterData = [];

    for (int i = 0; i < data.length; i++) {
      ExposureExercise exposure = data[i];
      beforeData.add(new LinearData((i + 1).toString(), exposure.usasBefore));
      afterData.add(new LinearData((i + 1).toString(), exposure.usasAfter));
    }

    return [
      new charts.Series<LinearData, String>(
        id: 'Antes',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault.darker,
        domainFn: (LinearData sales, _) => sales.index,
        measureFn: (LinearData sales, _) => sales.usas,
        data: beforeData,
      ),
      new charts.Series<LinearData, String>(
        id: 'Después',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault.lighter,
        domainFn: (LinearData sales, _) => sales.index,
        measureFn: (LinearData sales, _) => sales.usas,
        data: afterData,
      )
      // Set the 'Los Angeles Revenue' series to use the secondary measure axis.
      // All series that have this set will use the secondary measure axis.
      // All other series will use the primary measure axis.
    ];
  }
}

/// Sample linear data type.
class LinearData {
  final String index;
  final int usas;

  LinearData(this.index, this.usas);
}
