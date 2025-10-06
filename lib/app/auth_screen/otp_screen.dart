import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/login_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final LoginController controller = Get.find<LoginController>();
    // Start the resend timer if not already started
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.resendTimerStarted) {
        controller.startResendTimer();
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem()
            ? AppThemeData.surfaceDark
            : AppThemeData.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify Your Number 📱".tr,
                style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey900,
                    fontSize: 22,
                    fontFamily: AppThemeData.semiBold),
              ),
              Text(
                "${'Enter the OTP sent to your mobile number.'.tr} ${controller.countryCode.value} ${Constant.maskingString(controller.phoneNumber.value, 3)}",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: themeChange.getThem()
                      ? AppThemeData.grey200
                      : AppThemeData.grey700,
                  fontSize: 16,
                  fontFamily: AppThemeData.regular,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: PinCodeTextField(
                      length: 6,
                      appContext: context,
                      keyboardType: TextInputType.phone,
                      enablePinAutofill: true,
                      hintCharacter: "-",
                      textStyle: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontFamily: AppThemeData.regular,
                      ),
                      pinTheme: PinTheme(
                        fieldHeight: 50,
                        fieldWidth: 40,
                        inactiveFillColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        selectedFillColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        activeFillColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        selectedColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        activeColor: themeChange.getThem()
                            ? AppThemeData.primary300
                            : AppThemeData.primary300,
                        inactiveColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        disabledColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        shape: PinCodeFieldShape.box,
                        errorBorderColor: themeChange.getThem()
                            ? AppThemeData.grey600
                            : AppThemeData.grey300,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      cursorColor: AppThemeData.primary300,
                      enableActiveFill: true,
                      controller: controller.otpEditingController.value,
                      onCompleted: (v) async {
                        // Optionally, you can auto-verify here
                      },
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Obx(() => RoundedButtonFill(
                    title: controller.isVerifying.value
                        ? "Verifying...".tr
                        : "Verify & Next".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: controller.isVerifying.value
                        ? null
                        : () async {
                            await controller.verifyOtp(context);
                          },
                  )),
              const SizedBox(height: 40),
              Obx(() => Text.rich(
                    textAlign: TextAlign.start,
                    TextSpan(
                      text: "Didn't receive any code?".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: AppThemeData.medium,
                        color: themeChange.getThem()
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: controller.resendSeconds.value > 0 ||
                                  controller.isVerifying.value
                              ? null
                              : (TapGestureRecognizer()
                                ..onTap = () {
                                  controller.resendOtp();
                                  controller.startResendTimer();
                                }),
                          text: controller.resendSeconds.value > 0
                              ? '  Resend in  '
                              // {controller.resendSeconds.value}s

                              : '  Send Again'.tr,
                          style: TextStyle(
                              color: (controller.resendSeconds.value > 0 ||
                                      controller.isVerifying.value)
                                  ? AppThemeData.grey400
                                  : AppThemeData.primary300,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              fontFamily: AppThemeData.medium,
                              decoration: controller.resendSeconds.value > 0
                                  ? null
                                  : TextDecoration.underline,
                              decorationColor: AppThemeData.primary300),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
