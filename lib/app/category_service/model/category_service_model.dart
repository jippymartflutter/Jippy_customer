// lib/models/catering_request.dart
class CateringRequest {
  final String name;
  final String mobile;
  final String? email;
  final String place;
  final DateTime date;
  final int guests;
  final String functionType;
  final String mealPreference;
  final int vegCount;
  final int nonvegCount;
  final String? specialRequirements;

  CateringRequest({
    required this.name,
    required this.mobile,
    this.email,
    required this.place,
    required this.date,
    required this.guests,
    required this.functionType,
    required this.mealPreference,
    required this.vegCount,
    required this.nonvegCount,
    this.specialRequirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'place': place,
      'date': date.toIso8601String().split('T')[0],
      'guests': guests,
      'function_type': functionType,
      'meal_preference': mealPreference,
      'veg_count': vegCount,
      'nonveg_count': nonvegCount,
      'special_requirements': specialRequirements,
    };
  }
}
