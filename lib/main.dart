import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isFirstTime = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAppStatus();
  }

  void checkAppStatus() async {
    final prefs = await SharedPreferences.getInstance();

    bool? loginStatus = prefs.getBool("isLoggedIn");
    bool? seenOnboarding = prefs.getBool("seenOnboarding");

    setState(() {
      isLoggedIn = loginStatus ?? false;
      isFirstTime = !(seenOnboarding ?? false);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduAccess AI',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: isLoggedIn
          ? const DashboardScreen()
          : isFirstTime
          ? const OnboardingScreen()
          : const LoginScreen(),
    );
  }
}
