import 'package:flutter/material.dart';
import 'package:customer/models/vendor_model.dart';

/// **Restaurant Open/Close Failproof System**
/// 
/// This class implements the comprehensive failproof system for determining
/// restaurant open/close status based on the documentation provided.
/// 
/// **Core Failproof Logic:**
/// Restaurant is ONLY OPEN if BOTH conditions are met:
/// 1. Manual toggle (isOpen) is explicitly set to true
/// 2. Current time is within configured working hours
/// 
/// **Decision Matrix:**
/// | Manual Toggle (isOpen) | Within Working Hours | Final Status | Reason |
/// |------------------------|---------------------|--------------|---------|
/// | true | yes | **OPEN** | Manual toggle enabled + within working hours |
/// | false | yes | **CLOSED** | Manual override to close (ignores working hours) |
/// | true | no | **CLOSED** | Manual toggle ignored (outside working hours) |
/// | false | no | **CLOSED** | Manual override + outside working hours |
/// | null | yes | **CLOSED** | No manual toggle set (failproof safety) |
/// | null | no | **CLOSED** | No manual toggle + outside working hours |
class RestaurantStatusManager {
  static final RestaurantStatusManager _instance = RestaurantStatusManager._internal();
  factory RestaurantStatusManager() => _instance;
  RestaurantStatusManager._internal();

  /// **MAIN STATUS CHECK FUNCTION**
  /// 
  /// Implements the failproof logic where restaurant is ONLY OPEN if:
  /// 1. Manual toggle (isOpen) is explicitly true AND
  /// 2. Current time is within working hours
  /// 
  /// @param workingHours - Array of working hours configuration
  /// @param isOpen - Manual toggle status (true/false/null)
  /// @return true if restaurant is open, false otherwise
  bool isRestaurantOpenNow(List<WorkingHours>? workingHours, bool? isOpen) {
    print('DEBUG: RestaurantStatusManager - Checking status');
    print('DEBUG: Manual toggle (isOpen): $isOpen');
    
    // Step 1: Get current day and time
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final now = DateTime.now();
    final currentDay = days[now.weekday % 7]; // weekday is 1-7, we need 0-6
    final currentTime = _formatTime(now.hour, now.minute);
    
    print('DEBUG: Current day: $currentDay, Current time: $currentTime');
    
    // Step 2: Check if within working hours
    bool withinWorkingHours = false;
    
    if (workingHours != null && workingHours.isNotEmpty) {
      for (var workingHour in workingHours) {
        if (workingHour.day == currentDay) {
          final slots = workingHour.timeslot ?? [];
          for (var slot in slots) {
            final from = slot.from ?? '';
            final to = slot.to ?? '';
            
            if (from.isNotEmpty && to.isNotEmpty) {
              print('DEBUG: Checking slot: $from - $to');
              if (_isTimeInRange(currentTime, from, to)) {
                withinWorkingHours = true;
                print('DEBUG: Current time is within working hours');
                break;
              }
            }
          }
          if (withinWorkingHours) break;
        }
      }
    }
    
    print('DEBUG: Within working hours: $withinWorkingHours');
    
    // Step 3: Apply failproof logic
    // Restaurant is ONLY OPEN if BOTH conditions are met:
    // 1. Manual toggle is explicitly true AND
    // 2. Within working hours
    if (isOpen == true && withinWorkingHours) {
      print('DEBUG: Restaurant is OPEN - Both conditions met');
      return true;
    }
    
    print('DEBUG: Restaurant is CLOSED - Failproof conditions not met');
    return false;
  }

  /// **GET DETAILED STATUS INFORMATION**
  /// 
  /// Returns comprehensive status object with reason and UI information
  Map<String, dynamic> getRestaurantStatus(List<WorkingHours>? workingHours, bool? isOpen) {
    final now = DateTime.now();
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final currentDay = days[now.weekday % 7]; // weekday is 1-7, we need 0-6
    final currentTime = _formatTime(now.hour, now.minute);
    
    // Check if within working hours
    bool withinWorkingHours = false;
    String? nextOpeningTime;
    
    if (workingHours != null && workingHours.isNotEmpty) {
      for (var workingHour in workingHours) {
        if (workingHour.day == currentDay) {
          final slots = workingHour.timeslot ?? [];
          for (var slot in slots) {
            final from = slot.from ?? '';
            final to = slot.to ?? '';
            
            if (from.isNotEmpty && to.isNotEmpty) {
              if (_isTimeInRange(currentTime, from, to)) {
                withinWorkingHours = true;
                break;
              }
            }
          }
          if (withinWorkingHours) break;
        }
      }
      
      // Get next opening time
      nextOpeningTime = _getNextOpeningTime(workingHours, currentDay, currentTime);
    }
    
    // Determine final status
    final isOpenNow = isOpen == true && withinWorkingHours;
    
    // Determine reason and UI information
    String reason;
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isOpen == false) {
      reason = 'Restaurant is manually closed';
      statusColor = Colors.red;
      statusIcon = Icons.lock;
      statusText = 'Closed';
    } else if (isOpen == null) {
      reason = 'No manual toggle set (failproof safety)';
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'Closed';
    } else if (!withinWorkingHours) {
      reason = 'Outside working hours';
      statusColor = Colors.red;
      statusIcon = Icons.lock;
      statusText = 'Closed';
    } else {
      reason = 'Open now';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Open';
    }
    
