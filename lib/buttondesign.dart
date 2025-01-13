import 'package:flutter/material.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';

class ButtonDesign extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  // final ButtonStyle? style;
  // final Gradient? gradient;
  final double thickness;

  const ButtonDesign({
    Key? key,
    required this.onPressed,
    required this.child,
    // this.style,
    // this.gradient,
    this.thickness = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     ColorFile().buttonShadowColor,
          //     ColorFile().buttonDarkColor
          //   ],
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          // ),
          // border: Border.all(width: 2, color: Colors.transparent),
          //   borderRadius: BorderRadius.circular(50),
          // color: ColorFile().buttonColor
          ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.backgroundtext,
            shadowColor: Colors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }
}
