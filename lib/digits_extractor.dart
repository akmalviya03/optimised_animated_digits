class DigitsExtractor {
  String _value;
  late num mantissa;

  late List<String> _list;

  List<String> get list => _list;

  DigitsExtractor({required num numericValue}) : _value = "$numericValue" {
    _checkAndAssignValueToList();
  }

  void _containsDecimal(String value) {
    _isFractional = value.contains('.');
  }

  bool _isFractional = false;

  bool get isFractional => _isFractional;

  void _checkAndAssignValueToList() {
    _containsDecimal(_value);
    if (isFractional) {
      List<String> tempList = _value.split('.');

      String last = tempList.last;

      if (last.length > 2) {
        last = last.substring(0, 2);
      } else {
        last.padRight(2, '0');
      }
      mantissa = num.parse(tempList.first);
      _list = [...tempList.first.split(''), '.', ...last.split('')];
    } else {
      mantissa = num.parse(_value);
      _list = _value.split('');
    }
  }

  void updateWith({required num value}) {
    _value = "$value";
    _checkAndAssignValueToList();
  }
}
