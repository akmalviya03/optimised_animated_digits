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
  final ValueNotifier<num> valueNotifier;
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
  late AnimationController animationController;
  late TransformerHistoryValueNotifier<num, List<String>>
      transformerHistoryValueNotifier;
  @override
  void initState() {
    super.initState();
    widget.valueNotifier.addListener(listenToValue);
    transformerHistoryValueNotifier = TransformerHistoryValueNotifier(
      value: widget.valueNotifier.value,
      transformer: generateDigits,
    );
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.milliseconds,
      ),
    );
  }

  void listenToValue() {
    transformerHistoryValueNotifier.value = widget.valueNotifier.value;
  }

  @override
  void didUpdateWidget(OptimisedAnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    transformerHistoryValueNotifier.dispose();
    transformerHistoryValueNotifier = TransformerHistoryValueNotifier(
      value: widget.valueNotifier.value,
      transformer: generateDigits,
    );
    if (widget.milliseconds != oldWidget.milliseconds) {
      animationController.dispose();
      animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.milliseconds,
        ),
      );
    }

    oldWidget.valueNotifier.removeListener(listenToValue);
    widget.valueNotifier.addListener(listenToValue);
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.valueNotifier.removeListener(listenToValue);
    transformerHistoryValueNotifier.dispose();
    super.dispose();
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

  List<InlineSpan> _buildDigitSpans({
    required List<String> digitsList,
    required Color digitColor,
    required bool isFractional,
    required Widget? digitsSeparator,
    required Widget? decimal,
    required int startIndex,
    int? unMatchedIndex,
  }) {
    final List<InlineSpan> inlineSpansList = [];
    final int end = digitsSeparator != null
        ? (digitsList.length * 2) - 1
        : digitsList.length;

    if (digitsSeparator != null) {
      for (int i = startIndex; i < end; i++) {
        final int calculatedIndex = i ~/ 2;
        if (i.isEven) {
          final Color itemColor =
              unMatchedIndex != null && calculatedIndex >= unMatchedIndex
                  ? digitColor
                  : widget._neutralColor;
          inlineSpansList.add(
            _itemBuilder(
              digitsList[calculatedIndex],
              itemColor,
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
      for (int i = startIndex; i < end; i++) {
        final Color itemColor = unMatchedIndex != null && i >= unMatchedIndex
            ? digitColor
            : widget._neutralColor;
        inlineSpansList.add(
          _itemBuilder(
            digitsList[i],
            itemColor,
            isFractional,
            digitsSeparator,
            decimal,
          ),
        );
      }
    }

    return inlineSpansList;
  }

  @override
  Widget build(BuildContext context) {
    return TransformerHistoryValueListenableBuilder<num, List<String>>(
      transformerHistoryValueListenable: transformerHistoryValueNotifier,
      transformerHistoryValueBuilder: (context, previousValue,
          previousDigitsList, currentValue, digitsList, child) {
        {
          Color digitColor = widget._neutralColor;
          int startIndex = 0;
          List<InlineSpan> digitsSpan = [];
          final bool isFractional = containsDecimal(currentValue);

          if (digitsList.first == '-') {
            startIndex = 1;
            final PlaceholderAlignment signAlignment = isFractional &&
                    widget.decimal == null &&
                    widget.digitsSeparator == null
                ? PlaceholderAlignment.middle
                : PlaceholderAlignment.baseline;

            digitsSpan
                .add(_singleCharInlineSpan('-', signAlignment, digitColor));
          }

          int? unMatchedIndex;
          if (previousValue != null && previousDigitsList != null) {
            if (currentValue < previousValue) {
              digitColor = widget._negativeColor;
            } else if (currentValue > previousValue) {
              digitColor = widget._positiveColor;
            }

            unMatchedIndex = calculateFirstUnMatchedIndex(
              currentList: previousDigitsList,
              oldList: digitsList,
            );
          }

          animationController.forward(from: 0);
          digitsSpan.addAll(_buildDigitSpans(
            digitsList: digitsList,
            digitColor: digitColor,
            isFractional: isFractional,
            digitsSeparator: widget.digitsSeparator,
            decimal: widget.decimal,
            startIndex: startIndex,
            unMatchedIndex: unMatchedIndex,
          ));

          return Text.rich(
            TextSpan(
              children: digitsSpan,
            ),
          );
        }
      },
    );
  }
}
