import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Get base URL based on environment
  static String get apiBaseUrl {
    // You can switch based on build mode
    if (bool.fromEnvironment('dart.vm.product')) {
      return dotenv.env['API_BASE_URL'] ?? 'https://api.sportbook.com/v1';
    } else {
      return dotenv.env['API_BASE_URL_DEV'] ?? 'https://api.sportbook.com/v1';
    }
  }

  static bool get enableAnalytics {
    return dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  }

  static bool get enableLogging {
    return dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  }
}
