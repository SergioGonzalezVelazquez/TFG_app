import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/pages/exercises/exercise_in_progress.dart';
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

  void _start() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseInProgressPage(widget.exercise),
      ),
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
                      ? '\t(Situación neutra)'
                      : '')),
          _buildInfo(context, "Duración", '¿?'),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.exercise.audio == null,
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
              Navigator.pop(context);
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
