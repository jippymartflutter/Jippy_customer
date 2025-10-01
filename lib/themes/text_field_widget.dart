import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class TextFieldWidget extends StatelessWidget {
  final String? title;
  final String hintText;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool? enable;
  final bool? obscureText;
  final int? maxLine;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onchange;
  final TextInputAction? textInputAction;
  final String? fontFamily;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final FocusNode? focusNode;

  const TextFieldWidget({
    super.key,
    this.textInputType,
    this.enable,
    this.obscureText,
    this.prefix,
    this.suffix,
    this.title,
    required this.hintText,
    required this.controller,
    this.maxLine,
    this.inputFormatters,
    this.onchange,
    this.textInputAction,
    this.fontFamily,
    this.fillColor,
    this.textStyle,
    this.hintTextStyle,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.tr,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 14,
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900
              ),
            ),
            const SizedBox(height: 4),
          ],
          Material(
            elevation: 2,
            shadowColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey400,
            borderRadius: BorderRadius.circular(10),
            child: TextFormField(
              keyboardType: textInputType ?? TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              controller: controller,
              focusNode: focusNode,
              maxLines: maxLine ?? 1,
              textInputAction: textInputAction ?? TextInputAction.done,
              inputFormatters: inputFormatters,
              obscureText: obscureText ?? false,
              obscuringCharacter: '●',
              onChanged: onchange,
              style: textStyle ?? TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontFamily: fontFamily ?? AppThemeData.medium,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                errorStyle: const TextStyle(color: Colors.red),
                filled: true,
                enabled: enable ?? true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                fillColor: fillColor ?? (themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50),
                prefixIcon: prefix,
                suffixIcon: suffix,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    width: 1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    width: 1,
                  ),
                ),
                hintText: hintText.tr,
                hintStyle: hintTextStyle ?? TextStyle(
                  fontSize: 14,
                  color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                  fontFamily: fontFamily ?? AppThemeData.regular,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
