import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellostay/screens/Splash.dart';
import 'package:hellostay/screens/bottom_nav/bottom_Nav_bar.dart';
import 'package:hellostay/screens/loginScreen.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HELLOSTAY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: const SplashScreen(),
      // home:LoginPage(),
    );
  }
}


