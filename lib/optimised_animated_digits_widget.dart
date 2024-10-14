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
  final TransformerHistoryValueNotifier<num, List<String>> valueNotifier;
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
      return _getDecimalSpan(decimal, digitColor);
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
    return TransformerHistoryValueListenableBuilder<num, List<String>>(
      transformerHistoryValueNotifier: widget.valueNotifier,
      transformerHistoryValueBuilder: (BuildContext context,
          num? nullablePrevValue,
          List<String>? nullablePrevDigitsList,
          num value,
          List<String> digitsList,
          Widget? child) {
        Color digitColor = widget._neutralColor;
        int index = 0;
        List<InlineSpan> inlineSpansList = [];
        Widget? digitsSeparator = widget.digitsSeparator;
        Widget? decimal = widget.decimal;
        bool isFractional = containsDecimal(value);
        if (digitsList.first == '-') {
          index = 1;
          PlaceholderAlignment signAlignment = PlaceholderAlignment.baseline;
          if (isFractional && decimal == null && digitsSeparator == null) {
            signAlignment = PlaceholderAlignment.middle;
          }

          inlineSpansList.add(
            _singleCharInlineSpan('-', signAlignment, digitColor),
          );
        }

        num? canBeNullAblePrevValue = nullablePrevValue;
        List<String>? canBeNullablePrevDigitsList = nullablePrevDigitsList;

        int end = digitsList.length;

        if (canBeNullAblePrevValue != null &&
            canBeNullablePrevDigitsList != null) {
          ///Select Digits Color
          if (value < canBeNullAblePrevValue) {
            digitColor = widget._negativeColor;
          } else if (value > canBeNullAblePrevValue) {
            digitColor = widget._positiveColor;
          } else {
            digitColor = widget._neutralColor;
          }

          int unMatchedIndex = calculateFirstUnMatchedIndex(
              currentList: canBeNullablePrevDigitsList, oldList: digitsList);

          if (digitsSeparator != null) {
            end = (end * 2) - 1;
            for (int i = index; i < end; i++) {
              int calculatedIndex = i ~/ 2;
              if (i.isEven) {
                inlineSpansList.add(
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
                inlineSpansList.add(_separatorInlineSpan(digitsSeparator));
              }
            }
          } else {
            for (int i = index; i < end; i++) {
              inlineSpansList.add(
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
        } else {
          for (int i = index; i < end; i++) {
            inlineSpansList.add(
              _itemBuilder(
                digitsList[i],
                digitColor,
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
            children: inlineSpansList,
          ),
        );
      },
    );
  }
}
