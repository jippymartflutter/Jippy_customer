import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget boxShimmer(
    {double width = 50, double height = 50, double borderRadius = 16}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}
