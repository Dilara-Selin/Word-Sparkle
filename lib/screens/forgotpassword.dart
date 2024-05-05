import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_sparkle/screens/authservice.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  late String email, password, userName, rpassword;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Password reset link sent ! Check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  final formkey = GlobalKey<FormState>();

  final firebaseAuth = FirebaseAuth.instance;

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFCE4EC),
        appBar: AppBar(),
        body: SingleChildScrollView(
            child: Center(
          child: Padding(
            padding: PaddingItems.horizontalPadding,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(
                height: 130,
              ),
              const Text(
                "Forgot Password \n\nSifrenizi size e posta yoluyla gönderebilmemiz için email adresinizi giriniz.",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff31274F),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              nameTextField(),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: TextButton(
                  onPressed: passwordReset,
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
                        "Gönder",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/loginPage");
                      },
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(color: Color(0xff31274F)),
                      ),
                    ),
                  )),
            ]),
          ),
        )));
  }

  Text forgotPasswordText() {
    return const Text(
      "Forgot Password",
      style: TextStyle(fontSize: 20, color: Color(0xff31274F)),
    );
  }

  TextFormField nameTextField() {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz.";
        } else {}
      },
      onSaved: (value) {
        email = value!;
      },
    );
  }
}

class PaddingItems {
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 20);
}
