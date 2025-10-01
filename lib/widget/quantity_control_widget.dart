import 'package:flutter/material.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class QuantityControlWidget extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isEnabled;
  final double? width;
  final double? height;

  const QuantityControlWidget({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.isEnabled = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return Container(
      width: width ?? 80,
      height: height ?? 32,
      constraints: BoxConstraints(
        minWidth: 60,
        maxWidth: 100,
        minHeight: 28,
        maxHeight: 40,
      ),
      decoration: ShapeDecoration(
        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          Flexible(
            flex: 1,
            child: InkWell(
              onTap: isEnabled ? onDecrement : null,
              borderRadius: BorderRadius.circular(200),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: isEnabled 
                    ? (themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)
                    : AppThemeData.grey400,
                ),
              ),
            ),
          ),
          
          // Quantity text
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppThemeData.medium,
                  fontWeight: FontWeight.w500,
                  color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                ),
              ),
            ),
          ),
          
          // Increment button
          Flexible(
            flex: 1,
            child: InkWell(
              onTap: isEnabled ? onIncrement : null,
              borderRadius: BorderRadius.circular(200),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: isEnabled 
                    ? (themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)
                    : AppThemeData.grey400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 