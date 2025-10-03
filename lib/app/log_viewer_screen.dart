import 'dart:io';

import 'package:customer/utils/app_lifecycle_logger.dart';
import 'package:customer/utils/production_logger.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({Key? key}) : super(key: key);

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  String _logContent = '';
  Map<String, dynamic> _logStats = {};
  Map<String, dynamic> _appStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get log file path
      final logFilePath = await ProductionLogger.getLogFilePath();

      if (logFilePath != null) {
        final logFile = File(logFilePath);
        final exists = await logFile.exists();
        if (exists) {
          _logContent = await logFile.readAsString();
        } else {
          _logContent = 'No log file found';
        }
      } else {
        _logContent = 'Log file not accessible';
      }

      // Get log statistics
      _logStats = await ProductionLogger.getLogStats();

      // Get app lifecycle statistics
      _appStats = await AppLifecycleLogger().getAppStats();
    } catch (e) {
      _logContent = 'Error loading logs: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _shareLogs() async {
    try {
      final logFilePath = await ProductionLogger.getLogFilePath();
      if (logFilePath != null) {
        final logFile = File(logFilePath);
        final exists = await logFile.exists();
        if (exists) {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(logFilePath)],
              text: 'JippyMart App Logs - Please share this with support team',
            ),
          );
        } else {
          _showSnackBar('Log file not found');
        }
      } else {
        _showSnackBar('Log file not accessible');
      }
    } catch (e) {
      _showSnackBar('Error sharing logs: $e');
    }
  }

  Future<void> _clearLogs() async {
    try {
      await ProductionLogger.clearLogs();
      await _loadLogs();
      _showSnackBar('Logs cleared successfully');
    } catch (e) {
      _showSnackBar('Error clearing logs: $e');
    }
  }

  Future<void> _uploadLogs() async {
    try {
      await ProductionLogger.uploadLogs();
      _showSnackBar('Logs uploaded successfully');
    } catch (e) {
      _showSnackBar('Error uploading logs: $e');
    }
  }

  Future<void> _forceLogCurrentState() async {
    try {
      await AppLifecycleLogger().forceLogCurrentState();
      await _loadLogs(); // Refresh logs
      _showSnackBar('Current state logged successfully');
    } catch (e) {
      _showSnackBar('Error logging current state: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareLogs,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearLogs();
                  break;
                case 'upload':
                  _uploadLogs();
                  break;
                case 'force_log':
                  _forceLogCurrentState();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(width: 8),
                    Text('Clear Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'upload',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Upload Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'force_log',
                child: Row(
                  children: [
                    Icon(Icons.bug_report),
                    SizedBox(width: 8),
                    Text('Force Log Current State'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Log Statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_logStats.isNotEmpty) ...[
                        Text(
                            'File Size: ${_logStats['file_size_mb'] ?? 'N/A'} MB'),
                        Text(
                            'Log Entries: ${_logStats['log_entries'] ?? 'N/A'}'),
                        Text('Device ID: ${_logStats['device_id'] ?? 'N/A'}'),
                        Text('User ID: ${_logStats['user_id'] ?? 'N/A'}'),
                      ] else
                        const Text('No statistics available'),
                    ],
                  ),
                ),

                // App Lifecycle Statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Lifecycle Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_appStats.isNotEmpty) ...[
                        Text(
                            'App Open Count: ${_appStats['app_open_count'] ?? 'N/A'}'),
                        Text(
                            'Firebase User: ${_appStats['firebase_user'] ?? 'N/A'}'),
                        Text(
                            'API Token Exists: ${_appStats['api_token_exists'] ?? 'N/A'}'),
                        Text(
                            'Last Resume: ${_appStats['last_resume_time'] ?? 'N/A'}'),
                        Text(
                            'Last Pause: ${_appStats['last_pause_time'] ?? 'N/A'}'),
                      ] else
                        const Text('No app statistics available'),
                    ],
                  ),
                ),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'If you\'re experiencing issues, please share these logs with the support team. This helps us identify and fix problems.',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                // Log Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _logContent.isEmpty ? 'No logs available' : _logContent,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
