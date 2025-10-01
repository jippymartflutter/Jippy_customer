import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/services/app_update_service.dart';

class UpdateTestWidget extends StatelessWidget {
  const UpdateTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update System Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Update System Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use these buttons to test the update system functionality.',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                String currentVersion = await AppUpdateService.getCurrentVersion();
                String currentBuild = await AppUpdateService.getCurrentBuildNumber();
                Get.snackbar(
                  'Current Version',
                  'Version: $currentVersion\nBuild: $currentBuild',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: Duration(seconds: 3),
                );
              },
              icon: Icon(Icons.info),
              label: Text('Show Current Version'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                Get.dialog(
                  AlertDialog(
                    title: Text('Checking for Updates...'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Fetching latest version info...'),
                      ],
                    ),
                  ),
                );
                
                await AppUpdateService.checkForUpdate();
                Get.back(); // Close the loading dialog
              },
              icon: Icon(Icons.system_update),
              label: Text('Check for Updates'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                bool meetsMinimum = await AppUpdateService.checkMinimumVersion();
                Get.snackbar(
                  'Minimum Version Check',
                  meetsMinimum ? 'App meets minimum version requirement' : 'App version is too old',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: meetsMinimum ? Colors.green : Colors.red,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
              },
              icon: Icon(Icons.security),
              label: Text('Check Minimum Version'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Test with a fake version to trigger update dialog
                AppUpdateService.showUpdateDialog(
                  latestVersion: '2.2.0',
                  forceUpdate: false,
                  updateUrl: 'https://play.google.com/store/apps/details?id=com.jippymart.customer',
                  currentVersion: '2.1.6',
                  updateMessage: 'Test update message - New features available!',
                );
              },
              icon: Icon(Icons.bug_report),
              label: Text('Test Update Dialog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Test force update dialog
                AppUpdateService.showUpdateDialog(
                  latestVersion: '2.2.0',
                  forceUpdate: true,
                  updateUrl: 'https://play.google.com/store/apps/details?id=com.jippymart.customer',
                  currentVersion: '2.1.6',
                  updateMessage: 'Critical security update required! This update cannot be dismissed.',
                );
              },
              icon: Icon(Icons.warning),
              label: Text('Test Force Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            Spacer(),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Set up Firestore document as per FIREBASE_UPDATE_SETUP.md\n'
                      '2. Use "Check for Updates" to test with real data\n'
                      '3. Use "Test Update Dialog" to see the UI\n'
                      '4. Remove this widget after testing',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 