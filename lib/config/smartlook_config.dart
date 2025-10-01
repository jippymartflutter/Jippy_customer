class SmartlookConfig {
  // Replace this with your actual Smartlook project key
  static const String projectKey = 'bd486dadff299f71cecaeb1e0ab15a51d6e380c0';
  
  // Region setting (optional) - 'eu' for Europe, 'us' for United States
  static const String? region = null; // Set to 'eu' or 'us' if needed
  
  // Recording quality settings
  static const String recordingQuality = 'medium'; // 'low', 'medium', 'high'
  
  // Privacy settings
  static const bool enableSensitiveDataMasking = true;
  
  // Session management
  static const bool autoStartRecording = true;
  static const bool enableSessionUrlSharing = true;
  
  // Event tracking
  static const bool enableCustomEvents = true;
  
  // User identification
  static const bool enableUserIdentification = true;
  
  // Debug settings
  static const bool enableDebugLogs = true;
  
  // Production settings (set to false in production)
  static const bool isDevelopment = true;
} 