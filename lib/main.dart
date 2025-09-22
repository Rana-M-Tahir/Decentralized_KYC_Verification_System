import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus_kyt/login_screen.dart';

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
    statusBarColor: Colors.transparent, // Transparent top bar
    systemNavigationBarColor: Colors.transparent,
    // systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light, // Bottom icons
    // statusBarIconBrightness: Brightness.dark, // Top icons
    // statusBarBrightness: Brightness.dark, // iOS style
  ));
  runApp(const MyApp());
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

// class Splash_Screen extends StatefulWidget {
//   @override
//   State<Splash_Screen> createState() => _Splash_ScreenState();
// }

// ignore: camel_case_types
// class _Splash_ScreenState extends State<Splash_Screen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => login_screen(),
//           ));
//     });
//   }

//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF000000),
//               Color.fromARGB(255, 114, 107, 107),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/images/logo.png', // make sure your image is inside assets folder
//                 width: size.width * 0.3,
//                 height: size.width * 0.3,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Text('NexusKYT',
//                   style: TextStyle(
//                       fontSize: size.width * 0.06,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1.2))
//             ],
//           ),
//         ));
//   }
// }
