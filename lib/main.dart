import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Stream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      home: const SplashPage(), // Mulai dari splash page
    );
  }
}
