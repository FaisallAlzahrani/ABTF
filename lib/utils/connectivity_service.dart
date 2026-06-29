import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectivityService {
  // Check if the device has internet connectivity
  static Future<bool> isConnected() async {
    try {
      // Try to make a request to a reliable endpoint
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      // If there's any error (timeout, no connection, etc.), return false
      return false;
    }
  }
}
