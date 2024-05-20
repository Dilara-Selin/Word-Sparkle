import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:last_projectt/customs/customtextbutton.dart';
import 'package:last_projectt/screens/authservice.dart';
import 'package:last_projectt/screens/forgotpassword.dart';
import 'package:last_projectt/screens/home.dart';
import 'package:last_projectt/screens/signup.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  final formkey = GlobalKey<FormState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final AuthService authService = AuthService();

  late final String email;
  late final String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Merhaba, Hoşgeldiniz',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color(0xff31274F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      nameTextField(),
                      const SizedBox(height: 30),
                      passwordTextField(),
                      const SizedBox(height: 30),
                      Center(
                        child: CustomTextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                            ),
                          ),
                          buttonText: 'Şifremi Unuttum',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              formkey.currentState!.save();
                              try {
                                await firebaseAuth.signInWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              } catch (e) {
                                print(e.toString());
                              }
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: const Color(0xff31274F),
                            ),
                            child: const Center(
                              child: Text(
                                'Giriş Yap',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: CustomTextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          ),
                          buttonText: 'Hesap Oluştur',
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: CustomTextButton(
                          onPressed: () async {
                            final result = await authService.signInAnonymous();
                            if (result != null) {
                              await Navigator.pushReplacementNamed(
                                  context, '/homePage');
                            } else {
                              print('Hata ile karşılaşıldı');
                            }
                          },
                          buttonText: 'Misafir Girişi',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField nameTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri Eksiksiz Doldurunuz';
        }
        return null;
      },
      onSaved: (value) {
        email = value!;
      },
      decoration: customInputDecoration('Email'),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri eksiksiz giriniz';
        }
        return null;
      },
      onSaved: (value) {
        password = value!;
      },
      decoration: customInputDecoration('Şifre'),
    );
  }

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
    );
  }
}
