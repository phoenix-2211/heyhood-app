import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hood_officials/core/constants/app_colors.dart';
import 'package:hood_officials/screens/auth/officials_splash_screen.dart';

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
        appId: "1:269763727222:android:6196d6f4778c665b003457",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const HoodOfficialsApp());
}

class HoodOfficialsApp extends StatelessWidget {
  const HoodOfficialsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hood Officials',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBg,
        colorScheme: ColorScheme.light(
          primary: saffron,
          secondary: green,
          background: lightBg,
          surface: lightBg,
        ),
        textTheme: GoogleFonts.hankenGroteskTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const OfficialsSplashScreen(),
    );
  }
}
