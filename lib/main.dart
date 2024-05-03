import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dersleri/demos/SplashScreen.dart';
import 'package:flutter_dersleri/demos/forgot_password.dart';
import 'package:flutter_dersleri/demos/hesap_olustur.dart';
import 'package:flutter_dersleri/demos/home_page.dart';
import 'package:flutter_dersleri/demos/login_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SplashScreen(),
      routes: {
        "/forgotPasswordPage": (context) => ForgotPassword(),
        "/loginPage": (context) => LoginPage(),
        "/signUpPage": (context) => const HesapPage(),
        "/homePage": (context) => const HomePage()
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        iconTheme: const IconThemeData(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
