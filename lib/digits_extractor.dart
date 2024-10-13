class DigitsExtractor {
  String _value;

  late List<String> _list;

  int _firstUnMatchedIndex = 0;

  int get firstMatchedIndex => _firstUnMatchedIndex;
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
      _list = [...tempList.first.split(''), '.', ...last.split('')];
    } else {
      _list = _value.split('');
    }
  }

  void calculateFirstUnMatchedIndex(List<String> list){
    if (_list.length < list.length || _list.length  > list.length) {
      _firstUnMatchedIndex = 0;
    }else{
      for(int i =0 ; i< _list.length ; i++){
        if(_list[i] != list[i]){
          _firstUnMatchedIndex = i;
          break;
        }
      }
    }
  }

  void updateWith({required num value}) {
    _value = "$value";
    _checkAndAssignValueToList();
  }
}
