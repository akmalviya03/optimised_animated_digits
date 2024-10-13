part of 'optimised_animated_digits_widget.dart';

class _SingleSequence extends StatefulWidget {
  const _SingleSequence({
    required this.value,
    required this.animation,
    this.digitColor,
    required this.negativeColor,
    required this.positiveColor,
    required this.neutralColor,
    required this.textStyle,
  });
  final String value;
  final Animation<double> animation;
  final Color? digitColor;
  final Color negativeColor;
  final Color positiveColor;
  final Color neutralColor;
  final TextStyle textStyle;
  @override
  State<_SingleSequence> createState() => _SingleSequenceState();
}

class _SingleSequenceState extends State<_SingleSequence> {
  late Animation<double> _animation;
  num _oldValue = 0;
  num _newValue = 0;
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _animation = widget.animation;
    _newValue = int.parse(widget.value);
  }

  @override
  void didUpdateWidget(covariant _SingleSequence oldWidget) {
    super.didUpdateWidget(oldWidget);
    num tempOldValue = int.parse(oldWidget.value);
    num tempNewValue = int.parse(widget.value);
    Color? digitColor = widget.digitColor;
    if (digitColor == null) {
      if (tempNewValue < tempOldValue) {
        _textColor = widget.negativeColor;
      } else if (tempNewValue > tempOldValue) {
        _textColor = widget.positiveColor;
      } else {
        _textColor = widget.neutralColor;
      }
    } else {
      _textColor = digitColor;
    }

    if (tempNewValue < tempOldValue) {
      _oldValue = tempNewValue;
      _newValue = tempOldValue;
      _animation = ReverseAnimation(widget.animation);
    } else {
      _oldValue = tempOldValue;
      _newValue = tempNewValue;
      if (tempNewValue > tempOldValue) {
        _animation = widget.animation;
      } else {
        _animation = const AlwaysStoppedAnimation(1.0);
      }
    }
  }

  Widget getLayer(
      {required num value, required Offset begin, required Offset end}) {
    return SlideTransition(
      position: _animation.drive(
        Tween<Offset>(
          begin: begin,
          end: end,
        ),
      ),
      child: Text(
        key: ValueKey<num>(value),
        '$value',
        style: widget.textStyle.copyWith(color: _textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          getLayer(
            value: _oldValue,
            begin: Offset.zero,
            end: const Offset(0, -1),
          ),
          getLayer(
            value: _newValue,
            begin: const Offset(0, 1),
            end: Offset.zero,
          ),
        ],
      ),
    );
  }
}