    return {
      'isOpen': isOpenNow,
      'isManuallyClosed': isOpen == false,
      'isManuallyOpen': isOpen == true,
      'noManualToggle': isOpen == null,
      'withinWorkingHours': withinWorkingHours,
      'reason': reason,
      'statusColor': statusColor,
      'statusIcon': statusIcon,
      'statusText': statusText,
      'nextOpeningTime': nextOpeningTime,
      'currentDay': currentDay,
      'currentTime': currentTime,
      'hasWorkingHours': workingHours != null && workingHours.isNotEmpty,
    };
  }

  /// **VALIDATE WORKING HOURS DATA STRUCTURE**
  /// 
  /// Ensures working hours data is properly formatted
  bool validateWorkingHours(List<WorkingHours>? workingHours) {
    if (workingHours == null || workingHours.isEmpty) {
      return false;
    }
    
    for (var day in workingHours) {
      if (day.day == null || day.timeslot == null || day.timeslot!.isEmpty) {
        return false;
      }
      
      for (var slot in day.timeslot!) {
        if (slot.from == null || slot.to == null) {
          return false;
        }
        
        // Validate time format (HH:MM)
        final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
        if (!timeRegex.hasMatch(slot.from!) || !timeRegex.hasMatch(slot.to!)) {
          return false;
        }
      }
    }
    
    return true;
  }

  /// **GET NEXT OPENING TIME**
  /// 
  /// Returns the next time the restaurant will be open
  String? _getNextOpeningTime(List<WorkingHours> workingHours, String currentDay, String currentTime) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final currentDayIndex = days.indexOf(currentDay);
    
    // Check today's remaining slots
    final todayHours = workingHours.where((h) => h.day == currentDay).firstOrNull;
    if (todayHours?.timeslot != null) {
      for (var slot in todayHours!.timeslot!) {
        if (slot.from != null && _isTimeInRange(currentTime, '00:00', slot.from!)) {
          return '${slot.from} (Today)';
        }
      }
    }
    
    // Check next 7 days
    for (int i = 1; i <= 7; i++) {
      final nextDayIndex = (currentDayIndex + i) % 7;
      final nextDay = days[nextDayIndex];
      
      final nextDayHours = workingHours.where((h) => h.day == nextDay).firstOrNull;
      if (nextDayHours?.timeslot != null && nextDayHours!.timeslot!.isNotEmpty) {
        final firstSlot = nextDayHours.timeslot!.first;
        if (firstSlot.from != null) {
          return '${firstSlot.from} ($nextDay)';
        }
      }
    }
    
    return null;
  }

  /// **FORMAT TIME TO HH:MM STRING**
  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// **CHECK IF TIME IS IN RANGE**
  /// 
  /// Compares time strings in HH:MM format
  bool _isTimeInRange(String currentTime, String startTime, String endTime) {
    // Convert time strings to comparable values
    final current = _timeStringToMinutes(currentTime);
    final start = _timeStringToMinutes(startTime);
    final end = _timeStringToMinutes(endTime);
    
    return current >= start && current <= end;
  }
  
  /// **CONVERT TIME STRING TO MINUTES FOR COMPARISON**
  int _timeStringToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    return hours * 60 + minutes;
  }

  /// **UPDATE UI ELEMENTS**
  /// 
  /// Updates status display and cart buttons based on status
  void updateRestaurantStatusUI(Map<String, dynamic> status, {
    Function(bool)? onStatusChange,
    Function(String)? onStatusMessageChange,
  }) {
    if (onStatusChange != null) {
      onStatusChange(status['isOpen']);
    }
    
    if (onStatusMessageChange != null) {
      onStatusMessageChange(status['reason']);
    }
  }

  /// **START STATUS MONITORING**
  /// 
  /// Checks status every specified interval (default: 5 minutes)
  void startStatusMonitoring({
    required List<WorkingHours>? workingHours,
    required bool? isOpen,
    required Function(Map<String, dynamic>) onStatusUpdate,
    int intervalMinutes = 5,
  }) {
    // Check status immediately
    final status = getRestaurantStatus(workingHours, isOpen);
    onStatusUpdate(status);
    
    // Set up periodic checks
    Future.delayed(Duration(minutes: intervalMinutes), () {
      startStatusMonitoring(
        workingHours: workingHours,
        isOpen: isOpen,
        onStatusUpdate: onStatusUpdate,
        intervalMinutes: intervalMinutes,
      );
    });
  }

  /// **GET STATUS SUMMARY FOR DEBUGGING**
  String getStatusSummary(List<WorkingHours>? workingHours, bool? isOpen) {
    final status = getRestaurantStatus(workingHours, isOpen);
    
    return '''
Restaurant Status Summary:
- Manual Toggle (isOpen): $isOpen
- Within Working Hours: ${status['withinWorkingHours']}
- Final Status: ${status['isOpen'] ? 'OPEN' : 'CLOSED'}
- Reason: ${status['reason']}
- Next Opening: ${status['nextOpeningTime'] ?? 'Unknown'}
''';
  }
}
