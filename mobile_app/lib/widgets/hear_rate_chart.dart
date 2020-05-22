/// Line chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_style.dart' as ChartStyle;
import 'package:charts_flutter/src/text_element.dart' as ChartText;
import 'dart:math';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/phy_activity.dart';

class HeartRateChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final DateTime seriesStart;
  final DateTime seriesEnd;
  final DateTime rangeAnnotationStart;
  final DateTime rangeAnnotationEnd;
  static String pointerValue;

  HeartRateChart(
    this.seriesList,
    this.seriesStart,
    this.seriesEnd, {
    this.animate,
    this.rangeAnnotationStart,
    this.rangeAnnotationEnd,
  });

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory HeartRateChart.withHeartRateData(
      List<PhyActivity> data, DateTime seriesStart, DateTime seriesEnd,
      {DateTime rangeAnnotationStart,
      DateTime rangeAnnotationEnd,
      bool animate = true}) {
    return new HeartRateChart(
      _createWithHeartRate(data),
      seriesStart, seriesEnd,
      rangeAnnotationStart: rangeAnnotationStart,
      rangeAnnotationEnd: rangeAnnotationEnd,
      // Disable animations for image tests.
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(seriesList,
        animate: animate,
        customSeriesRenderers: [
          new charts.LineRendererConfig(
              // ID used to link series to this renderer.
              customRendererId: 'customArea',
              //includePoints: true,
              roundEndCaps: true,
              includeArea: true),
        ],
        primaryMeasureAxis: new charts.NumericAxisSpec(
          showAxisLine: false,
          tickProviderSpec: new charts.StaticNumericTickProviderSpec(
            <charts.TickSpec<num>>[
              charts.TickSpec<num>(60),
              charts.TickSpec<num>(80),
              charts.TickSpec<num>(100),
              charts.TickSpec<num>(120),
              charts.TickSpec<num>(140),
            ],
          ),
        ),
        domainAxis: new charts.DateTimeAxisSpec(
          tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
            day: new charts.TimeFormatterSpec(
              format: 'dd',
              transitionFormat: 'dd',
            ),
            hour: new charts.TimeFormatterSpec(
              format: 'HH:mm',
              transitionFormat: 'HH:mm',
            ),
            minute: new charts.TimeFormatterSpec(
              format: 'HH:mm',
              transitionFormat: 'HH:mm',
            ),
          ),
        ),
        behaviors: [
          new charts.RangeAnnotation(
            (rangeAnnotationStart != null && rangeAnnotationEnd != null)
                ? [
                    new charts.RangeAnnotationSegment(
                      rangeAnnotationStart,
                      rangeAnnotationEnd,
                      charts.RangeAnnotationAxisType.domain,
                      labelAnchor: charts.AnnotationLabelAnchor.end,
                      labelDirection:
                          charts.AnnotationLabelDirection.horizontal,
                      color: charts.MaterialPalette.gray.shade200,
                      labelPosition: charts.AnnotationLabelPosition.margin,
                      startLabel: 'Inicio',
                      endLabel: 'Fin',
                    ),
                  ]
                : [],
          ),
          new charts.PanAndZoomBehavior(),
          LinePointHighlighter(symbolRenderer: CustomCircleSymbolRenderer())
        ],
        selectionModels: [
          SelectionModelConfig(changedListener: (SelectionModel model) {
            if (model.hasDatumSelection)
              pointerValue = model.selectedSeries[0]
                  .measureFn(model.selectedDatum[0].index)
                  .toString();
          })
        ]);
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<PhyActivity, DateTime>> _createWithHeartRate(
      List<PhyActivity> data) {
    /*
    DateTime date1 = DateTime.parse("2020-05-20 20:18:00Z");
    DateTime date2 = DateTime.parse("2020-05-20 20:19:00Z");
    DateTime date3 = DateTime.parse("2020-05-20 20:20:00Z");
    DateTime date4 = DateTime.parse("2020-05-20 20:21:00Z");
    DateTime date5 = DateTime.parse("2020-05-20 20:22:00Z");
    DateTime date6 = DateTime.parse("2020-05-20 20:23:00Z");
    DateTime date7 = DateTime.parse("2020-05-20 20:24:00Z");
    DateTime date8 = DateTime.parse("2020-05-20 20:25:00Z");
    DateTime date9 = DateTime.parse("2020-05-20 20:26:00Z");
    DateTime date10 = DateTime.parse("2020-05-20 20:27:00Z");
    DateTime date11 = DateTime.parse("2020-05-20 20:28:00Z");
    DateTime date12 = DateTime.parse("2020-05-20 20:29:00Z");
    DateTime date13 = DateTime.parse("2020-05-20 20:30:00Z");
    DateTime date14 = DateTime.parse("2020-05-20 20:31:00Z");
    DateTime date15 = DateTime.parse("2020-05-20 20:32:00Z");
    DateTime date16 = DateTime.parse("2020-05-20 20:33:00Z");
    DateTime date17 = DateTime.parse("2020-05-20 20:34:00Z");
    DateTime date18 = DateTime.parse("2020-05-20 20:35:00Z");
    DateTime date19 = DateTime.parse("2020-05-20 20:36:00Z");
    DateTime date20 = DateTime.parse("2020-05-20 20:37:00Z");
    DateTime date21 = DateTime.parse("2020-05-20 20:38:00Z");
    DateTime date22 = DateTime.parse("2020-05-20 20:39:00Z");
    DateTime date23 = DateTime.parse("2020-05-20 20:40:00Z");
    DateTime date24 = DateTime.parse("2020-05-20 20:41:00Z");
    DateTime date25 = DateTime.parse("2020-05-20 20:42:00Z");
    DateTime date26 = DateTime.parse("2020-05-20 20:43:00Z");
    DateTime date27 = DateTime.parse("2020-05-20 20:44:00Z");
    DateTime date28 = DateTime.parse("2020-05-20 20:45:00Z");
    DateTime date29 = DateTime.parse("2020-05-20 20:46:00Z");
    DateTime date30 = DateTime.parse("2020-05-20 20:47:00Z");
    DateTime date31 = DateTime.parse("2020-05-20 20:48:00Z");
    DateTime date32 = DateTime.parse("2020-05-20 20:49:00Z");

    final data = [
      new PhyActivity(
          heartRate: 70, intensity: 5, timestamp: Timestamp.fromDate(date1)),
      new PhyActivity(
          heartRate: 90, intensity: 10, timestamp: Timestamp.fromDate(date2)),
      new PhyActivity(
          heartRate: 91, intensity: 5, timestamp: Timestamp.fromDate(date3)),
      new PhyActivity(
          heartRate: 80, intensity: 10, timestamp: Timestamp.fromDate(date4)),
      new PhyActivity(
          heartRate: 86, intensity: 5, timestamp: Timestamp.fromDate(date5)),
      new PhyActivity(
          heartRate: 90, intensity: 10, timestamp: Timestamp.fromDate(date6)),
      new PhyActivity(
          heartRate: 120, intensity: 5, timestamp: Timestamp.fromDate(date7)),
      new PhyActivity(
          heartRate: 121, intensity: 10, timestamp: Timestamp.fromDate(date8)),
      new PhyActivity(
          heartRate: 115, intensity: 5, timestamp: Timestamp.fromDate(date9)),
      new PhyActivity(
          heartRate: 116, intensity: 10, timestamp: Timestamp.fromDate(date10)),
      new PhyActivity(
          heartRate: 114, intensity: 5, timestamp: Timestamp.fromDate(date11)),
      new PhyActivity(
          heartRate: 111, intensity: 10, timestamp: Timestamp.fromDate(date12)),
      new PhyActivity(
          heartRate: 100, intensity: 5, timestamp: Timestamp.fromDate(date13)),
      new PhyActivity(
          heartRate: 90, intensity: 10, timestamp: Timestamp.fromDate(date14)),
      new PhyActivity(
          heartRate: 90, intensity: 5, timestamp: Timestamp.fromDate(date15)),
      new PhyActivity(
          heartRate: 98, intensity: 10, timestamp: Timestamp.fromDate(date16)),
      new PhyActivity(
          heartRate: 90, intensity: 5, timestamp: Timestamp.fromDate(date17)),
      new PhyActivity(
          heartRate: 87, intensity: 10, timestamp: Timestamp.fromDate(date18)),
      new PhyActivity(
          heartRate: 85, intensity: 5, timestamp: Timestamp.fromDate(date19)),
      new PhyActivity(
          heartRate: 80, intensity: 10, timestamp: Timestamp.fromDate(date20)),
      new PhyActivity(
          heartRate: 76, intensity: 5, timestamp: Timestamp.fromDate(date21)),
      new PhyActivity(
          heartRate: 76, intensity: 10, timestamp: Timestamp.fromDate(date22)),
      new PhyActivity(
          heartRate: 76, intensity: 5, timestamp: Timestamp.fromDate(date23)),
      new PhyActivity(
          heartRate: 73, intensity: 10, timestamp: Timestamp.fromDate(date24)),
      new PhyActivity(
          heartRate: 79, intensity: 5, timestamp: Timestamp.fromDate(date25)),
      new PhyActivity(
          heartRate: 80, intensity: 10, timestamp: Timestamp.fromDate(date26)),
      new PhyActivity(
          heartRate: 91, intensity: 5, timestamp: Timestamp.fromDate(date27)),
      new PhyActivity(
          heartRate: 72, intensity: 10, timestamp: Timestamp.fromDate(date28)),
      new PhyActivity(
          heartRate: 74, intensity: 10, timestamp: Timestamp.fromDate(date29)),
      new PhyActivity(
          heartRate: 72, intensity: 10, timestamp: Timestamp.fromDate(date30)),
      new PhyActivity(
          heartRate: 80, intensity: 10, timestamp: Timestamp.fromDate(date31)),
      new PhyActivity(
          heartRate: 80, intensity: 10, timestamp: Timestamp.fromDate(date32)),
    ];
    */

    return [
      new charts.Series<PhyActivity, DateTime>(
        id: 'HeartRate',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (PhyActivity activity, _) => activity.timestamp.toDate(),
        measureFn: (PhyActivity activity, _) => activity.heartRate,
        data: data,
      )
        // Configure our custom bar target renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customArea'),
    ];
  }
}

// https://github.com/google/charts/issues/58
class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  @override
  void paint(ChartCanvas canvas, Rectangle bounds,
      {List<int> dashPattern,
      Color fillColor,
      charts.FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 60, bounds.width + 13,
            bounds.height + 10),
        fill: Color.fromHex(code: '#f2f2f2'));
    var textStyle = ChartStyle.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 13;
    canvas.drawText(
        ChartText.TextElement(HeartRateChart.pointerValue, style: textStyle),
        (bounds.left - 2).round(),
        (bounds.top - 58).round());
  }
}
