import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nexus_kyt/auth_provider.dart';
import 'package:nexus_kyt/background_video_provider.dart';
import 'package:nexus_kyt/dashboard_screen.dart';
import 'package:nexus_kyt/face_verification_screen.dart';
import 'package:nexus_kyt/id_card_screen.dart' as id_card;
import 'package:nexus_kyt/login_screen.dart';
import 'package:nexus_kyt/profile_form_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.top, // Show top status bar
      SystemUiOverlay.bottom, // Show bottom navigation bar
    ],
  );
  // Customize the system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Transparent top bar
    systemNavigationBarColor: Colors.black,
    // systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light, // Bottom icons
    // statusBarIconBrightness: Brightness.dark, // Top icons
    // statusBarBrightness: Brightness.dark, // iOS style
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BackgroundVideoProvider()),
        // add other providers later
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state on app startup
    Future.microtask(() {
      context.read<AuthProvider>().initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // While initializing, show a loading screen
          if (!authProvider.isInitialized) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
          }

          // No token - show login screen
          if (!authProvider.isLoggedIn) {
            return const login_screen();
          }

          // Has token - navigate based on current screen
          switch (authProvider.currentScreen) {
            case 'profile_form':
              return const ProfileFormScreen();
            case 'id_card':
              return const id_card.IdCardUploadScreen();
            case 'face_verification':
              return const FaceVerificationScreen();
            case 'dashboard':
              return const DashboardScreen();
            default:
              // Default to profile form if screen is not set
              return const ProfileFormScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
