import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/themes/app_them_data.dart';

class AppLoadingWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final bool showDots;
  final bool showFunFact;

  const AppLoadingWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.showDots = true,
    this.showFunFact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Try to find DarkThemeProvider, fallback to default theme if not found
    DarkThemeProvider? themeChange;
    try {
      themeChange = Get.find<DarkThemeProvider>();
    } catch (e) {
      // If DarkThemeProvider is not registered, use default theme
      themeChange = null;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // **ANIMATED ICON**
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: size ?? 60,
                  height: size ?? 60,
                  decoration: BoxDecoration(
                    color: backgroundColor ?? AppThemeData.primary300,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (backgroundColor ?? AppThemeData.primary300).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon ?? Icons.search,
                    color: iconColor ?? Colors.white,
                    size: (size ?? 60) * 0.5,
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
            },
          ),
          
          const SizedBox(height: 24),
          
          // **LOADING TEXT**
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Column(
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: (themeChange?.getThem() ?? false)
                              ? AppThemeData.grey50 
                              : AppThemeData.grey900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (subtitle != null) ...[
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppThemeData.grey400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          
          if (showDots) ...[
            const SizedBox(height: 20),
            
            // **ANIMATED DOTS**
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 800 + (index * 300)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5201).withValues(alpha: 0.3 + (0.7 * value)),
                              shape: BoxShape.circle,
                            ),
                    );
                  },
                  onEnd: () {
                    // Restart animation
                  },
                );
              }),
            ),
          ],
          
          if (showFunFact) ...[
            const SizedBox(height: 40),
            _buildFunFact(themeChange),
          ],
        ],
      ),
    );
  }

  Widget _buildFunFact(DarkThemeProvider? themeChange) {
    final funFacts = [
      "🍕 Pizza is the most popular food in the world!",
      "🌮 Tacos are eaten 4.5 billion times per year in the US!",
      "🍔 Americans eat 50 billion burgers per year!",
      "🍜 Ramen was invented in Japan in 1958!",
      "🍰 The world's largest cake weighed 128,238 pounds!",
      "🥘 Biryani has over 50 different varieties!",
      "🍦 Ice cream was invented in China over 4000 years ago!",
      "🍕 The first pizza was made in Naples, Italy!",
    ];
    
    final randomFact = funFacts[DateTime.now().millisecond % funFacts.length];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (themeChange?.getThem() ?? false)
            ? AppThemeData.grey800 
            : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemeData.primary300.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        randomFact,
        style: TextStyle(
          fontSize: 14,
          color: (themeChange?.getThem() ?? false)
              ? AppThemeData.grey300 
              : AppThemeData.grey600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// **PREDEFINED LOADING WIDGETS FOR COMMON USE CASES**

class SearchLoadingWidget extends StatelessWidget {
  const SearchLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingWidget(
      title: "🔍 Finding Your Perfect Match",
      subtitle: "Searching through thousands of options...",
      icon: Icons.search,
      showDots: true,
      showFunFact: false,
    );
  }
}

class RestaurantLoadingWidget extends StatelessWidget {
  final bool showFunFact;
  
  const RestaurantLoadingWidget({
    super.key,
    this.showFunFact = true,
  });

  @override
  Widget build(BuildContext context) {
    // Try to find DarkThemeProvider, fallback to default theme if not found
    DarkThemeProvider? themeChange;
    try {
      themeChange = Get.find<DarkThemeProvider>();
    } catch (e) {
      // If DarkThemeProvider is not registered, use default theme
      themeChange = null;
    }

    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppThemeData.primary300.withOpacity(0.1),
                  AppThemeData.primary300.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppThemeData.primary300.withOpacity(0.08),
                  AppThemeData.primary300.withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // **ANIMATED RESTAURANT ICON WITH ROTATING PLATE**
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 2000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating plate background
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 2),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, rotationValue, child) {
                            return Transform.rotate(
                              angle: rotationValue * 2 * 3.14159, // Full rotation
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5201).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF5201).withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: PlatePainter(),
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // Restart rotation animation
                          },
                        ),
                        // Main restaurant icon with rotation
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 3),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, rotationValue, child) {
                            return Transform.rotate(
                              angle: rotationValue * 2 * 3.14159, // Full rotation
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5201),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5201).withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // Restart rotation animation
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              onEnd: () {
                // Restart animation
              },
            ),

              const SizedBox(height: 24),

              // **LOADING TEXT WITH SAME ANIMATION**
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Text(
                          "🍽️ Preparing Your Food Journey",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: (themeChange?.getThem() ?? false)
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Loading delicious restaurants & dishes...",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppThemeData.grey400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // **ANIMATED DOTS**
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 800 + (index * 300)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.3 + (0.7 * value)),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                    onEnd: () {
                      // Restart animation
                    },
                  );
                }),
              ),

              if (showFunFact) ...[
                const SizedBox(height: 40),
                _buildFunFact(themeChange),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFunFact(DarkThemeProvider? themeChange) {
    final funFacts = [
      "🍕 Pizza is the most popular food in the world!",
      "🌮 Tacos are eaten 4.5 billion times per year in the US!",
      "🍔 Americans eat 50 billion burgers per year!",
      "🍜 Ramen was invented in Japan in 1958!",
      "🍰 The world's largest cake weighed 128,238 pounds!",
      "🥘 Biryani has over 50 different varieties!",
      "🍦 Ice cream was invented in China over 4000 years ago!",
      "🍕 The first pizza was made in Naples, Italy!",
    ];
    
    final randomFact = funFacts[DateTime.now().millisecond % funFacts.length];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (themeChange?.getThem() ?? false)
            ? AppThemeData.grey800 
            : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        randomFact,
        style: TextStyle(
          fontSize: 14,
          color: (themeChange?.getThem() ?? false)
              ? AppThemeData.grey300 
              : AppThemeData.grey600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class GeneralLoadingWidget extends StatelessWidget {
  final String? message;
  
  const GeneralLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoadingWidget(
      title: message ?? "⏳ Loading...",
      icon: Icons.hourglass_empty,
      showDots: true,
      showFunFact: false,
    );
  }
}

class DataLoadingWidget extends StatelessWidget {
  final String? message;
  
  const DataLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoadingWidget(
      title: message ?? "📊 Loading Data...",
      subtitle: "Please wait while we fetch your information",
      icon: Icons.cloud_download,
      showDots: true,
      showFunFact: false,
    );
  }
}

class OrderLoadingWidget extends StatelessWidget {
  final String? message;
  
  const OrderLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Try to find DarkThemeProvider, fallback to default theme if not found
    DarkThemeProvider? themeChange;
    try {
      themeChange = Get.find<DarkThemeProvider>();
    } catch (e) {
      // If DarkThemeProvider is not registered, use default theme
      themeChange = null;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // **ANIMATED HAND WITH SERVING DISH ICON**
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5201),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5201).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.room_service, // Hand with serving dish icon
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
            },
          ),
          
          const SizedBox(height: 24),
          
          // **LOADING TEXT WITH SAME ANIMATION**
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Column(
                  children: [
                    Text(
                      message ?? "🍽️ Loading Your Orders",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: (themeChange?.getThem() ?? false)
                            ? AppThemeData.grey50 
                            : AppThemeData.grey900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fetching your delicious order history...",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemeData.grey400,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // **ANIMATED DOTS**
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800 + (index * 300)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5201).withValues(alpha: 0.3 + (0.7 * value)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// **CUSTOM PAINTER FOR PLATE DESIGN**
class PlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5201).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Draw plate rim
    canvas.drawCircle(center, radius, paint);

    // Draw decorative lines on the plate
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14159 * 2) / 8;
      final startRadius = radius * 0.7;
      final endRadius = radius * 0.9;
      
      final startX = center.dx + startRadius * cos(angle);
      final startY = center.dy + startRadius * sin(angle);
      final endX = center.dx + endRadius * cos(angle);
      final endY = center.dy + endRadius * sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Draw inner circle
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
