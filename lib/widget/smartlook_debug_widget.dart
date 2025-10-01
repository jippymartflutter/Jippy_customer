import 'package:flutter/material.dart';
import '../services/smartlook_service.dart';
import '../config/smartlook_config.dart';

/// SmartLook Debug Widget
/// 
/// This widget provides debugging controls for SmartLook
/// Use this in development to test SmartLook functionality
class SmartLookDebugWidget extends StatefulWidget {
  const SmartLookDebugWidget({super.key});

  @override
  State<SmartLookDebugWidget> createState() => _SmartLookDebugWidgetState();
}

class _SmartLookDebugWidgetState extends State<SmartLookDebugWidget> {
  final SmartlookService _smartlookService = SmartlookService();
  bool _isLoading = false;
  String _status = 'Unknown';

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    setState(() {
      _status = _smartlookService.isInitialized ? 'Initialized ✅' : 'Not Initialized ❌';
    });
  }

  Future<void> _forceReinitialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _smartlookService.forceReinitialize(
        SmartlookConfig.projectKey,
        region: SmartlookConfig.region,
      );
      
      setState(() {
        _status = success ? 'Reinitialized ✅' : 'Reinitialization Failed ❌';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _smartlookService.checkHealthAndRecover(
        SmartlookConfig.projectKey,
        region: SmartlookConfig.region,
      );
      
      setState(() {
        _status = success ? 'Healthy ✅' : 'Unhealthy ❌';
      });
    } catch (e) {
      setState(() {
        _status = 'Health Check Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getSessionUrl() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = await _smartlookService.getSessionUrl();
      setState(() {
        _status = url != null ? 'Session URL: $url' : 'No Session URL';
      });
    } catch (e) {
      setState(() {
        _status = 'Session URL Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎥 SmartLook Debug Panel',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: $_status',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkHealth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Check Health'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _forceReinitialize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Force Reinit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getSessionUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Get Session URL'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh Status'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show SmartLook debug panel
void showSmartLookDebugPanel(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('SmartLook Debug'),
      content: const SmartLookDebugWidget(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}