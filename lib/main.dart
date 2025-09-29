import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus_kyt/auth_provider.dart';
import 'package:nexus_kyt/background_video_provider.dart';
import 'package:nexus_kyt/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: login_screen(),
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
    return Scaffold();
  }
}
