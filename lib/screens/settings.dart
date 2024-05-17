import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _questionCount = 10;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFBE1EF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height:
                      20), // Geri okunu biraz daha aşağı almak için boşluk ekliyoruz
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Ayarlar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 40,
                        color: Colors.black, // İkonun rengini siyah yaptık
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Geri ok ve başlık altına boşluk ekliyoruz
              Text(
                'Soru Sayısı: $_questionCount',
                style: TextStyle(fontSize: 20),
              ),
              Slider(
                value: _questionCount,
                min: 1,
                max: 20,
                divisions: 19,
                label: _questionCount.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _questionCount = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  // Kullanıcının seçtiği soru sayısını kaydet
                  _saveQuestionCount(_questionCount);
                  // Ayarlar sayfasını kapatarak önceki sayfaya dön
                  Navigator.of(context).pop();
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveQuestionCount(double questionCount) async {
    try {
      String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(kullaniciId)
          .collection('settings')
          .doc('user_settings')
          .set({'questionCount': questionCount});
      print('Seçilen soru sayısı Firestore\'a kaydedildi: $questionCount');
    } catch (error) {
      print('Soru sayısı kaydedilirken bir hata oluştu: $error');
    }
  }
}
