import 'package:advanced_value_notifier/advanced_value_notifier.dart';
import 'package:flutter/material.dart';
import 'package:optimised_animated_digits/digits_extractor.dart';

part 'single_sequence.dart';

class OptimisedAnimatedDigit extends StatefulWidget {
  OptimisedAnimatedDigit({
    super.key,
    required this.valueNotifier,
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
  }
  final HistoryValueNotifier<num> valueNotifier;
  late final Color _negativeColor;
  late final Color _positiveColor;
  late final Color _neutralColor;
  final TextStyle textStyle;
  final int milliseconds;
  final Widget? decimal;
  final Widget? digitsSeparator;

  @override
  State<OptimisedAnimatedDigit> createState() => _OptimisedAnimatedDigitState();
}

class _OptimisedAnimatedDigitState extends State<OptimisedAnimatedDigit>
    with TickerProviderStateMixin {
  late final AnimationController animationController;

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

  InlineSpan _getDecimalSpan(Widget? decimal, Color digitsColor) {
    if (decimal != null) {
      return _separatorInlineSpan(decimal);
    } else {
      return _singleCharInlineSpan(
          '.', PlaceholderAlignment.baseline, digitsColor);
    }
  }

  InlineSpan _singleCharInlineSpan(String char,
      PlaceholderAlignment placeHolderAlignment, Color digitsColor) {
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
      return _getDecimalSpan(decimal,digitColor);
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
    return HistoryValueListenableBuilder<num>(
      historyValueNotifier: widget.valueNotifier,
      historyValueBuilder: (BuildContext context, num prevValue, num value, Widget? child) {
        ///Select Digits Color
        Color digitColor = widget._neutralColor;
        if (value < prevValue) {
          digitColor = widget._negativeColor;
        } else if (value > prevValue) {
          digitColor = widget._positiveColor;
        } else {
          digitColor = widget._neutralColor;
        }

        List<String> prevDigitsList = generateDigits(prevValue);
        List<String> digitsList = generateDigits(value);
        int unMatchedIndex = calculateFirstUnMatchedIndex(currentList: digitsList, oldList: prevDigitsList);
        bool isFractional = containsDecimal(value);
        Widget? digitsSeparator = widget.digitsSeparator;
        Widget? decimal = widget.decimal;
        List<InlineSpan> widgetSpanFirst = [];
        int index = 0;
        if (digitsList.first == '-') {
          index = 1;
          PlaceholderAlignment signAlignment = PlaceholderAlignment.baseline;
          if (isFractional &&
              widget.decimal == null &&
              digitsSeparator == null) {
            signAlignment = PlaceholderAlignment.middle;
          }

          widgetSpanFirst.add(
            _singleCharInlineSpan('-', signAlignment, digitColor),
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
                      ? digitColor
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
                i >= unMatchedIndex ? digitColor : widget._neutralColor,
                isFractional,
                digitsSeparator,
                decimal,
              ),
            );
          }
        }

        animationController.forward(from: 0);

        return Text.rich(
          TextSpan(
            children: widgetSpanFirst,
          ),
        );
      },
    );
  }
}
