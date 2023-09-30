import 'package:flutter/material.dart';
import '../data/heatmap_color.dart';

class HeatMapContainer extends StatelessWidget {
  final DateTime date;
  final double size;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final EdgeInsets? margin;
  final bool? showText;
  final Function(DateTime dateTime, TapDownDetails details)? onTapDown;
  final Function(DateTime dateTime, TapUpDetails details)? onTapUp;
  final Function(DateTime dateTime)? onTap;

  const HeatMapContainer({
    Key? key,
    required this.date,
    required this.size,
    this.margin,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.showText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.all(2),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? HeatMapColor.defaultColor,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 5)),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutQuad,
            width: size,
            height: size,
            alignment: Alignment.center,
            child: (showText ?? true)
                ? Text(
                    date.day.toString(),
                    style: TextStyle(
                        color: textColor ?? const Color(0xFF8A8A8A),
                        fontSize: fontSize),
                  )
                : null,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius:
                  BorderRadius.all(Radius.circular(borderRadius ?? 5)),
            ),
          ),
        ),
        onTap: () {
          onTap != null ? onTap!(date) : null;
        },
        onTapDown: (TapDownDetails tapDownDetails) {
          onTapDown != null ? onTapDown!(date, tapDownDetails) : null;
        },
        onTapUp: (TapUpDetails tapDownDetails) {
          onTapUp != null ? onTapUp!(date, tapDownDetails) : null;
        },
      ),
    );
  }
}
