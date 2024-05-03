import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dersleri/demos/forgot_password.dart';
import 'package:flutter_dersleri/services/auth_service.dart';
import 'package:flutter_dersleri/widget/custom_text_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  late String email, password, userName, rpassword;

  final formkey = GlobalKey<FormState>();

  final firebaseAuth = FirebaseAuth.instance;

  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 160),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Merhaba,Hoşgeldiniz",
                        style: TextStyle(
                            fontSize: 30,
                            color: Color(0xff31274F),
                            fontWeight: FontWeight.bold),
                      ),
                      nameTextField(),
                      const SizedBox(height: 30),
                      passwordTextField(),
                      const SizedBox(height: 10),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ForgotPassword();
                                  }));
                                },
                                child: const Text("Forgot Password ?",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )
                            ],
                          )),
                      // Center(
                      //     child: CustomTextButton(
                      //         onPressed: () => Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => ForgotPassword()),
                      //             ),
                      //         buttonText: "Sifremi Unuttum")),

                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              formkey.currentState!.save();
                              try {
                                final userResult = await firebaseAuth
                                    .signInWithEmailAndPassword(
                                        email: email, password: password);
                                Navigator.pushReplacementNamed(
                                    context, "/homePage");
                                print(userResult.user!.email);
                              } catch (e) {
                                print(e.toString());
                              }
                            } else {}
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
                                "Giriş Yap",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                          child: CustomTextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, "/signUpPage"),
                              buttonText: "Hesap Olustur")),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: CustomTextButton(
                            onPressed: () async {
                              final result =
                                  await authService.signInAnonymous();
                              if (result != null) {
                                Navigator.pushReplacementNamed(
                                    context, "/homePage");
                              } else {
                                print("Hata ile karsılasıldı");
                              }
                            },
                            buttonText: "Misafir Girisi"),
                      ),
                      // Center(
                      //   child: CustomTextButton(
                      //       onPressed: () async {
                      //         final result =
                      //             await authService.forgotPassword(email);
                      //       },
                      //       buttonText: "Sifremi Unuttum"),
                      // )
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

  void signIn() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      final result = await authService.signIn(email, password);
      print(result);
    }
  }

  TextFormField nameTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        email = value!;
      },
      decoration: customInputDecoration("email"),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri eksiksiz giriniz";
        } else {}
      },
      onSaved: (value) {
        password = value!;
      },
      decoration: customInputDecoration("password"),
    );
  }
}

InputDecoration customInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.grey,
      )));
}

class PaddingItems {
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 20);
}
