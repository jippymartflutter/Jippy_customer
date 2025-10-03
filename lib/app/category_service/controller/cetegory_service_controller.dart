import 'dart:convert';

import 'package:customer/app/category_service/model/category_service_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CategoryServiceController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    updateGuestCounts();
  }

  void dropDownChanger(String newValue) {
    functionTypeController.text = newValue;
    update();
  }

  void vegChanger(String value) {
    mealPreference = value;
    updateGuestCounts();
    update();
  }

  void updateGuestCounts() {
    final guests = int.tryParse(guestsController.text) ?? 0;
    if (mealPreference == 'Veg') {
      vegCountController.text = guests.toString();
      nonvegCountController.text = '0';
    } else if (mealPreference == 'Non-Veg') {
      vegCountController.text = '0';
      nonvegCountController.text = guests.toString();
    }
  }

  Future<void> selectDate({required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date'),
          content: SizedBox(
            height: 400,
            width: 400,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: selectedDate,
              minDate: DateTime.now(),
              maxDate: DateTime.now().add(const Duration(days: 365)),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  selectedDate = args.value as DateTime;
                  dateController.text =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                  update();
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  void showSuccessDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: const Text(
              'Your catering request has been submitted successfully. '
              'We will contact you shortly to confirm the details.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(
      {required String message, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void resetForm() {
    formKey.currentState!.reset();
    selectedDate = DateTime.now();
    mealPreference = 'Veg';
    dateController.clear();
    update();
  }

  Future<Map<String, dynamic>> submitCateringRequest(
      CateringRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}catering-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Catering request submitted successfully!',
          'data': json.decode(response.body)['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to submit request',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your connection',
      };
    }
  }

  final formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController alterMobileNumber = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final TextEditingController functionTypeController = TextEditingController();
  final TextEditingController specialRequirementsController =
      TextEditingController();
  final TextEditingController vegCountController = TextEditingController();
  final TextEditingController nonvegCountController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String mealPreference = 'Veg';
  bool isLoading = false;

  List<String> functionTypes = [
    'Wedding',
    'Birthday Party',
    'Corporate Event',
    'Family Function',
    'Other'
  ];

  Future<void> submitForm(
      {required CategoryServiceController categoryServiceController,
      required BuildContext context}) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      final request = CateringRequest(
        name: nameController.text,
        mobile: mobileController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
        place: placeController.text,
        date: selectedDate,
        guests: int.parse(guestsController.text),
        functionType: functionTypeController.text,
        mealPreference: mealPreference,
        vegCount: int.parse(vegCountController.text),
        nonvegCount: int.parse(nonvegCountController.text),
        specialRequirements: specialRequirementsController.text.isEmpty
            ? null
            : specialRequirementsController.text,
      );

      final result =
          await categoryServiceController.submitCateringRequest(request);

      if (result['success'] == true) {
        showSuccessDialog(context: context);
        resetForm();
      } else {
        showErrorDialog(
          message: result['message'],
          context: context,
        );
      }
    } catch (e) {
      showErrorDialog(
          message: 'An unexpected error occurred', context: context);
    } finally {
      isLoading = false;
      update();
    }
  }
}
