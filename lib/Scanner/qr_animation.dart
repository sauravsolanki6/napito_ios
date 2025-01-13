import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class BlinkingBorder extends StatefulWidget {
  final double size;

  const BlinkingBorder({Key? key, required this.size}) : super(key: key);

  @override
  _BlinkingBorderState createState() => _BlinkingBorderState();
}

class _BlinkingBorderState extends State<BlinkingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      upperBound: 1,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: CustomColors.backgroundtext,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: _colorAnimation.value!, width: 4),
              right: BorderSide(color: _colorAnimation.value!, width: 4),
              bottom: BorderSide(color: _colorAnimation.value!, width: 4),
              left: BorderSide(color: _colorAnimation.value!, width: 4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
