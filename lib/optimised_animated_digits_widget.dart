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
    required this.differentDigitsColor,
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
  final bool differentDigitsColor;
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
  Color? digitsColor;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.milliseconds,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant OptimisedAnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    num tempOldValue = oldWidget.value;
    num tempNewValue = widget.value;
    if (tempNewValue != tempOldValue) {
      if (widget._digitsExtractor.mantissa <
          oldWidget._digitsExtractor.mantissa) {
        digitsColor = widget._negativeColor;
      } else if (widget._digitsExtractor.mantissa >
          oldWidget._digitsExtractor.mantissa) {
        digitsColor = widget._positiveColor;
      } else if (widget.differentDigitsColor) {
        digitsColor = null;
      } else {
        if (tempNewValue < tempOldValue) {
          digitsColor = widget._negativeColor;
        } else if (tempNewValue > tempOldValue) {
          digitsColor = widget._positiveColor;
        } else {
          digitsColor = widget._negativeColor;
        }
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
        digitsColor ?? widget._neutralColor,
        PlaceholderAlignment.baseline,
      );
    }
  }

  InlineSpan _singleCharInlineSpan(
    String char,
    Color color,
    PlaceholderAlignment placeHolderAlignment,
  ) {
    return WidgetSpan(
      child: Text(
        char,
        style: widget.textStyle.copyWith(
          color: color,
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

  InlineSpan _itemBuilder(String value) {
    if (value == '.') {
      return _getDecimalSpan();
    } else {
      PlaceholderAlignment alignment = PlaceholderAlignment.middle;
      if (widget._digitsExtractor.isFractional &&
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
          digitColor: digitsColor,
          negativeColor: widget._negativeColor,
          positiveColor: widget._positiveColor,
          neutralColor: widget._neutralColor,
          textStyle: widget.textStyle,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> widgetSpanFirst = [];
    int index = 0;
    if (widget._digitsExtractor.list.first == '-') {
      index = 1;
      PlaceholderAlignment signAlignment = PlaceholderAlignment.baseline;
      if (widget._digitsExtractor.isFractional &&
          widget.decimal == null &&
          widget.digitsSeparator == null) {
        signAlignment = PlaceholderAlignment.middle;
      }

      widgetSpanFirst.add(
        _singleCharInlineSpan(
          '-',
          digitsColor ?? widget._negativeColor,
          signAlignment,
        ),
      );
    }

    Widget? digitsSeparator = widget.digitsSeparator;
    int end = widget._digitsExtractor.list.length;

    if (digitsSeparator != null) {
      end = (end * 2) - 1;
      for (int i = index; i < end; i++) {
        int calculatedIndex = i ~/ 2;
        if (i.isEven) {
          widgetSpanFirst.add(
            _itemBuilder(widget._digitsExtractor.list[calculatedIndex]),
          );
        } else {
          widgetSpanFirst.add(_separatorInlineSpan(digitsSeparator));
        }
      }
    } else {
      for (int i = index; i < end; i++) {
        widgetSpanFirst.add(
          _itemBuilder(widget._digitsExtractor.list[i]),
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
