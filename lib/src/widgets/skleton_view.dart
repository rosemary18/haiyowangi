import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkletonView extends StatelessWidget {

  final double? height;
  final double? width;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const SkletonView({
    super.key,
    this.height = 40.0,
    this.width,
    this.radius = 8.0,
    this.margin
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        )
      )
    );
  }
}