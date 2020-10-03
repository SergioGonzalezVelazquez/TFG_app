class Situation implements Comparable {
  final String itemCode;
  final String itemStr;

  int usas;

  /// Default class constructor
  Situation({this.itemCode, this.itemStr, this.usas});

  /// Converts Firestore Document into a Situation object
  factory Situation.fromMap(Map<String, dynamic> map) {
    return Situation(
      itemCode: map['itemCode'],
      itemStr: map['itemStr'],
      usas: map['usas'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['itemCode'] = itemCode;
    map['itemStr'] = itemStr;
    map['usas'] = usas;

    return map;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'itemCode: $itemCode, itemStr: $itemStr';
  }

  @override
  int compareTo(dynamic other) {
    if (usas == null || other == null || other.usas == null) {
      return -1;
    }
    if (usas == other.usas) {
      return 0;
    }
    if (usas < other.usas) {
      return -1;
    }

    if (usas > other.usas) {
      return 1;
    }
    return 0;
  }
}
