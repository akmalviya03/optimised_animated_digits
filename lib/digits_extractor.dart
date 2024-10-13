class StartColourIndex {
  List<String>? _oldList;

  StartColourIndex();

  void updateOldDigitsList(List<String> oldList) {
    _oldList = oldList;
  }

  int calculateFirstUnMatchedIndex(List<String> currentList) {
    List<String>? oldList = _oldList;
    if (oldList != null) {
      if (currentList.length < oldList.length ||
          currentList.length > oldList.length) {
        return 0;
      } else {
        for (int i = 0; i < oldList.length; i++) {
          if (currentList[i] != oldList[i]) {
            return i;
          }
        }
      }
    }
    return 0;
  }
}

bool containsDecimal(num value) {
  return value is! int;
}

List<String> generateDigits(num value) {
  bool isFractional = containsDecimal(value);
  String stringValue = "$value";
  if (isFractional) {
    List<String> tempList = stringValue.split('.');

    String exponent = tempList[1];
    String mantissa = tempList[0];
    int mantissaLength = mantissa.length;

    List<String> characters = <String>[];

    for(int i=0; i<mantissaLength ; i++){
      characters.add(mantissa[i]);
    }
    characters.add('.');

    if (exponent.length >= 2) {
      exponent = exponent.substring(0, 2);

    } else {
      exponent = exponent.padRight(2, '0');
    }

    for(int i=0; i<exponent.length ; i++){
      characters.add(exponent[i]);
    }

    return characters;
  } else {
    return stringValue.split('');
  }
}
