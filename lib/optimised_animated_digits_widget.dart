import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:optimised_animated_digits/digits_extractor.dart';

part 'single_sequence.dart';


class PrevValueHolderNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Creates a [ChangeNotifier] that wraps this value.
  PrevValueHolderNotifier(this._value):_prevValue = _value {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  T get value => _value;
  T _value;

  T _prevValue;
  T get prevValue => _prevValue;

  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _prevValue = value;
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($prevValue)($value)';
}

class OptimisedAnimatedDigit extends StatefulWidget {
  OptimisedAnimatedDigit({
    super.key,
    required this.value,
    Color? negativeColor,
    Color? positiveColor,
    Color? neutralColor,
    required this.textStyle,
    required this.milliseconds,
    this.decimal,
    this.digitsSeparator,
  }) {
    assert(milliseconds >= 100,
        "milliseconds should be greater or equal to 100 for smooth animation");
    _negativeColor = negativeColor ?? Colors.black;
    _positiveColor = positiveColor ?? Colors.black;
    _neutralColor = neutralColor ?? Colors.black;
    _digits = generateDigits(value);
  }
  final num value;
  late final Color _negativeColor;
  late final Color _positiveColor;
  late final Color _neutralColor;
  final TextStyle textStyle;
  final int milliseconds;
  final Widget? decimal;
  final Widget? digitsSeparator;
  late final List<String> _digits;
  @override
  State<OptimisedAnimatedDigit> createState() => _OptimisedAnimatedDigitState();
}

class _OptimisedAnimatedDigitState extends State<OptimisedAnimatedDigit>
    with TickerProviderStateMixin {
  late final AnimationController animationController;
  late Color digitsColor;
  final StartColourIndex startColorIndex = StartColourIndex();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.milliseconds,
      ),
    );
    digitsColor = widget._neutralColor;
  }

  @override
  void didUpdateWidget(covariant OptimisedAnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    num tempOldValue = oldWidget.value;
    num tempNewValue = widget.value;
    if (tempNewValue != tempOldValue) {
      startColorIndex.updateOldDigitsList(oldWidget._digits);
      if (tempNewValue < tempOldValue) {
        digitsColor = widget._negativeColor;
      } else if (tempNewValue > tempOldValue) {
        digitsColor = widget._positiveColor;
      } else {
        digitsColor = widget._negativeColor;
      }
      animationController.forward(from: 0);
    }
  }

  InlineSpan _getDecimalSpan(Widget? decimal) {
    if (decimal != null) {
      return _separatorInlineSpan(decimal);
    } else {
      return _singleCharInlineSpan(
        '.',
        PlaceholderAlignment.baseline,
      );
    }
  }

  InlineSpan _singleCharInlineSpan(
    String char,
    PlaceholderAlignment placeHolderAlignment,
  ) {
    return WidgetSpan(
      child: Text(
        char,
        style: widget.textStyle.copyWith(
          color: digitsColor,
        ),
      ),
      baseline: TextBaseline.alphabetic,
      alignment: placeHolderAlignment,
    );
  }

  InlineSpan _separatorInlineSpan(Widget widget) {
    return WidgetSpan(
      child: widget,
      baseline: TextBaseline.alphabetic,
      alignment: PlaceholderAlignment.middle,
    );
  }

  InlineSpan _itemBuilder(
    String value,
    Color digitColor,
    bool isFractional,
    Widget? digitsSeparator,
    Widget? decimal,
  ) {
    if (value == '.') {
      return _getDecimalSpan(decimal);
    } else {
      PlaceholderAlignment alignment = PlaceholderAlignment.middle;
      if (isFractional && decimal == null && digitsSeparator == null) {
        alignment = PlaceholderAlignment.baseline;
      }
      return WidgetSpan(
        baseline: TextBaseline.alphabetic,
        alignment: alignment,
        child: _SingleSequence(
          value: num.parse(value),
          animation: animationController.view,
          digitColor: digitColor,
          textStyle: widget.textStyle,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> digitsList = widget._digits;
    int unMatchedIndex =
        startColorIndex.calculateFirstUnMatchedIndex(widget._digits);
    bool isFractional = containsDecimal(widget.value);
    Widget? digitsSeparator = widget.digitsSeparator;
    Widget? decimal = widget.decimal;
    List<InlineSpan> widgetSpanFirst = [];
    int index = 0;
    if (digitsList.first == '-') {
      index = 1;
      PlaceholderAlignment signAlignment = PlaceholderAlignment.baseline;
      if (isFractional && widget.decimal == null && digitsSeparator == null) {
        signAlignment = PlaceholderAlignment.middle;
      }

      widgetSpanFirst.add(
        _singleCharInlineSpan(
          '-',
          signAlignment,
        ),
      );
    }

    int end = digitsList.length;

    if (digitsSeparator != null) {
      end = (end * 2) - 1;
      for (int i = index; i < end; i++) {
        int calculatedIndex = i ~/ 2;
        if (i.isEven) {
          widgetSpanFirst.add(
            _itemBuilder(
              digitsList[calculatedIndex],
              calculatedIndex >= unMatchedIndex
                  ? digitsColor
                  : widget._neutralColor,
              isFractional,
              digitsSeparator,
              decimal,
            ),
          );
        } else {
          widgetSpanFirst.add(_separatorInlineSpan(digitsSeparator));
        }
      }
    } else {
      for (int i = index; i < end; i++) {
        widgetSpanFirst.add(
          _itemBuilder(
            digitsList[i],
            i >= unMatchedIndex ? digitsColor : widget._neutralColor,
            isFractional,
            digitsSeparator,
            decimal,
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(
        children: widgetSpanFirst,
      ),
    );
  }
}
