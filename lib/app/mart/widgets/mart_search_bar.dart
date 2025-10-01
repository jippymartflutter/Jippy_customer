import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/mart/mart_search_screen.dart';
import 'package:customer/themes/mart_theme.dart';

class MartSearchBar extends StatefulWidget {
  final String hintText;
  final bool enabled;
  final VoidCallback? onTap;
  
  const MartSearchBar({
    Key? key,
    this.hintText = 'Search products, categories...',
    this.enabled = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<MartSearchBar> createState() => _MartSearchBarState();
}

class _MartSearchBarState extends State<MartSearchBar> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _emojiController;
  
  // Mart-specific emojis from theme
  final List<String> martEmojis = [
    MartEmojis.cart, MartEmojis.milk, MartEmojis.bread, MartEmojis.egg, MartEmojis.cheese,
    MartEmojis.apple, MartEmojis.carrot, MartEmojis.bottle, MartEmojis.banana, MartEmojis.baguette,
    MartEmojis.potato, MartEmojis.onion, MartEmojis.tomato, MartEmojis.cucumber, MartEmojis.lettuce,
    MartEmojis.nuts, MartEmojis.honey, MartEmojis.bacon, MartEmojis.meat, MartEmojis.fish,
    MartEmojis.orange, MartEmojis.strawberry, MartEmojis.grapes, MartEmojis.mango, MartEmojis.peach,
    MartEmojis.cherry, MartEmojis.coconut, MartEmojis.pineapple, MartEmojis.kiwi, MartEmojis.melon,
  ];
  
  int currentEmojiIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation for the background circle
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Pulse animation for the center icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Emoji rotation animation
    _emojiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _emojiController.addListener(() {
      if (_emojiController.value >= 1.0) {
        setState(() {
          currentEmojiIndex = (currentEmojiIndex + 1) % martEmojis.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(80),
        border: Border.all(
          color: MartTheme.brandGreen.withOpacity(0.2),
        ),
        boxShadow: MartTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(80),
          onTap: widget.enabled ? (widget.onTap ?? () => Get.to(() => const MartSearchScreen())) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Animated search icon with mart emojis
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating background circle
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * 3.14159,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: MartTheme.brandGreen.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Pulsing center emoji
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_pulseController.value * 0.4),
                            child: Text(
                              martEmojis[currentEmojiIndex],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.hintText,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.enabled ? MartTheme.grayDark : MartTheme.grayMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.enabled)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: MartTheme.grayMedium,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
