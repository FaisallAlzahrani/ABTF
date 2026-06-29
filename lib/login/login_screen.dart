import 'dart:convert';
import 'package:application_v1/home/Maintanace.dart';
import 'package:application_v1/login/Forget.dart';
import 'package:application_v1/login/selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Notifications System/firebase_notification.dart';
import '../home/Admins_screen_updated_new.dart';
import '../home/HRD_screen_new.dart';
import '../home/Main_Screen.dart';
import '../home/Operations_screen.dart';
import '../home/home_screen.dart';
import 'user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool passToggle = true;
  bool isLoading = false;
  bool isFirstLogin = true;
  final LocalAuthentication auth = LocalAuthentication();

  bool _loadingDialogOpen = false;

  Future<void> _showBlockingLoading() async {
    if (!mounted || _loadingDialogOpen) return;
    _loadingDialogOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        const brandColor = Color(0xFF104164);
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assest/images/r2.png',
                              height: 160,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Please wait',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: brandColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Signing you in...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: brandColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _loadingDialogOpen = false;
    });
  }

  void _hideBlockingLoading() {
    if (!mounted) return;
    if (_loadingDialogOpen && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _loadingDialogOpen = false;
  }

  Future<void> saveLoginDetails(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userType', 'employee');
  }

  Future<void> handleLogin() async {
    // Assuming you have an authentication function `firstFactorLogin`
    final loginResult = await firstFactorLogin(
      emailController.text.toString(),
      passController.text.toString(),
    );

    if (loginResult['status']) {
      // Save login details in SharedPreferences
      await saveLoginDetails(emailController.text, passController.text);
      // Navigate to the next screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      // Handle failed login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginResult['message']),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to handle the login process
  Future<Map<String, dynamic>> firstFactorLogin(
      String username,
      String password,
      ) async {

    Map<String, dynamic> loginResult = {
      "status": false,
      "message": "",
      "name": "",
      "id": "",
      "department": ""
    };

    try {
      // Step 1: Authenticate user with API
      final loginResponse = await http
          .post(
            Uri.parse("http://172.18.101.32:8085/staff-api-token-auth/"),
            body: {
              "username": username,
              "password": password,
            },
          )
          .timeout(const Duration(seconds: 12));
      print("LOGIN STATUS = ${loginResponse.statusCode}");
      print("LOGIN BODY = ${loginResponse.body}");

      if (loginResponse.statusCode != 200) {
        loginResult["message"] = "Invalid username or password";
        return loginResult;
      }

      final tokenData = json.decode(loginResponse.body);

      print("TOKEN DATA = $tokenData");

      final userToken = tokenData['token'];

      print("USER TOKEN = $userToken");

        // Step 2: Fetch the employee's first name
        final empCode = username; // Use username as emp_code

      print("USER TOKEN = $userToken");
        final employeeResponse = await http
            .get(
              Uri.parse("http://172.18.101.182:8086/employee-details?emp_code=$empCode"),
            )
            .timeout(const Duration(seconds: 12));
      print("FLASK RESPONSE = ${employeeResponse.body}");
      print("FLASK STATUS = ${employeeResponse.statusCode}");
      print("FLASK BODY = ${employeeResponse.body}");
        if (employeeResponse.statusCode != 200) {
          loginResult["message"] = "Failed to fetch employee data";

          return loginResult;
        }

      final employeeData = json.decode(employeeResponse.body);

      // =====================
      // 3. FIXED PARSING (NO data[])
      // =====================
      final emp = employeeData;

      if (emp['emp_id'] == null) {
        loginResult["message"] = "Employee not found";
        return loginResult;
      }

      loginResult["name"] = emp['name'] ?? "";
      loginResult["id"] = emp['emp_id'].toString();
      loginResult["department"] = emp['department'] ?? "";
      loginResult["status"] = true;
      loginResult["message"] = "Login Successful";

        // =========================
        // 3. FIREBASE LOGIN (ONLY)
        // =========================
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "admin@app.com.sa",
            password: "11223344",
          );
        } catch (e) {
          loginResult["message"] = "Firebase login failed: $e";
        }

        return loginResult;
      } catch (e) {
      loginResult["message"] = "Network error: $e";
      return loginResult;
    }
  }
  Future<Map<String, String>> getLoginDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    return {
      'username': username ?? '', // Return an empty string if no username is saved
      'password': password ?? '', // Return an empty string if no password is saved
    };
  }

  Future<void> biometricLogin() async {
    if (isLoading) return;
    bool authenticated = false;

    try {
      // Check if we have saved credentials first
      final loginDetails = await getLoginDetails();
      final String savedUsername = (loginDetails['username'] ?? '').trim();
      final String savedPassword = (loginDetails['password'] ?? '').trim();

      final String typedUsername = emailController.text.trim();
      final String typedPassword = passController.text.trim();

      final String usernameToUse = savedUsername.isNotEmpty ? savedUsername : typedUsername;
      final String passwordToUse = savedPassword.isNotEmpty ? savedPassword : typedPassword;

      if (usernameToUse.isEmpty || passwordToUse.isEmpty) {
        // No saved credentials, inform user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please sign in with username and password first'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Authenticate with biometrics
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Set loading state
        setState(() {
          isLoading = true;
        });
        _showBlockingLoading();

        // Set the controllers with saved credentials for consistency
        emailController.text = usernameToUse;
        passController.text = passwordToUse;

        try {
          // Login with saved credentials
          final loginResult = await firstFactorLogin(
            usernameToUse,
            passwordToUse,
          );

          if (loginResult['status']) {
            final fcmToken = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 12));

          // Save login session state
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', loginDetails['username']!);
          await prefs.setString('password', loginDetails['password']!);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userName', loginResult['name']);
          await prefs.setString('userId', loginResult['id']);
          await prefs.setString('userDepartment', loginResult['department']);
          await prefs.setString('userType', 'employee'); // Simple user type for session persistence

          // Update UserProvider with user data
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.updateFirstName(loginResult['name']);
          await userProvider.updateEmail(loginDetails['username']!);
          await userProvider.updateEmpId(loginResult['id']);
          await userProvider.updatedeoartment_id(loginResult['department']);
          await userProvider.updateFcmToken(fcmToken!);


          await FirebaseMessagingService.saveUserDataToFirebase(
            email: loginDetails['username']!,
            departmentId: loginResult['department'],
            name: loginResult['name'],
            fcmToken: fcmToken!,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome, ${loginResult['name']}!"),
              duration: const Duration(seconds: 3),
            ),
          );
          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');

            // Navigate based on user name and department
            if (!mounted) return;
            _hideBlockingLoading();

          } else {
            if (!mounted) return;
            _hideBlockingLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginResult['message']),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;
          _hideBlockingLoading();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $e'),
              duration: const Duration(seconds: 4),
            ),
          );
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          _hideBlockingLoading();
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication cancelled'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _hideBlockingLoading();
      print("Error with biometric authentication: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication failed: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  List<String> adminNames = [
    "Khalid Hassan Ali Alyami",
    "imdad",
    "ramesh",
    "Ihab Samir Mohamed Ahmed Raia",
    "Mohamed Alhadari",
    "Jamludeen Athorai",
    "santoshchavan",
    "NiteshKumbhar",
    "Mohammed Abdulaziz Khan",
    "Ali Balharth",
    "raad alghamdi"
  ];
  List<String> Prodactions = [
    "Sheets Fabrication",
    "Angles Fabrication",
    "Assembly and Welding",
    "Production",
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    const brandColor = Color(0xFF104164);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double contentWidth = constraints.maxWidth.clamp(320.0, 520.0);
        final double horizontalPadding = (contentWidth * 0.06).clamp(16.0, 28.0);
        final double verticalPadding = (screenHeight * 0.02).clamp(12.0, 22.0);
        final double titleFontSize = (contentWidth * 0.085).clamp(24.0, 36.0);
        final double subtitleFontSize = (contentWidth * 0.040).clamp(13.0, 18.0);
        final double fieldFontSize = (contentWidth * 0.040).clamp(13.0, 18.0);
        final double labelFontSize = (contentWidth * 0.036).clamp(12.0, 16.0);
        final double iconSize = (contentWidth * 0.060).clamp(18.0, 26.0);
        final double imageWidth = contentWidth;
        final double imageHeight = (screenHeight * 0.20).clamp(120.0, 180.0);

        return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: brandColor),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SelectionScreen()),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assest/images/r2.png',
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withValues(alpha: 0.10),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all((contentWidth * 0.05).clamp(16.0, 26.0)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              "Welcome",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: brandColor,
                                fontWeight: FontWeight.w800,
                                fontSize: titleFontSize,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Log in to your account",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w600,
                                fontSize: subtitleFontSize,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            TextFormField(
                              controller: emailController,
                              style: TextStyle(fontSize: fieldFontSize, color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'File No.',
                                labelStyle: TextStyle(
                                  fontSize: labelFontSize,
                                  color: brandColor.withValues(alpha: 0.85),
                                ),
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  color: brandColor.withValues(alpha: 0.9),
                                  size: iconSize,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF4F6F8),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: (screenHeight * 0.02).clamp(14.0, 18.0),
                                  horizontal: (contentWidth * 0.04).clamp(14.0, 18.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: brandColor.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: brandColor,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter File No.";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.018),
                            TextFormField(
                              obscureText: passToggle,
                              controller: passController,
                              style: TextStyle(fontSize: fieldFontSize, color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  fontSize: labelFontSize,
                                  color: brandColor.withValues(alpha: 0.85),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: brandColor.withValues(alpha: 0.9),
                                  size: iconSize,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passToggle = !passToggle;
                                    });
                                  },
                                  icon: Icon(
                                    passToggle ? Icons.visibility : Icons.visibility_off,
                                    color: brandColor.withValues(alpha: 0.9),
                                    size: iconSize,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF4F6F8),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: (screenHeight * 0.02).clamp(14.0, 18.0),
                                  horizontal: (contentWidth * 0.04).clamp(14.0, 18.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: brandColor.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: brandColor,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Password";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: FilledButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            isLoading = true; // Start loading
                                          });
                                          _showBlockingLoading();

                                          try {
                                            final loginResult = await firstFactorLogin(
                                              emailController.text.toString(),
                                              passController.text.toString(),
                                            );
                                            print("LOGIN RESULT = $loginResult");
                                            print("NAME = ${loginResult['name']}");
                                            print("ID = ${loginResult['id']}");
                                            print("DEPT = ${loginResult['department_id']}");

                                            if (loginResult['status']) {
                                              final fcmToken = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 12));


                                            // Save complete user session data
                                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                                            await prefs.setString('username', emailController.text);
                                            await prefs.setString('password', passController.text);
                                            await prefs.setBool('isLoggedIn', true);
                                            print("BEFORE SAVE");
                                            print(loginResult);
                                            await prefs.setString('userName', loginResult['name']);
                                            await prefs.setString('userId', loginResult['id']);
                                            await prefs.setString('userDepartment', loginResult['department']);
                                            await prefs.setString('userType', 'employee'); // Simple user type for session persistence
                                            // Update UserProvider with the email and first name
                                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                                            await userProvider.updateFirstName(loginResult['name']);
                                            await userProvider.updateEmail(emailController.text);
                                            await userProvider.updateEmpId(loginResult['id']);
                                            await userProvider.updatedeoartment_id(loginResult['department']);
                                            await userProvider.updateFcmToken(fcmToken!);


                                            await FirebaseMessagingService.saveUserDataToFirebase(
                                              email: emailController.text,
                                              departmentId: loginResult['department'],
                                              name: loginResult['name'],
                                              fcmToken: fcmToken!,
                                            );

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Welcome, ${loginResult['name']}!"),
                                                duration: const Duration(seconds: 3),
                                              ),
                                            );

                                              if (!mounted) return;
                                              _hideBlockingLoading();
                                              if (loginResult['name'] == "Faisal Alzahrani") {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Full_screen()),
                                                );
                                              } else if (adminNames.contains(loginResult['name'])) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Adminscreen()),
                                                );
                                              } else if (loginResult['department'] == "HRD") {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Hrdscreen()),
                                                );
                                              } else if (loginResult['department'] == "Maintenance") {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Main_Screen()),
                                                );
                                              } else if (Prodactions.contains(loginResult["department"])) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Operations_screen()),
                                                );
                                              } else {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => home_screen()),
                                                );
                                              }
                                            } else {
                                              if (!mounted) return;
                                              _hideBlockingLoading();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(loginResult['message']),
                                                  duration: Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (!mounted) return;
                                            _hideBlockingLoading();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Login failed: $e'),
                                                duration: const Duration(seconds: 4),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                isLoading = false; // Stop loading
                                              });
                                            }
                                            _hideBlockingLoading();
                                          }
                                        }
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: brandColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: (screenHeight * 0.016).clamp(12.0, 16.0),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              height: screenHeight * 0.024,
                                              width: screenHeight * 0.024,
                                              child: const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.4,
                                              ),
                                            )
                                          : Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: (contentWidth * 0.045).clamp(14.0, 18.0),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: (contentWidth * 0.03).clamp(10.0, 16.0)),
                                  SizedBox(
                                    width: (contentWidth * 0.16).clamp(56.0, 88.0),
                                    height: (screenHeight * 0.062).clamp(44.0, 54.0),
                                    child: FilledButton(
                                      onPressed: () {
                                        // Call the function for biometric login
                                        biometricLogin();
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFEAF0F3),
                                        foregroundColor: brandColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          side: BorderSide(
                                            color: brandColor.withValues(alpha: 0.18),
                                          ),
                                        ),
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              height: screenHeight * 0.024,
                                              width: screenHeight * 0.024,
                                              child: const CircularProgressIndicator(
                                                color: brandColor,
                                                strokeWidth: 2.4,
                                              ),
                                            )
                                          : Icon(
                                              Icons.fingerprint,
                                              color: brandColor,
                                              size: (contentWidth * 0.08).clamp(22.0, 34.0),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ForgetPasswordPage(),
                                  ));
                                },
                                child: Text(
                                  'Forget Password?',
                                  style: TextStyle(
                                    color: brandColor,
                                    fontSize: (contentWidth * 0.04).clamp(13.0, 18.0),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: brandColor.withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'CopyRight© جميع الحقوق محفوظة © 2025',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  fontSize: (contentWidth * 0.03).clamp(11.0, 14.0),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        );
      },
    );
  }
}
