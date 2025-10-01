import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const InitialsAvatar({Key? key, this.firstName, this.lastName, this.radius = 20, this.backgroundColor, this.textColor}) : super(key: key);

  String getInitials() {
    String first = (firstName != null && firstName!.isNotEmpty) ? firstName![0] : '';
    String last = (lastName != null && lastName!.isNotEmpty) ? lastName![0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: Text(
        getInitials(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
} 