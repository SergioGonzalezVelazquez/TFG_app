import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/widgets/progress.dart';

class ExerciseProgress extends StatefulWidget {
  final Exercise exercise;

  ExerciseProgress(this.exercise);
  _ExerciseProgressState createState() => _ExerciseProgressState();
}

class _ExerciseProgressState extends State<ExerciseProgress> {
  bool _isLoading = false;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildHeader1() {
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.22),
          1: FractionColumnWidth(.3),
          2: FractionColumnWidth(.16),
          3: FractionColumnWidth(.32),
        },
        border: TableBorder.all(color: Colors.black45),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: new Color(0xffE0D5F1),
            ),
            children: [
              _tableCellHeader(""),
              _tableCellHeader("Hora"),
              _tableCellHeader(""),
              _tableCellHeader("Ansiedad (USAs)"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader2() {
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.22),
          1: FractionColumnWidth(.15),
          2: FractionColumnWidth(.15),
          3: FractionColumnWidth(.16),
          4: FractionColumnWidth(.16),
          5: FractionColumnWidth(.16)
        },
        border: TableBorder.all(color: Colors.black45),
        children: [
          TableRow(
              decoration: BoxDecoration(color: new Color(0xffE0D5F1)),
              children: [
                _tableCellHeader("Día"),
                _tableCellHeader("Empieza"),
                _tableCellHeader("Acaba"),
                _tableCellHeader("Duración"),
                _tableCellHeader("Antes"),
                _tableCellHeader("Después"),
              ]),
        ],
      ),
    );
  }

  Widget _buildTableBody() {
    return Container(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(.22),
          1: FractionColumnWidth(.15),
          2: FractionColumnWidth(.15),
          3: FractionColumnWidth(.16),
          4: FractionColumnWidth(.16),
          5: FractionColumnWidth(.16)
        },
        border: TableBorder.all(color: Colors.black45),
        children: [
          TableRow(children: [
            _tableCell("20-05-2020"),
            _tableCell("10:41"),
            _tableCell("11:32"),
            _tableCell("20"),
            _tableCell("70"),
            _tableCell("100"),
          ]),
          TableRow(children: [
            _tableCell("20-05-2020"),
            _tableCell("10:41"),
            _tableCell("11:32"),
            _tableCell("20"),
            _tableCell("70"),
            _tableCell("100"),
          ]),
          TableRow(children: [
            _tableCell("20-05-2020"),
            _tableCell("10:41"),
            _tableCell("11:32"),
            _tableCell("20"),
            _tableCell("70"),
            _tableCell("100"),
          ]),
          TableRow(children: [
            _tableCell(""),
            _tableCell(""),
            _tableCell(""),
            _tableCell(""),
            _tableCell(""),
            _tableCell(""),
          ]),
        ],
      ),
    );
  }

  Widget _tableCell(String content) {
    TextStyle style =
        Theme.of(context).textTheme.bodyText1.apply(fontSizeFactor: .75);
    return TableCell(
      child: Center(
        child: Text(
          content,
          style: style,
        ),
      ),
    );
  }

  Widget _tableCellHeader(String content) {
    TextStyle headerStyle = Theme.of(context).textTheme.bodyText1.apply(
          fontSizeFactor: .75,
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

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            widget.exercise.itemStr,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.95),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _buildHeader1(),
          _buildHeader2(),
          _buildTableBody(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.005,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro de exposición"),
      ),
      //backgroundColor:  Color(0xffe8eaf6),
      body: _isLoading ? circularProgress(context) : _buildPage(context),
    );
  }
}
