// lib/models/catering_request.dart
class CateringRequest {
  final String name;
  final String mobile;
  final String? alternativeMobile;
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
    this.alternativeMobile,
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
      'alternative_mobile': alternativeMobile,
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

  factory CateringRequest.fromJson(Map<String, dynamic> json) {
    return CateringRequest(
      name: json['name'],
      mobile: json['mobile'],
      alternativeMobile: json['alternative_mobile'],
      email: json['email'],
      place: json['place'],
      date: DateTime.parse(json['date']),
      guests: json['guests'],
      functionType: json['function_type'],
      mealPreference: json['meal_preference'],
      vegCount: json['veg_count'],
      nonvegCount: json['nonveg_count'],
      specialRequirements: json['special_requirements'],
    );
  }
}
