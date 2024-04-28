import 'package:bccapp/views/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAmLedPhPzMJVW_xXpiB9VtOiNQLLtJ5DI",
            authDomain: "countcolony-7566d.firebaseapp.com",
            projectId: "countcolony-7566d",
            storageBucket: "countcolony-7566d.appspot.com",
            messagingSenderId: "154231204696",
            appId: "1:154231204696:web:dd502c1a29a56622fc132d",
            measurementId: "G-H3VZZH7DKH"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue.shade50,
        appBarTheme: AppBarTheme(backgroundColor: Colors.blue.shade50),
        fontFamily: 'Times New Roman',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
