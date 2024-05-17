import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants.dart'; // Add this import

class SuccessModulePage extends StatelessWidget {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  final String kullaniciId;

  SuccessModulePage({required this.kullaniciId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFBE1EF),
        title: Text(
          'Başarı Modülü',
          style: TextStyle(
            color: Colors.black.withOpacity(0.75),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              Uint8List? result = await _captureAndConvertToPdf(context);
              if (result != null) {
                Printing.layoutPdf(onLayout: (_) => result);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('PDF Oluşturma Hatası'),
                    content: Text('PDF oluşturulurken bir hata oluştu.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Tamam'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(kullaniciId)
            .collection('words')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Veri alınamadı: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  height: 0.5,
                ),
                RepaintBoundary(
                  key: _printKey,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var wordData = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;

                          int correctCount = wordData[totalCorrectField] ?? 0;
                          int incorrectCount = wordData[totalWrongField] ?? 0;

                          int totalAttempts = correctCount + incorrectCount;
                          double successRate = totalAttempts != 0
                              ? (correctCount / totalAttempts) * 100
                              : 0.0;

                          return Card(
                            color: Colors.black.withOpacity(0.55),
                            child: ListTile(
                              title: Text(
                                'Kelime ${index + 1}',
                                style: TextStyle(
                                  color: Color(0xFFFBE1EF),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Doğru Sayısı: $correctCount',
                                    style: TextStyle(
                                      color: Color(0xFFFBE1EF),
                                    ),
                                  ),
                                  Text(
                                    'Yanlış Sayısı: $incorrectCount',
                                    style: TextStyle(
                                      color: Color(0xFFFBE1EF),
                                    ),
                                  ),
                                  Text(
                                    'Başarı Oranı: ${successRate.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: Color(0xFFFBE1EF),
                                    ),
                                  ),
                                  Text(
                                    'En Son Güncelleme: ${wordData['last_update']}',
                                    style: TextStyle(
                                      color: Color(0xFFFBE1EF),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Color(0xFFFBE1EF),
    );
  }

  Future<Uint8List?> _captureAndConvertToPdf(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary =
          _printKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      pdf.addPage(pw.Page(
          build: (pw.Context context) => pw.Image(pw.MemoryImage(pngBytes))));

      Uint8List? result = await pdf.save();
      return result;
    } catch (e) {
      print("PDF oluşturma hatası: $e");
      return null;
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Bir hata oluştu: ${snapshot.error}');
        }
        if (snapshot.hasData && snapshot.data != null) {
          User user = snapshot.data!;
          String kullaniciId = user.uid;
          return MaterialApp(
            home: SuccessModulePage(kullaniciId: kullaniciId),
          );
        }
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Giriş yapın.'),
            ),
          ),
        );
      },
    );
  }
}
