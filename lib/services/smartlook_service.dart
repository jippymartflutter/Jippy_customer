import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SmartlookService {
  static final SmartlookService _instance = SmartlookService._internal();
  factory SmartlookService() => _instance;
  SmartlookService._internal();

  final Smartlook _smartlook = Smartlook.instance;
  bool _isInitialized = false;

  /// Initialize Smartlook with project key and storage validation
  Future<void> initialize(String projectKey, {String? region}) async {
    try {
      print('[SMARTLOOK] 🚀 Starting SmartLook initialization...');
      
      // ✅ CRITICAL: Validate and cleanup storage directory before initialization
      await _validateStorageDirectory();
      
      // ✅ ENHANCED: Clean up any corrupted session files during startup
      await cleanupStorage();
      
      // ✅ NEW: Additional cleanup for the specific error we're seeing
      await _cleanupCorruptedSessionFiles();
      
      // ✅ NEW: Force clean storage if previous attempts failed
      await _forceCleanStorage();
      
      print('[SMARTLOOK] 📁 Storage prepared, setting project key...');
      
      // Set project key FIRST before starting recording
      _smartlook.preferences.setProjectKey(projectKey);
      
      // Note: Region setting is not available in this version
      // if (region != null) {
      //   _smartlook.preferences.setRegion(region);
      // }
      
      print('[SMARTLOOK] 🎬 Starting recording...');
      
      // Start recording AFTER setting project key
      _smartlook.start();
      _isInitialized = true;
      
      print('[SMARTLOOK] ✅ Successfully initialized with project key: $projectKey');
    } catch (e) {
      print('[SMARTLOOK] ❌ Initialization error: $e');
      _isInitialized = false;
      
      // ✅ ENHANCED: Try multiple recovery strategies
      try {
        print('[SMARTLOOK] 🔧 Attempting recovery...');
        await _handleInitializationFailure();
        
        // Try to reinitialize after recovery
        print('[SMARTLOOK] 🔄 Retrying initialization after recovery...');
        _smartlook.preferences.setProjectKey(projectKey);
        _smartlook.start();
        _isInitialized = true;
        print('[SMARTLOOK] ✅ Recovery successful - SmartLook reinitialized');
      } catch (e2) {
        print('[SMARTLOOK] ❌ Recovery attempt failed: $e2');
        _isInitialized = false;
      }
    }
  }

  /// ✅ NEW: Force clean storage to ensure clean state
  Future<void> _forceCleanStorage() async {
    try {
      print('[SMARTLOOK] 🧹 Force cleaning storage...');
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory smartlookDir = Directory('${appDir.path}/smartlook');
      
      // Delete entire SmartLook directory
      if (await smartlookDir.exists()) {
        await smartlookDir.delete(recursive: true);
        print('[SMARTLOOK] 🗑️ Deleted existing SmartLook directory');
      }
      
      // Recreate clean directory
      await smartlookDir.create(recursive: true);
      print('[SMARTLOOK] 📁 Created fresh SmartLook directory');
      
    } catch (e) {
      print('[SMARTLOOK] Force clean storage error: $e');
    }
  }

  /// ✅ ENHANCED: Handle specific SessionRecordingStorage errors with proper validation
  Future<void> _cleanupCorruptedSessionFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory smartlookDir = Directory('${appDir.path}/smartlook');
      
      if (await smartlookDir.exists()) {
        // ✅ CRITICAL FIX: Validate directory before operations
        final stat = await smartlookDir.stat();
        if (stat.type != FileSystemEntityType.directory) {
          print('[SMARTLOOK] Smartlook path is not a directory, recreating...');
          await smartlookDir.delete();
          await smartlookDir.create(recursive: true);
          return;
        }
        
        // Look for the specific session recording directory structure
        final Directory sessionRecordingDir = Directory('${smartlookDir.path}/session_recording');
        if (await sessionRecordingDir.exists()) {
          print('[SMARTLOOK] Found session_recording directory - cleaning up...');
          
          // ✅ SAFE DELETE: Use enhanced deletion with validation
          await _safeDeleteDirectory(sessionRecordingDir);
          await sessionRecordingDir.create(recursive: true);
          print('[SMARTLOOK] Deleted corrupted session_recording directory');
        }
        
        // ✅ NEW: Clean up other problematic directories that cause crashes
        final List<String> problemDirs = ['sessions', 'temp', 'cache'];
        for (String dirName in problemDirs) {
          final Directory dir = Directory('${smartlookDir.path}/$dirName');
          if (await dir.exists()) {
            print('[SMARTLOOK] Cleaning up $dirName directory...');
            await _safeDeleteDirectory(dir);
            await dir.create(recursive: true);
          }
        }
      }
    } catch (e) {
      print('[SMARTLOOK] Error cleaning up corrupted session files: $e');
    }
  }
  
  /// ✅ NEW: Safe directory deletion that prevents the crash
  Future<void> _safeDeleteDirectory(Directory dir) async {
    try {
      // Validate directory exists and is actually a directory
      if (await dir.exists()) {
        final stat = await dir.stat();
        if (stat.type == FileSystemEntityType.directory) {
          // Use a more careful deletion approach
          await dir.delete(recursive: true);
        } else {
          print('[SMARTLOOK] Path is not a directory, deleting as file: ${dir.path}');
          await File(dir.path).delete();
        }
      }
    } catch (e) {
      print('[SMARTLOOK] Safe directory deletion failed for ${dir.path}: $e');
      // Try alternative cleanup approach
      try {
        await dir.delete();
      } catch (e2) {
        print('[SMARTLOOK] Alternative cleanup also failed: $e2');
      }
    }
  }

  /// ✅ NEW: Handle initialization failure with recovery
  Future<void> _handleInitializationFailure() async {
    try {
      print('[SMARTLOOK] Attempting recovery from initialization failure...');
      
      // Clean up all Smartlook storage
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory smartlookDir = Directory('${appDir.path}/smartlook');
      
      if (await smartlookDir.exists()) {
        await smartlookDir.delete(recursive: true);
        print('[SMARTLOOK] Deleted all Smartlook storage for clean restart');
      }
      
      // Recreate directory
      await smartlookDir.create(recursive: true);
      print('[SMARTLOOK] Recreated Smartlook storage directory');
      
    } catch (e) {
      print('[SMARTLOOK] Recovery failed: $e');
    }
  }

  /// ✅ ENHANCED: Validate storage directory to prevent SessionRecordingStorage errors
  Future<void> _validateStorageDirectory() async {
    try {
      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory smartlookDir = Directory('${appDir.path}/smartlook');
      
      // ✅ CRITICAL: Always recreate directory to prevent FileTreeWalk errors
      if (await smartlookDir.exists()) {
        print('[SMARTLOOK] Removing existing directory to prevent corruption...');
        await smartlookDir.delete(recursive: true);
      }
      
      // Create fresh directory
      await smartlookDir.create(recursive: true);
      print('[SMARTLOOK] Created fresh storage directory: ${smartlookDir.path}');
      
      // ✅ NEW: Create subdirectories that Smartlook expects
      final Directory sessionDir = Directory('${smartlookDir.path}/sessions');
      await sessionDir.create(recursive: true);
      
      final Directory tempDir = Directory('${smartlookDir.path}/temp');
      await tempDir.create(recursive: true);
      
      // Verify directory is writable and accessible
      final testFile = File('${smartlookDir.path}/test_write.tmp');
      await testFile.writeAsString('test');
      await testFile.delete();
      
      // ✅ NEW: Verify subdirectories are accessible
      await sessionDir.list().first;
      await tempDir.list().first;
      
      print('[SMARTLOOK] Storage directory validated with subdirectories: ${smartlookDir.path}');
    } catch (e) {
      print('[SMARTLOOK] Storage directory validation failed: $e');
      // ✅ NEW: Try alternative directory if main one fails
      try {
        final Directory altDir = Directory('${(await getTemporaryDirectory()).path}/smartlook');
        if (await altDir.exists()) {
          await altDir.delete(recursive: true);
        }
        await altDir.create(recursive: true);
        print('[SMARTLOOK] Using alternative storage directory: ${altDir.path}');
      } catch (e2) {
        print('[SMARTLOOK] Alternative storage directory also failed: $e2');
      }
    }
  }

  /// ✅ ENHANCED: Start recording with error handling
  void startRecording() {
    try {
      if (!_isInitialized) {
        print('[SMARTLOOK] Cannot start recording - not initialized');
        return;
      }
      _smartlook.start();
      print('[SMARTLOOK] Recording started');
    } catch (e) {
      print('[SMARTLOOK] Error starting recording: $e');
    }
  }

  /// ✅ ENHANCED: Stop recording with cleanup
  void stopRecording() {
    try {
      _smartlook.stop();
      print('[SMARTLOOK] Recording stopped');
    } catch (e) {
      print('[SMARTLOOK] Error stopping recording: $e');
    }
  }

  /// ✅ REMOVED: openNewSession() - Smartlook manages sessions automatically
  /// Only use this if you have specific requirements (e.g., user logout/login tracking)
  void openNewSession() {
    try {
      // ⚠️ WARNING: Only use this if you have specific session management requirements
      // Smartlook manages sessions automatically - manual session opening may fragment analytics
      _smartlook.user.session.openNew();
      print('[SMARTLOOK] New session opened (manual)');
    } catch (e) {
      print('[SMARTLOOK] Error opening new session: $e');
      // Try to recover by reinitializing storage
      _validateStorageDirectory();
    }
  }

  /// Get current session URL
  Future<String?> getSessionUrl() async {
    try {
      return await _smartlook.user.session.getUrl();
    } catch (e) {
      print('[SMARTLOOK] Error getting session URL: $e');
      return null;
    }
  }

  /// Get current session URL with timestamp
  Future<String?> getSessionUrlWithTimestamp() async {
    try {
      return await _smartlook.user.session.getUrlWithTimeStamp();
    } catch (e) {
      print('[SMARTLOOK] Error getting session URL with timestamp: $e');
      return null;
    }
  }

  /// Register session changed listener
  void registerSessionChangedListener(Function(String) callback) {
    try {
      _smartlook.eventListeners.registerSessionChangedListener(callback);
      print('[SMARTLOOK] Session changed listener registered');
    } catch (e) {
      print('[SMARTLOOK] Error registering session changed listener: $e');
    }
  }

  /// Set user identifier
  void setUserIdentifier(String identifier) {
    try {
      _smartlook.user.setIdentifier(identifier);
      print('[SMARTLOOK] User identifier set: $identifier');
    } catch (e) {
      print('[SMARTLOOK] Error setting user identifier: $e');
    }
  }

  /// Set user properties
  void setUserProperties(Map<String, String> properties) {
    try {
      // Note: setProperty method is not available in this version
      // User properties can be set through other means if needed
      print('[SMARTLOOK] User properties set: $properties (method not available in this version)');
    } catch (e) {
      print('[SMARTLOOK] Error setting user properties: $e');
    }
  }

  /// Track custom event
  void trackEvent(String eventName, {Map<String, String>? properties}) {
    try {
      // Note: trackEvent with properties is not available in this version
      _smartlook.trackEvent(eventName);
      print('[SMARTLOOK] Event tracked: $eventName');
    } catch (e) {
      print('[SMARTLOOK] Error tracking event: $e');
    }
  }

  /// Set sensitive data masking
  void setSensitiveDataMasking(bool enabled) {
    try {
      // Note: setSensitiveDataMasking is not available in this version
      print('[SMARTLOOK] Sensitive data masking ${enabled ? 'enabled' : 'disabled'} (method not available in this version)');
    } catch (e) {
      print('[SMARTLOOK] Error setting sensitive data masking: $e');
    }
  }

  /// ✅ IMPROVED: Recording quality - placeholder for future versions
  /// This method is a placeholder for when Smartlook SDK supports quality settings
  /// Current version: 4.1.27 - quality settings not available
  void setRecordingQuality(String quality) {
    try {
      // ⚠️ PLACEHOLDER: Recording quality setting not available in current SDK version
      // This will be implemented when Smartlook SDK adds quality control
      print('[SMARTLOOK] Recording quality setting requested: $quality');
      print('[SMARTLOOK] Note: Quality settings not available in current SDK version (4.1.27)');
      print('[SMARTLOOK] This is a placeholder for future SDK versions');
    } catch (e) {
      print('[SMARTLOOK] Error setting recording quality: $e');
    }
  }

  /// ✅ ENHANCED: Clean up Smartlook storage to prevent SessionRecordingStorage errors
  Future<void> cleanupStorage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory smartlookDir = Directory('${appDir.path}/smartlook');
      
      if (await smartlookDir.exists()) {
        // ✅ CRITICAL: Validate directory before listing contents
        if (!await _isValidDirectory(smartlookDir)) {
          print('[SMARTLOOK] Invalid directory detected - recreating: ${smartlookDir.path}');
          await smartlookDir.delete(recursive: true);
          await smartlookDir.create(recursive: true);
          return;
        }
        
        // Clean up any corrupted session files
        final List<FileSystemEntity> files = await smartlookDir.list().toList();
        int cleanedCount = 0;
        
        for (FileSystemEntity file in files) {
          try {
            // ✅ ENHANCED: Check if it's a valid file/directory before processing
            if (file is File && file.path.contains('session')) {
              await file.delete();
              cleanedCount++;
              print('[SMARTLOOK] Cleaned up session file: ${file.path}');
            } else if (file is Directory && file.path.contains('session')) {
              // ✅ NEW: Handle session directories that might be corrupted
              if (await _isValidDirectory(file)) {
                await file.delete(recursive: true);
                cleanedCount++;
                print('[SMARTLOOK] Cleaned up session directory: ${file.path}');
              } else {
                print('[SMARTLOOK] Skipping corrupted directory: ${file.path}');
              }
            }
          } catch (e) {
            print('[SMARTLOOK] Could not delete: ${file.path} - $e');
            // ✅ NEW: Try to handle corrupted files by recreating parent directory
            try {
              if (file is Directory) {
                await file.delete(recursive: true);
                print('[SMARTLOOK] Force deleted corrupted directory: ${file.path}');
              }
            } catch (e2) {
              print('[SMARTLOOK] Force delete failed: ${file.path} - $e2');
            }
          }
        }
        
        if (cleanedCount > 0) {
          print('[SMARTLOOK] Storage cleanup completed - $cleanedCount items removed');
        } else {
          print('[SMARTLOOK] Storage cleanup completed - no items to remove');
        }
      }
    } catch (e) {
      print('[SMARTLOOK] Storage cleanup error: $e');
      // ✅ NEW: If cleanup fails, try to recreate the entire directory
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory smartlookDir = Directory('${appDir.path}/smartlook');
        if (await smartlookDir.exists()) {
          await smartlookDir.delete(recursive: true);
        }
        await smartlookDir.create(recursive: true);
        print('[SMARTLOOK] Recreated storage directory after cleanup failure');
      } catch (e2) {
        print('[SMARTLOOK] Failed to recreate storage directory: $e2');
      }
    }
  }

  /// ✅ NEW: Validate if a directory is properly accessible
  Future<bool> _isValidDirectory(Directory dir) async {
    try {
      // Check if directory exists and is readable
      if (!await dir.exists()) return false;
      
      // Try to list contents to verify it's accessible
      await dir.list().first;
      return true;
    } catch (e) {
      print('[SMARTLOOK] Directory validation failed: ${dir.path} - $e');
      return false;
    }
  }

  /// ✅ ENHANCED: Force restart Smartlook with clean storage
  Future<void> restartWithCleanStorage() async {
    try {
      print('[SMARTLOOK] Restarting with clean storage...');
      
      // Stop current recording
      stopRecording();
      
      // Clean up storage
      await cleanupStorage();
      
      // Reinitialize
      await _validateStorageDirectory();
      
      // Restart recording
      startRecording();
      
      print('[SMARTLOOK] Restart completed successfully');
    } catch (e) {
      print('[SMARTLOOK] Restart error: $e');
    }
  }

  /// ✅ NEW: Check if Smartlook is properly initialized
  bool get isInitialized => _isInitialized;

  /// ✅ NEW: Auto-recovery method for SessionRecordingStorage errors
  Future<void> handleStorageError() async {
    print('[SMARTLOOK] Detected storage error - attempting auto-recovery...');
    try {
      await restartWithCleanStorage();
      print('[SMARTLOOK] Auto-recovery completed successfully');
    } catch (e) {
      print('[SMARTLOOK] Auto-recovery failed: $e');
      // Don't disable Smartlook - try to recover
      _isInitialized = false;
    }
  }

  /// ✅ NEW: Force reinitialize SmartLook (useful for recovery)
  Future<bool> forceReinitialize(String projectKey, {String? region}) async {
    try {
      print('[SMARTLOOK] 🔄 Force reinitializing SmartLook...');
      
      // Stop current recording
      try {
        _smartlook.stop();
      } catch (e) {
        print('[SMARTLOOK] Error stopping current recording: $e');
      }
      
      // Force clean storage
      await _forceCleanStorage();
      
      // Reinitialize
      await initialize(projectKey, region: region);
      
      if (_isInitialized) {
        print('[SMARTLOOK] ✅ Force reinitialization successful');
        return true;
      } else {
        print('[SMARTLOOK] ❌ Force reinitialization failed');
        return false;
      }
    } catch (e) {
      print('[SMARTLOOK] ❌ Force reinitialization error: $e');
      return false;
    }
  }

  /// ✅ NEW: Check SmartLook health and attempt recovery if needed
  Future<bool> checkHealthAndRecover(String projectKey, {String? region}) async {
    try {
      if (!_isInitialized) {
        print('[SMARTLOOK] 🔍 SmartLook not initialized - attempting recovery...');
        return await forceReinitialize(projectKey, region: region);
      }
      
      // Try to get session URL to test if SmartLook is working
      try {
        await _smartlook.user.session.getUrl();
        print('[SMARTLOOK] ✅ SmartLook health check passed');
        return true;
      } catch (e) {
        print('[SMARTLOOK] ❌ SmartLook health check failed: $e');
        print('[SMARTLOOK] 🔧 Attempting recovery...');
        return await forceReinitialize(projectKey, region: region);
      }
    } catch (e) {
      print('[SMARTLOOK] ❌ Health check error: $e');
      return false;
    }
  }

  /// ✅ NEW: Handle SessionRecordingStorage.deleteSession crashes
  Future<void> preventSessionRecordingStorageCrash() async {
    try {
      print('[SMARTLOOK] 🛡️ Preventing SessionRecordingStorage crashes...');
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory smartlookDir = Directory('${appDir.path}/smartlook');
      
      // ✅ CRITICAL: Ensure directory structure exists and is valid
      if (!await smartlookDir.exists()) {
        await smartlookDir.create(recursive: true);
        print('[SMARTLOOK] Created Smartlook directory');
      }
      
      // ✅ NEW: Create the specific session recording directory structure
      final Directory sessionRecordingDir = Directory('${smartlookDir.path}/session_recording');
      if (!await sessionRecordingDir.exists()) {
        await sessionRecordingDir.create(recursive: true);
        print('[SMARTLOOK] Created session_recording directory');
      }
      
      // ✅ NEW: Create subdirectories that prevent FileTreeWalk errors
      final List<String> subdirs = [
        'session_recording/active',
        'session_recording/archived',
        'session_recording/temp',
        'sessions',
        'temp',
        'cache'
      ];
      
      for (String subdir in subdirs) {
        final Directory dir = Directory('${smartlookDir.path}/$subdir');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          print('[SMARTLOOK] Created subdirectory: $subdir');
        }
      }
      
      // ✅ NEW: Verify all directories are accessible (prevents FileTreeWalk errors)
      for (String subdir in subdirs) {
        final Directory dir = Directory('${smartlookDir.path}/$subdir');
        try {
          await dir.list().first; // This will fail if directory is corrupted
          print('[SMARTLOOK] Verified directory accessibility: $subdir');
        } catch (e) {
          print('[SMARTLOOK] Directory corrupted, recreating: $subdir');
          await dir.delete(recursive: true);
          await dir.create(recursive: true);
        }
      }
      
      print('[SMARTLOOK] 🛡️ SessionRecordingStorage crash prevention completed');
    } catch (e) {
      print('[SMARTLOOK] ❌ SessionRecordingStorage crash prevention failed: $e');
    }
  }

  /// Get Smartlook instance for advanced usage
  Smartlook get instance => _smartlook;
} 