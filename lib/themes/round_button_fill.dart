import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class RoundedButtonFill extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final double? fontSizes;
  final double? radius;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final bool? isRight;
  final bool? isEnabled;
  final Function()? onPress;
  final bool isLoading;

  const RoundedButtonFill({
    super.key,
    this.isEnabled = true,
    required this.title,
    this.height,
    required this.onPress,
    this.width,
    this.color,
    this.icon,
    this.fontSizes,
    this.textColor,
    this.isRight,
    this.radius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled == true
          ? () {
              FocusManager.instance.primaryFocus?.unfocus();
              onPress!();
            }
          : () {},
      child: Container(
        width: Responsive.width(width ?? 100, context),
        height: Responsive.height(height ?? 6, context),
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (isRight == false)
                ? Padding(padding: const EdgeInsets.only(right: 5), child: icon)
                : const SizedBox(),
            isLoading
                ? SpinKitWave(
                    color: Colors.blue, // customize color
                    size: 14.0, // customize size
                    duration: const Duration(seconds: 1), // optional speed
                  )
                : Text(
                    title.tr.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      color: textColor ?? AppThemeData.grey800,
                      fontSize: fontSizes ?? 14,
                    ),
                  ),
            (isRight == true)
                ? Padding(padding: const EdgeInsets.only(left: 5), child: icon)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
