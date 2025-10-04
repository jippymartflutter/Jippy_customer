import 'package:flutter/material.dart';

class SpecialPriceBadge extends StatelessWidget {
  final bool showShimmer;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SpecialPriceBadge({
    super.key,
    this.showShimmer = true,
    this.width,
    this.height,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] SpecialPriceBadge build() called');
    print('[DEBUG] Badge dimensions: ${width ?? 60} x ${height ?? 60}');
    print(
        '[DEBUG] Badge colors: Red background (#E73336), White text, Triangular design');

    return Container(
      width: width ?? 60,
      height: height ?? 60,
      margin: margin ?? const EdgeInsets.only(right: 6),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(width ?? 60, height ?? 60),
            painter: TriangularBadgePainter(),
          ),
          // Text positioned in the triangle
          Positioned(
            top: 6,
            left: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECIAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
                Text(
                  'OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TriangularBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF44336) // Specific red color requested
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create triangular shape
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    // Draw main triangle
    canvas.drawPath(path, paint);

    // Draw folded corner effect (smaller triangle)
    final foldPaint = Paint()
      ..color = const Color(0xFFFF0003) // Darker shade of the same red
      ..style = PaintingStyle.fill;

    final foldPath = Path();
    foldPath.moveTo(0, 0);
    foldPath.lineTo(size.width * 0.3, 0);
    foldPath.lineTo(0, size.height * 0.3);
    foldPath.close();

    canvas.drawPath(foldPath, foldPaint);

    // Add shadow effect
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final shadowPath = Path();
    shadowPath.moveTo(2, 2);
    shadowPath.lineTo(size.width + 2, 2);
    shadowPath.lineTo(2, size.height + 2);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
