import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/pages/exercises/exercise_progress.dart';
import 'package:tfg_app/pages/exercises/exercise_running.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:tfg_app/widgets/buttons.dart';

class ExerciseDetails extends StatefulWidget {
  final Exercise exercise;

  ExerciseDetails(this.exercise);
  _ExerciseDetailsState createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  ScrollController _scrollController;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _start() async {
    // Obtener la duración de la exposición
    await showDialog(
      context: context,
      builder: (BuildContext context) => DurationDialog(widget.exercise),
    );
  }

  Widget _buildImage(BuildContext context) {
    Widget children;
    if (widget.exercise.image != null) {
      children = Container(
          width: double.maxFinite,
          child: CachedNetworkImage(
            imageUrl: widget.exercise.image,
            fit: BoxFit.cover,
          ),
          height: MediaQuery.of(context).size.height * 0.16);
    } else {
      children = Container(
          width: double.maxFinite,
          child: Image.asset(
            "assets/images/noimage.jpg",
            fit: BoxFit.cover,
          ),
          height: MediaQuery.of(context).size.height * 0.16);
    }

    return children;
  }

  double _getAppBarCollapsePercent() {
    if (!_scrollController.hasClients ||
        _scrollController.positions.length > 1) {
      return 0.0;
    }
    return (_scrollController.offset /
            (MediaQuery.of(context).size.height / 2.5 - kToolbarHeight))
        .clamp(0.0, 1.0);
  }

  bool get _changeColor {
    return (_getAppBarCollapsePercent() == 1);
  }

  Widget _buildAppBar() {
    Color primaryColor = Theme.of(context).primaryColor;

    return SliverAppBar(
      iconTheme: IconThemeData(
          color: _changeColor || widget.exercise.image == null
              ? primaryColor
              : Colors.white),
      backgroundColor: Colors.white,
      expandedHeight: MediaQuery.of(context).size.height / 2.5,
      actions: <Widget>[],
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _changeColor ? widget.exercise.itemCode : '',
          style: TextStyle(color: primaryColor),
        ),
        centerTitle: true,
        background: _buildImage(context),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child:
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(
          title + ":",
          style:
              Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2),
        ),
        SizedBox(
          width: 10,
        ),
        Flexible(
            child: Text(
          content,
          overflow: TextOverflow.fade,
        ))
      ]),
    );
  }

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.02),
      child: ListView(
        children: <Widget>[
          Text(
            widget.exercise.itemStr,
            style:
                Theme.of(context).textTheme.headline6.apply(fontSizeFactor: 1),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 5,
          ),
          _buildInfo(context, "Categoría",
              widget.exercise.levelCode + ". " + widget.exercise.levelStr),
          _buildInfo(context, "Situación", widget.exercise.situationStr),
          Visibility(
            visible: widget.exercise.variantStr != null,
            child: _buildInfo(
                context,
                "Variante",
                widget.exercise.variantStr != null
                    ? widget.exercise.variantStr
                    : ''),
          ),
          _buildInfo(
              context,
              "Ansiedad inicial",
              widget.exercise.originalUsas.toString() +
                  (widget.exercise.originalUsas == 0
                      ? 'USAs \t(Situación neutra)'
                      : ' USAs')),
          _buildInfo(context, "Duración", '¿?'),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.exercise.audio != null,
            child: Text(
              "Durante la realización de este ejercicio se reproducirá un clip de audio para mejorar la experiencia de exposición",
              style: TextStyle(color: Theme.of(context).primaryColorDark),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottonNavigationBar(BuildContext parentContext) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(
          left: width * 0.07, right: width * 0.07, bottom: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseProgress(widget.exercise),
                ),
              );
            },
            child: Text(
              "Progreso",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          primaryButton(context, _start, "Comenzar",
              width: MediaQuery.of(context).size.width * 0.45)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[_buildAppBar()];
        },
        body: new Container(child: _buildPage(context)),
      ),
      bottomNavigationBar: _bottonNavigationBar(context),
    );
  }
}

class DurationDialog extends StatefulWidget {
  final Exercise exercise;
  DurationDialog(this.exercise);
  _DurationDialogState createState() => _DurationDialogState();
}

/// Custom Dialog for select a duration
class _DurationDialogState extends State<DurationDialog> {
  Duration _duration = Duration(hours: 0, minutes: 0);
  Widget _dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        16.0,
      ),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Text("Duración de la exposición",
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 16.0),
          Text("description",
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyText2),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          DurationPicker(
            duration: _duration,
            onChange: (val) {
              this.setState(() => _duration = val);
            },
            snapToMins: 1,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              SizedBox(
                width: 40,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExerciseRunningPage(widget.exercise, _duration),
                    ),
                  );
                },
                child: Text(
                  "Continuar",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }
}
