import 'package:flutter/material.dart';
import 'package:tfg_app/models/situation.dart';
import 'package:tfg_app/models/therapy.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/widgets/stress_slider_dialog.dart';

class HierarchyPage extends StatefulWidget {
  static const routeEditable = "/buildHierarchy";
  static const routeNoEditable = "/viewHierarchy";

  final bool editable;
  HierarchyPage(this.editable);

  @override
  _HierarchyPageState createState() => _HierarchyPageState();
}

class _HierarchyPageState extends State<HierarchyPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool _isLoading = true;
  bool _isCompleted = false;
  AuthService _authService;
  List<Situation> _situations = [];
  Therapy _therapy;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _initializeList();
  }

  Future<void> _initializeList() async {
    setState(() {
      _isLoading = true;
    });
    _therapy = _authService.user.patient.currentTherapy;
    print(widget.editable);
    if (widget.editable) {
      Situation neutral = _therapy.neutral;
      neutral.usas = 0;
      _situations.add(neutral);

      Situation anxiety = _therapy.anxiety;
      anxiety.usas = 100;
      _situations.add(anxiety);
    }
    _situations = _situations + _therapy.situations;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });

    await setHierarchy(_situations);

    setState(() {
      _isLoading = false;
    });
  }

  int _newItemIndex(Situation situation) {
    for (int i = 0; i < _situations.length; i++) {
      if (_situations[i].usas == null)
        return i;
      else if (_situations[i].usas > situation.usas) return i;
    }
    return _situations.length + 1;
  }

  bool checkIsCompleted() {
    return !_situations.any((element) => element.usas == null);
  }

  void _onItemChanged(String itemCode) {
    print("onItem changed " + itemCode);
    int index =
        _situations.indexWhere((element) => element.itemCode == itemCode);
    Situation updated = _situations[index];

    _situations.remove(updated);

    // Remove item from list
    _listKey.currentState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) =>
          _buildItem(context, index, animation),
      duration: const Duration(milliseconds: 250),
    );

    // Insert item at new index
    int newIndex = _newItemIndex(updated);
    _situations.insert(newIndex, updated);
    _listKey.currentState.insertItem(newIndex);

    if (!_isCompleted) {
      if (checkIsCompleted()) {
        setState(() {
          _isCompleted = true;
        });
      }
    }
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: new SituationItem(
        key: ObjectKey(_situations[index]),
        editable: widget.editable,
        situation: _situations[index],
        isNeutral: index == 0,
        isAnxiety: _situations[index].itemCode == _therapy.anxiety.itemCode,
        onChanged: _onItemChanged,
      ),
    );
  }

  Widget _buildPage() {
    return new AnimatedList(
      key: _listKey,
      initialItemCount: _situations.length,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        return _buildItem(context, index, animation);
      },
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text:
                  'Ordena las situaciones temidas en función de una puntuación de 0 a 100 ',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(fontSizeFactor: 0.75),
              children: <TextSpan>[
                TextSpan(
                  text: 'USAs ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .apply(fontSizeFactor: 0.75, fontWeightDelta: 2),
                ),
                TextSpan(text: '(Unidades subjetivas de ansiedad). \n'),
                TextSpan(
                    text:
                        'El 0 representa ausencia de ansiedad y el 100 una ansiedad extrema.')
              ],
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.editable
          ? AppBar(
              title: Text("Jerarquía"),
              bottom: PreferredSize(
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.height * 0.09),
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white),
                  child: _buildInfo(),
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: _isCompleted
                      ? () async {
                          await _save();
                          Navigator.pop(context);
                        }
                      : null,
                  textColor: Theme.of(context).primaryColorLight,
                  child: Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            )
          : AppBar(
              title: Text("Jerarquía"),
            ),
      body: _isLoading ? circularProgress(context) : _buildPage(),
    );
  }
}

class SituationItem extends StatefulWidget {
  final bool editable;
  final Situation situation;
  final bool isNeutral;
  final bool isAnxiety;
  final Function onChanged;

  SituationItem({
    Key key,
    this.editable,
    this.situation,
    this.isNeutral,
    this.isAnxiety,
    this.onChanged,
  }) : super(key: key);

  ///Creates a StatelessElement to manage this widget's location in the tree.
  @override
  _SituationItemState createState() => _SituationItemState();
}

class _SituationItemState extends State<SituationItem> {
  Situation _situation;

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    _situation = widget.situation;
    super.initState();
  }

  Future<void> _onItemTap(BuildContext context) async {
    double usas = await showDialog(
      context: context,
      builder: (BuildContext context) => StressSliderDialog(
          max: 100,
          valuesNotAllowed: [0, 100],
          current: _situation.usas == null ? 0.0 : _situation.usas.toDouble(),
          text: _situation.itemStr),
    );

    if (usas >= 0) {
      setState(() {
        _situation.usas = usas.toInt();
      });
      widget.onChanged(_situation.itemCode);
    }
  }

  BoxDecoration _border(BuildContext context) {
    return new BoxDecoration(
        border: Border(
          top: widget.isNeutral
              ? Divider.createBorderSide(context)
              : BorderSide.none,
          bottom: widget.isAnxiety
              ? BorderSide.none
              : Divider.createBorderSide(context),
        ),
        color: Colors.white);
  }

  Widget _buildUSAsZone(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 18.0, left: 18.0, top: 5, bottom: 5),
      width: MediaQuery.of(context).size.width * 0.20,
      color: Color(0x08000000),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "USAs",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(fontSizeFactor: 0.6, fontWeightDelta: 2),
          ),
          SizedBox(
            height: 5,
          ),
          Text(_situation.usas == null ? '-' : _situation.usas.toString(),
              style: widget.isNeutral || widget.isAnxiety || !widget.editable
                  ? Theme.of(context).textTheme.bodyText2
                  : Theme.of(context).textTheme.bodyText1),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return InkWell(
      onTap: widget.isNeutral || widget.isAnxiety || !widget.editable
          ? null
          : () async {
              _onItemTap(context);
            },
      child: Container(
        decoration: _border(context),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
                  child: !widget.isNeutral && !widget.isAnxiety
                      ? Text(_situation.itemStr)
                      : RichText(
                          text: TextSpan(
                            text: _situation.itemStr + ' ',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: '\n(' +
                                    (widget.isNeutral
                                        ? 'Situación que no provoca ansiedad'
                                        : 'Situación de mayor ansiedad') +
                                    ')',
                                style: DefaultTextStyle.of(context).style.apply(
                                    fontWeightDelta: 2, fontSizeFactor: 0.8),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              _buildUSAsZone(context)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildItem(context);
  }
}
