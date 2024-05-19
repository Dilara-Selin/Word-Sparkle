import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:last_projectt/screens/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  Future<Uint8List> _getImage(BuildContext context, String imageName) async {
    final firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(imageName);
    final String downloadURL = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(Uri.parse(downloadURL));
    return downloadData.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Uint8List>(
              future: _getImage(context, 'Word Sparkle.png'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Container(
                      width: 200,
                      height: 200,
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    return Text(
                      'Image not found',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return Container(); // Hata durumları için boş bir konteyner döndürün
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
