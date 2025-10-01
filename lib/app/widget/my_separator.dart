import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/src/dotted_border_options.dart';

class MySeparator extends StatelessWidget {
  final Color color;
  final double height;
  final double width;

  const MySeparator({
    Key? key,
    required this.color,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: color,
        strokeWidth: 2,
        radius: const Radius.circular(10),
        dashPattern: const [6, 3],
      ),
      child: Container(
        height: height,
        width: width,
      ),
    );
  }
} 