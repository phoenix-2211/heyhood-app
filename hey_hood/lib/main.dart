import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hey_hood/core/constants/app_colors.dart';
import 'package:hey_hood/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDetZVdCC3x0PGg_ZuUw2JXZwVScVGoWjI",
        authDomain: "hey-hood-prod.firebaseapp.com",
        projectId: "hey-hood-prod",
        storageBucket: "hey-hood-prod.firebasestorage.app",
        messagingSenderId: "269763727222",
        appId: "1:269763727222:android:37f303c5294f4035003457",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const HeyHoodApp());
}

class HeyHoodApp extends StatelessWidget {
  const HeyHoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hey Hood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.dark(
          primary: saffron,
          secondary: saffron,
          background: darkBg,
          surface: darkSurface,
        ),
        textTheme: GoogleFonts.hankenGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
