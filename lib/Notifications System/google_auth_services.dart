import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class GoogleAuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String> getOAuth2BearerToken() async {
    String? storedToken = await storage.read(key: 'bearer_token');
    String? tokenExpiry = await storage.read(key: 'token_expiry');

    if (storedToken != null && tokenExpiry != null) {
      DateTime expiryTime = DateTime.parse(tokenExpiry);
      if (expiryTime.isAfter(DateTime.now())) {
        print('Using cached OAuth token');
        return storedToken;
      }
    }

    print('Fetching new OAuth token...');
    final String serviceAccountJson = await rootBundle.loadString(
        'assest/firebase/towerapp-fec08-firebase-adminsdk-4v2d5-a7d4309c1d.json');
    final Map<String, dynamic> serviceAccount = jsonDecode(serviceAccountJson);

    final String clientEmail = serviceAccount['client_email'];
    final String privateKey = serviceAccount['private_key'];

    final String authUrl = "https://oauth2.googleapis.com/token";

    final response = await http.post(
      Uri.parse(authUrl),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": _generateJWT(clientEmail, privateKey),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String accessToken = responseData['access_token'];
      int expiresIn = responseData['expires_in'];

      await storage.write(key: 'bearer_token', value: accessToken);
      await storage.write(
        key: 'token_expiry',
        value: DateTime.now()
            .add(Duration(seconds: expiresIn - 60))
            .toIso8601String(),
      );

      return accessToken;
    } else {
      throw Exception("Failed to get OAuth2 token: ${response.body}");
    }
  }


  String _generateJWT(String clientEmail, String privateKey) {
    final jwt = JWT(
      {
        "iss": clientEmail,
        "scope": "https://www.googleapis.com/auth/cloud-platform",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": (DateTime
            .now()
            .millisecondsSinceEpoch ~/ 1000) + 3600,
        "iat": (DateTime
            .now()
            .millisecondsSinceEpoch ~/ 1000),
      },
    );

    final key = RSAPrivateKey(privateKey);
    return jwt.sign(key, algorithm: JWTAlgorithm.RS256);
  }
}