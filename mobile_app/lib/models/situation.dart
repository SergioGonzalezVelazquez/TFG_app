class Situation implements Comparable {
  final String itemCode;
  final String itemStr;
  final String situationCode;
  final String situationStr;
  final String levelStr;
  final String levelCode;
  int usas;

  /// Default class constructor
  Situation(
      {this.itemCode,
      this.itemStr,
      this.situationCode,
      this.situationStr,
      this.levelStr,
      this.levelCode});

  /// Converts Firestore Document into a Situation object
  factory Situation.fromMap(Map<String, dynamic> map) {
    return Situation(
        itemCode: map['itemCode'],
        itemStr: map['itemStr'],
        situationCode: map['situationCode'],
        situationStr: map['situationStr'],
        levelCode: map['levelCode'],
        levelStr: map['levelStr']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    map['itemCode'] = itemCode;
    map['itemStr'] = itemStr;
    map['situationCode'] = situationCode;
    map['situationStr'] = situationStr;
    map['levelCode'] = levelCode;
    map['levelStr'] = levelStr;
    map['usas'] = usas;

    return map;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'itemCode: $itemCode, itemStr: $itemStr, situationCode: $situationCode, situationStr: $situationStr';
  }

  @override
  int compareTo(other) {
    if (this.usas == null || other == null || other.usas == null) {
      return -1;
    }
    if (this.usas == other.usas) {
      return 0;
    }
    if (this.usas < other.usas) {
      return -1;
    }

    if (this.usas > other.usas) {
      return 1;
    }
    return 0;
  }
}
