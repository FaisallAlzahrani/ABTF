import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthHelper {
  static Future<String> generateAuthToken(String serviceAccountPath) async {
    try {
      // Read and decode the service account JSON file
      final serviceAccount = jsonDecode(await File(serviceAccountPath).readAsString());
      final now = DateTime.now().toUtc();
      final expiry = now.add(Duration(hours: 1));
      final claimSet = {
        'iss': serviceAccount['client_email'],
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': serviceAccount['token_uri'],
        'iat': (now.millisecondsSinceEpoch / 1000).floor(),
        'exp': (expiry.millisecondsSinceEpoch / 1000).floor(),
      };

      // Create the JWT token
      final jwtHeader = {'alg': 'RS256', 'typ': 'JWT'};
      final jwt = base64Url.encode(utf8.encode(jsonEncode(jwtHeader))) +
          '.' +
          base64Url.encode(utf8.encode(jsonEncode(claimSet))) +
          '.' +
          base64Url.encode(
            _createSignature(jsonEncode(jwtHeader) + '.' + jsonEncode(claimSet), serviceAccount['private_key']) as List<int>,
          );

      // Request an access token
      final response = await http.post(
        Uri.parse(serviceAccount['token_uri']),
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        return tokenData['access_token'];
      } else {
        throw Exception('Failed to generate token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating token: $e');
    }
  }

  static String _createSignature(String input, String privateKey) {
    // Use RSA (with a library like `rsa_pkcs`) to sign the input with the private key
    // Example: Implement with an external library
    return ''; // Replace with the actual signature generation logic
  }
}
