import 'package:flutter/material.dart';
import 'package:last_projectt/customs/custom.elevatedbutton.dart';
import 'package:last_projectt/screens/addword.dart';
import 'package:last_projectt/screens/quiz.dart';
import 'package:last_projectt/screens/settings.dart';
import 'package:last_projectt/screens/SuccessModulePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _kullaniciId;

  @override
  void initState() {
    super.initState();
    _setKullaniciId();
  }

  Future<void> _setKullaniciId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _kullaniciId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFBE1EF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  'WORD SPARKLE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: CustomElevatedButton(
                  onpressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddWord()),
                    );
                  },
                  content: 'Kelime Ekle',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: CustomElevatedButton(
                  onpressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const Question(questionCount: 10)),
                    );
                  },
                  content: 'Quiz',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: CustomElevatedButton(
                  onpressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SuccessModulePage(kullaniciId: _kullaniciId),
                      ),
                    );
                  },
                  content: 'Başarı İstatistiği',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings,
                          size: 60, color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
