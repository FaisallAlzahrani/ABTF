import 'dart:async';
import 'home/Admins_screen_updated_new.dart';
import 'home/HRD_screen_new.dart';
import 'home/Main_Screen.dart';
import 'home/Maintanace.dart';
import 'home/Operations_screen.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Notifications System/firebase_notification.dart';
import 'Notifications System/local_notifaction.dart';
import 'login/selection_screen.dart';
import 'login/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'firebase_options.dart';

void main() {
  // Catch any errors that occur during Flutter initialization
  runZonedGuarded(() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Set up error handling for Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      print('Flutter error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    };

    // Run the app without wrapping it with UserProvider here
    runApp(const AppLoader());
  }, (error, stack) {
    // Log any errors that occur during initialization
    print('Uncaught error: $error');
    print('Stack trace: $stack');
  });
}

// Loader widget that handles initialization
class AppLoader extends StatefulWidget {
  const AppLoader({Key? key}) : super(key: key);

  @override
  _AppLoaderState createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  // Initialization state
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';
  String _debugInfo = '';


  // No need for didChangeDependencies here anymore
  @override
  void initState() {
    super.initState();
    initializeApp();
  }
Future<void> initializeApp() async {
  try {
    print("==================================================");
    print("ABTF APP INITIALIZATION STARTED");
    print("==================================================");

    setState(() {
      _debugInfo = "Starting application...\n";
    });

    print("Flutter initialized successfully.");

    // Show existing Firebase apps
    print("Firebase Apps BEFORE init: ${Firebase.apps.length}");

    setState(() {
      _debugInfo += "Firebase Apps BEFORE: ${Firebase.apps.length}\n";
    });

    print("Initializing Firebase...");

    final FirebaseApp app = Platform.isIOS ? await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: 'AIzaSyA9VSOATv5eWQ54Yu5zGd8-eCkgaJVcC_U',
      appId: '1:241071190796:ios:79a8fb36027cf6f67e4f29',
      messagingSenderId:'241071190796',
      projectId: 'towerapp-fec08',
      iosBundleId: 'com.your.bundle',
    )):await Firebase.initializeApp().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException("Firebase initialization timed out");
      },
    );

    print("==================================================");
    print("FIREBASE INITIALIZED SUCCESSFULLY");
    print("==================================================");
    print("App Name      : ${app.name}");
    print("Project ID    : ${app.options.projectId}");
    print("App ID        : ${app.options.appId}");
    print("Storage Bucket: ${app.options.storageBucket}");
    print("Messaging ID  : ${app.options.messagingSenderId}");
    print("Database URL  : ${app.options.databaseURL}");
    print("Apps AFTER    : ${Firebase.apps.length}");
    print("==================================================");

    setState(() {
      _debugInfo += "Firebase initialized successfully\n";
      _debugInfo += "Project: ${app.options.projectId}\n";
      _debugInfo += "App ID : ${app.options.appId}\n";
      _debugInfo += "Apps   : ${Firebase.apps.length}\n";
    });

    _initialized = true;
  } catch (e, stackTrace) {
    print("==================================================");
    print("FIREBASE INITIALIZATION FAILED");
    print("==================================================");
    print(e);
    print(stackTrace);
    print("==================================================");

    setState(() {
      _error = true;
      _errorMessage = e.toString();
      _debugInfo += "Firebase ERROR:\n";
      _debugInfo += "$e\n";
      _debugInfo += "$stackTrace\n";
    });

    return;
  }

  if (mounted) {
    setState(() {
      _initialized = true;
    });
  }

  print("Initializing background services...");

  try {
    await LocalNotificationsService.setupLocalNotifications();
    print("Local Notifications initialized.");
  } catch (e) {
    print("Local Notifications ERROR: $e");
  }

  try {
    FirebaseMessagingService.setupFirebaseMessaging();
    print("Firebase Messaging initialized.");
  } catch (e) {
    print("Firebase Messaging ERROR: $e");
  }

  print("Application initialization finished.");
}



  @override
  Widget build(BuildContext context) {
    // Show loading screen
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assest/images/r10.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 18),
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Preparing your app…',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_debugInfo.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _debugInfo,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show error screen
    if (_error) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B1F2A),
                  Color(0xFF111827),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      elevation: 0,
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 28),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Failed to initialize the app',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: initializeApp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // App is initialized, show the main app wrapped with UserProvider
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _providerLoaded = false;
  Widget _initialScreen = const SelectionScreen();
  
  // Admin list for navigation
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
    "raad alghamdi"
  ];
  List<String> Prodactions = [
    "Sheets Fabrication",
    "Angles Fabrication",
    "Assembly and Welding",
    "Production",
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_providerLoaded) {
      _providerLoaded = true;

      final userProvider =
      Provider.of<UserProvider>(context, listen: false);

      userProvider.loadUserData();
    }
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bool isLoggedIn =
          prefs.getBool('isLoggedIn') ?? false;

      final String? userName =
      prefs.getString('userName');

      final String? userDepartment =
      prefs.getString('userDepartment');

      if (!mounted) return;

      setState(() {
        _initialScreen = const SelectionScreen();

        _isLoading = false;
      });
    } catch (e) {
      print('Error checking login status: $e');

      if (!mounted) return;

      setState(() {
        _initialScreen = const SelectionScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TowerFactory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF104164),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF4F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF104164), width: 1.2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF104164),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
        home: _isLoading ? _initialScreen : _initialScreen,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/selection': (context) => const SelectionScreen(),
        },
      );

  }
}
