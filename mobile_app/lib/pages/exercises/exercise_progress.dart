import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/exercise.dart';
import '../../widgets/progress.dart';
import '../../widgets/self_efficacy_chart.dart';
import '../../widgets/usas_chart.dart';

class ExerciseProgress extends StatefulWidget {
  final Exercise exercise;

  ExerciseProgress(this.exercise);
  _ExerciseProgressState createState() => _ExerciseProgressState();
}

class _ExerciseProgressState extends State<ExerciseProgress> {
  final bool _isLoading = false;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getDurationString(int seconds) {
    Duration duration = Duration(seconds: seconds);
    int minutes = duration.inMinutes % 60;
    int hours = duration.inHours % 60;
    seconds = seconds % 60;

    String str = '';
    if (hours > 0) str += '${hours.toString()} h ';
    if (minutes > 0) str += '${minutes.toString()} min ';
    if (seconds > 0) str += '${seconds.toString()} seg';

    return str;
  }

  Widget _buildTableResumeHeader1() {
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.06),
          1: FractionColumnWidth(.18),
          2: FractionColumnWidth(.25),
          3: FractionColumnWidth(.26),
          4: FractionColumnWidth(.25)
        },
        border: TableBorder.all(color: Colors.black45),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Color(0xffE0D5F1),
            ),
            children: [
              _tableCellHeader(""""""),
              _tableCellHeader(""""""),
              _tableCellHeader("""Hora"""),
              _tableCellHeader("""Duración"""),
              _tableCellHeader("""Ansiedad (USAs)"""),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableResumeHeader2() {
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.06),
          1: FractionColumnWidth(.18),
          2: FractionColumnWidth(.13),
          3: FractionColumnWidth(.12),
          4: FractionColumnWidth(.13),
          5: FractionColumnWidth(.13),
          6: FractionColumnWidth(.11),
          7: FractionColumnWidth(.14)
        },
        border: TableBorder.all(color: Colors.black45),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Color(0xffE0D5F1)),
            children: [
              _tableCellHeader("""#"""),
              _tableCellHeader("""Día"""),
              _tableCellHeader("""Empieza"""),
              _tableCellHeader("""Acaba"""),
              _tableCellHeader("""Fijada"""),
              _tableCellHeader("""Real"""),
              _tableCellHeader("""Antes"""),
              _tableCellHeader("""Durante"""),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableResumeBody() {
    List<TableRow> rows = [];
    int index = 1;
    widget.exercise.exposures.forEach((exposure) {
      rows.add(TableRow(children: [
        _tableCell(index.toString()),
        _tableCell(dateFormatter.format(exposure.start.toDate())),
        _tableCell(timeFormatter.format(exposure.start.toDate())),
        _tableCell(timeFormatter.format(exposure.end.toDate())),
        _tableCell(getDurationString(exposure.presetDuration)),
        _tableCell(getDurationString(exposure.realDuration),
            color: exposure.realDuration >= exposure.presetDuration
                ? Colors.green
                : Colors.redAccent),
        _tableCell(exposure.usasBefore.toString()),
        _tableCell(exposure.usasAfter.toString(),
            color: exposure.usasAfter < exposure.usasBefore
                ? Colors.green
                : Colors.redAccent),
      ]));
      index++;
    });

    if (widget.exercise.exposures.isEmpty) {
      rows.add(
        TableRow(children: [
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
        ]),
      );
    }

    return Container(
      child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FractionColumnWidth(.06),
            1: FractionColumnWidth(.18),
            2: FractionColumnWidth(.13),
            3: FractionColumnWidth(.12),
            4: FractionColumnWidth(.13),
            5: FractionColumnWidth(.13),
            6: FractionColumnWidth(.11),
            7: FractionColumnWidth(.14)
          },
          border: TableBorder.all(color: Colors.black45),
          children: rows),
    );
  }

  Widget _tableCell(String content,
      {Color color = Colors.black87, TextAlign align = TextAlign.center}) {
    TextStyle style = Theme.of(context)
        .textTheme
        .bodyText1
        .apply(fontSizeFactor: .65, color: color);
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 2, bottom: 2),
        child: Text(
          content,
          textAlign: align,
          style: style,
        ),
      ),
    );
  }

  Widget _tableCellHeader(String content) {
    TextStyle headerStyle = Theme.of(context).textTheme.bodyText1.apply(
          fontSizeFactor: .65,
          fontWeightDelta: 2,
        );

    return TableCell(
      child: Center(
        child: Text(
          content,
          style: headerStyle,
        ),
      ),
    );
  }

  String _getPanicBeforeText(String value) {
    String text = '';
    switch (value) {
      case """ataque_ansiedad""":
        text = """-\tTener un ataque de ansiedad""";
        break;
      case """bloqueo""":
        text = """-\tBloquearme y no saber cómo reaccionar""";
        break;
      case """ataque_corazon""":
        text = """-\tTener un ataque al corazón""";
        break;
      case """desmayo""":
        text = """-\tDesmayarme""";
        break;
      case """ridiculo""":
        text = """-\tLlamar la atención o hacer el ridículo""";
        break;
      case """perder_control""":
        text = """-\tPerder el control del vehículo""";
        break;
      case """embarazosa""":
        text = """-\tSerá una situación embarazosa""";
        break;
    }

    return text;
  }

  String _getPanicAfterText(String value) {
    String text = '';
    switch (value) {
      case """ataque_corazon""":
        text = """-\tLatidos rápidos o fuertes del corazón""";
        break;
      case """sudor""":
        text = """-\tSudores""";
        break;
      case """falta_aire""":
        text = """-\tFalta de aire""";
        break;
      case """escalofrio""":
        text = """-\tEscalofríos""";
        break;
      case """mareo""":
        text = """-\tVértigos, mareos, inestabilidad""";
        break;
      case """perder_control""":
        text = """-\tMiedo a perder el control del vehículo""";
        break;
      case """pecho""":
        text = """-\tDolor o malestar en el pecho""";
        break;
      case """estomago""":
        text = """-\tVómitos o malestar en el estómago""";
        break;
    }

    return text;
  }

  Widget _buildTablePanic() {
    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(
          color: Color(0xffE0D5F1),
        ),
        children: [
          _tableCellHeader("""#"""),
          _tableCellHeader("""Temores"""),
          _tableCellHeader("""Sensaciones reales"""),
        ],
      ),
    ];
    int index = 1;
    widget.exercise.exposures.forEach((exposure) {
      String before = '';
      exposure.panicBefore.forEach((element) {
        before += _getPanicBeforeText(element) + """\n""";
      });
      if (before.isNotEmpty) {
        before = before.substring(0, before.length - 1);
      }

      String after = '';
      exposure.panicAfter.forEach((element) {
        after += _getPanicAfterText(element) + """\n""";
      });
      if (after.isNotEmpty) {
        after = after.substring(0, after.length - 1);
      }

      rows.add(TableRow(children: [
        _tableCell(index.toString()),
        _tableCell(before, align: TextAlign.left),
        _tableCell(after, align: TextAlign.left),
      ]));
      index++;
    });

    if (widget.exercise.exposures.isEmpty) {
      rows.add(
        TableRow(children: [
          _tableCell(""""""),
          _tableCell(""""""),
          _tableCell(""""""),
        ]),
      );
    }

    return Container(
      child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FractionColumnWidth(.06),
            1: FractionColumnWidth(.47),
            2: FractionColumnWidth(.47),
          },
          border: TableBorder.all(color: Colors.black45),
          children: rows),
    );
  }

  Widget _buildUSAsChart() {
    return Container(
      height: 200,
      child: USAsChart.withExerciseData(
          widget.exercise.exposures, widget.exercise.originalUsas),
    );
  }

  Widget _buildSelfEfficacyChart() {
    return Container(
      height: 200,
      child: SelfEfficacyChart.withExerciseData(widget.exercise.exposures),
    );
  }

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          Text(
            widget.exercise.itemStr,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.95),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),

          // Tabla de seguimiento
          _buildTitle("Historial de exposiciones", description: [
            """Esta información puede ser útil para plantearte el próximo 
            objetivo de tiempo basándote en tus ejercicios pasados. """
          ]),
          _buildTableResumeHeader1(),
          _buildTableResumeHeader2(),
          _buildTableResumeBody(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _buildTitle("""Evolución de la ansiedad antes y durante la 
          exposición""", description: [
            """Se utiliza una puntuación de 0 a 100 USAs, dónde el 0 representa 
            ausencia de ansiedad y el 100 una ansiedad extrema."""
          ]),
          _buildUSAsChart(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _buildTitle("""Evolución de las respuestas de autoeficacia""",
              description: [
                """La siguiente gráfica representa cómo de seguro estabas de 
                poder realizar el ejercicio justo antes de las diferentes 
                exposiciones.""",
                """Se utiliza una escala de 0 a 100 dónde 0 significa 
                "No puedo hacerlo" y 100 "Totalmente seguro de poder 
                hacerlo" """
              ]),
          _buildSelfEfficacyChart(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _buildTitle("Informe referido al pánico y sensaciones experimentadas",
              description: [
                """En esta tabla puedes comparar sensaciones que pensabas que 
                ibas a experimentar durante el ejercicio con las sensaciones 
                que realmente has experimentado."""
              ]),
          _buildTablePanic(),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, {List<String> description}) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.8, fontWeightDelta: 2),
            textAlign: TextAlign.justify,
          ),
          Visibility(
            visible: description != null && description.isNotEmpty,
            child: Column(
              children: description == null
                  ? []
                  : description
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            item,
                            textAlign: TextAlign.justify,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .apply(fontSizeFactor: 0.85),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("""Registro de exposición"""),
      ),
      //backgroundColor:  Color(0xffe8eaf6),
      body: _isLoading ? circularProgress(context) : _buildPage(context),
    );
  }
}
