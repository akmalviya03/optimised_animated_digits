import 'package:flutter/material.dart';
import 'package:optimised_animated_digits/digits_extractor.dart';

part 'single_sequence.dart';

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
    _digitsExtractor = DigitsExtractor(numericValue: value);
  }
  final num value;
  late final Color _negativeColor;
  late final Color _positiveColor;
  late final Color _neutralColor;
  final TextStyle textStyle;
  final int milliseconds;
  final Widget? decimal;
  final Widget? digitsSeparator;
  late final DigitsExtractor _digitsExtractor;
  @override
  State<OptimisedAnimatedDigit> createState() => _OptimisedAnimatedDigitState();
}

class _OptimisedAnimatedDigitState extends State<OptimisedAnimatedDigit>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Color digitsColor;
  late DigitsExtractor digitsExtractor;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.milliseconds,
      ),
    );
    digitsExtractor = widget._digitsExtractor;
    digitsColor = widget._neutralColor;
  }

  @override
  void didUpdateWidget(covariant OptimisedAnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    digitsExtractor = widget._digitsExtractor;
    num tempOldValue = oldWidget.value;
    num tempNewValue = widget.value;
    if (tempNewValue != tempOldValue) {
      digitsExtractor
          .calculateFirstUnMatchedIndex(oldWidget._digitsExtractor.list);
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

  InlineSpan _getDecimalSpan() {
    Widget? decimal = widget.decimal;
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

  InlineSpan _itemBuilder(String value, Color digitColor) {
    if (value == '.') {
      return _getDecimalSpan();
    } else {
      PlaceholderAlignment alignment = PlaceholderAlignment.middle;
      if (digitsExtractor.isFractional &&
          widget.decimal == null &&
          widget.digitsSeparator == null) {
        alignment = PlaceholderAlignment.baseline;
      }
      return WidgetSpan(
        baseline: TextBaseline.alphabetic,
        alignment: alignment,
        child: _SingleSequence(
          value: value,
          animation: animationController.view,
          digitColor: digitColor,
          textStyle: widget.textStyle,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> widgetSpanFirst = [];
    int index = 0;
    if (digitsExtractor.list.first == '-') {
      index = 1;
      PlaceholderAlignment signAlignment = PlaceholderAlignment.baseline;
      if (digitsExtractor.isFractional &&
          widget.decimal == null &&
          widget.digitsSeparator == null) {
        signAlignment = PlaceholderAlignment.middle;
      }

      widgetSpanFirst.add(
        _singleCharInlineSpan(
          '-',
          signAlignment,
        ),
      );
    }

    Widget? digitsSeparator = widget.digitsSeparator;
    int end = digitsExtractor.list.length;

    if (digitsSeparator != null) {
      end = (end * 2) - 1;
      for (int i = index; i < end; i++) {
        int calculatedIndex = i ~/ 2;
        if (i.isEven) {
          widgetSpanFirst.add(
            _itemBuilder(
              digitsExtractor.list[calculatedIndex],
              calculatedIndex >= digitsExtractor.firstMatchedIndex
                  ? digitsColor
                  : widget._neutralColor,
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
            digitsExtractor.list[i],
            i >= digitsExtractor.firstMatchedIndex
                ? digitsColor
                : widget._neutralColor,
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
