import 'package:flutter/material.dart';
import 'package:customer/themes/app_them_data.dart';

class CartAnimationWidget extends StatefulWidget {
  final Widget child;
  final GlobalKey cartIconKey;
  final VoidCallback? onAnimationComplete;

  const CartAnimationWidget({
    Key? key,
    required this.child,
    required this.cartIconKey,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<CartAnimationWidget> createState() => _CartAnimationWidgetState();
}

class _CartAnimationWidgetState extends State<CartAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isAnimating = false;
  Offset? _startPosition;
  Offset? _endPosition;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
        widget.onAnimationComplete?.call();
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    // Calculate start and end positions
    _calculatePositions();
    
    // Start animation
    _animationController.forward();
  }

  void _calculatePositions() {
    // Get the position of the cart icon
    final RenderBox? cartRenderBox = widget.cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (cartRenderBox != null) {
      _endPosition = cartRenderBox.localToGlobal(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original child widget
        widget.child,
        
        // Flying animation overlay
        if (_isAnimating)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _slideAnimation.value * 100,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159 / 180,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppThemeData.primary300,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppThemeData.primary300.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Helper class to trigger cart animation from anywhere
class CartAnimationHelper {
  static final Map<String, VoidCallback> _animationCallbacks = {};
  
  static void registerAnimation(String key, VoidCallback callback) {
    _animationCallbacks[key] = callback;
  }
  
  static void unregisterAnimation(String key) {
    _animationCallbacks.remove(key);
  }
  
  static void triggerAnimation(String key) {
    _animationCallbacks[key]?.call();
  }
  
  static void triggerAllAnimations() {
    for (var callback in _animationCallbacks.values) {
      callback();
    }
  }
}
