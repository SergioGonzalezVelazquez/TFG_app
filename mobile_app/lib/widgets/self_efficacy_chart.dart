/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:tfg_app/models/exposure_exercise.dart';
import 'package:tfg_app/themes/style.dart';

class SelfEfficacyChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SelfEfficacyChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SelfEfficacyChart.withExerciseData(List<ExposureExercise> data,
      {bool animate = true}) {
    return new SelfEfficacyChart(
      _createWithData(data),
      // Disable animations for image tests.
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
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
      behaviors: [
        new charts.ChartTitle('Número de exposición',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea,
            titleStyleSpec: charts.TextStyleSpec(
                fontSize: 10, fontFamily: CustomTheme.fontFamily),
            outerPadding: 0,
            innerPadding: 5),
        new charts.ChartTitle('Escala de autoeficacia',
            behaviorPosition: charts.BehaviorPosition.start,
            titleStyleSpec: charts.TextStyleSpec(
                fontSize: 10, fontFamily: CustomTheme.fontFamily),
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea,
            outerPadding: 0,
            innerPadding: 5)
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalData, String>> _createWithData(
      List<ExposureExercise> data) {
    List<OrdinalData> selfEfficacyData = [];

    for (int i = 0; i < data.length; i++) {
      ExposureExercise exposure = data[i];
      selfEfficacyData.add(
        new OrdinalData((i + 1).toString(), exposure.selfEfficacyBefore),
      );
    }

    return [
      new charts.Series<OrdinalData, String>(
        id: 'selfEfficacy',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault.darker,
        domainFn: (OrdinalData sales, _) => sales.index,
        measureFn: (OrdinalData sales, _) => sales.efficacy,
        data: selfEfficacyData,
      )
    ];
  }
}

/// Sample ordinal data type.
class OrdinalData {
  final String index;
  final int efficacy;

  OrdinalData(this.index, this.efficacy);
}
