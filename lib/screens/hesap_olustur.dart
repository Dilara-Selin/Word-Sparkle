import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:last_project/screens/login.dart';

class HesapPage extends StatefulWidget {
  const HesapPage({super.key});

  @override
  State<HesapPage> createState() => _HesapPageState();
}

class _HesapPageState extends State<HesapPage> {
  late String email, password, userName, rpassword;

  final formkey = GlobalKey<FormState>();

  final firebaseAuth = FirebaseAuth.instance;

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
                        titleText(),
                        const SizedBox(height: 20),
                        nameTextField(),
                        const SizedBox(height: 20),
                        emailTextField(),
                        const SizedBox(height: 20),
                        passwordTextField(),
                        const SizedBox(height: 20),
                        signUpButton(),
                        const SizedBox(height: 10),
                        loginUpButton(),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Text titleText() {
    return const Text(
      "Merhaba,Hoşgeldiniz",
      style: TextStyle(
          fontSize: 30, color: Color(0xff31274F), fontWeight: FontWeight.bold),
    );
  }

  Center signUpButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          if (formkey.currentState!.validate()) {
            formkey.currentState!.save();

            try {
              var userResult =
                  await firebaseAuth.createUserWithEmailAndPassword(
                      email: email, password: password);
              formkey.currentState!.reset();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      "Kayıt Yapıldı , Giris sayfasına yönlendiriliyorsunuz ")));
              Navigator.pushReplacementNamed(context, "/loginPage");
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
              "Hesap Oluştur",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Center loginUpButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ),
        child: const Text(
          "Giriş Yap",
          style: TextStyle(color: Color(0xff31274F)),
        ),
      ),
    );
  }

  TextFormField nameTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
      },
      onSaved: (value) {
        userName = value!;
      },
      decoration: customInputDecoration("user name"),
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri eksiksiz giriniz";
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
