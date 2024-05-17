import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final double questionCount;

  const Question({super.key, required this.questionCount});

  @override
  _QuestState createState() => _QuestState();
}

class _QuestState extends State<Question> {
  final answerController = TextEditingController();
  List<DocumentSnapshot> ingilizce = [];
  int currentWordIndex = 0;
  late int questionCount;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadWords() async {
    try {
      String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;

      if (kullaniciId != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(kullaniciId)
            .collection('words')
            .limit(questionCount) // İstenen kadar kelimeyi al
            .get();
        setState(() {
          ingilizce = querySnapshot.docs;
          currentWordIndex = 0; // Yeni kelimeler yüklendiğinde başlangıca dön
        });
        print('Words loaded: ${ingilizce.length}');
      } else {
        print('User ID is null');
      }
    } catch (error) {
      print('Failed to load words: $error');
    }
  }

  void _nextWord() {
    if (currentWordIndex < questionCount - 1 &&
        currentWordIndex < ingilizce.length - 1) {
      setState(() {
        currentWordIndex++;
      });
    } else {
      _showQuizFinishedScreen();
    }
  }

  void _loadSettings() async {
    try {
      String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;
      DocumentSnapshot settingsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(kullaniciId)
          .collection('settings')
          .doc('user_settings')
          .get();
      setState(() {
        questionCount = settingsDoc.exists
            ? (settingsDoc.data() as Map<String, dynamic>)['questionCount']
                    ?.toInt() ??
                10
            : 10; // varsayılan değer
      });
      _loadWords(); // Ayarlar yüklendikten sonra kelimeleri yükle
    } catch (error) {
      print('Kullanıcı ayarları yüklenirken bir hata oluştu: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBE1EF),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildImageWidget(),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFBE1EF)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            ingilizce.isEmpty ||
                                    currentWordIndex >= ingilizce.length
                                ? 'No word available'
                                : ingilizce[currentWordIndex].get('ingilizce'),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            ingilizce.isEmpty ||
                                    currentWordIndex >= ingilizce.length
                                ? 'No sentence available'
                                : ingilizce[currentWordIndex].get('cumle'),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 23.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: answerController,
                  decoration: InputDecoration(labelText: 'answer'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _checkAnswer(answerController.text);
                },
                child: Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (ingilizce.isNotEmpty && currentWordIndex < ingilizce.length) {
      String imageUrl = ingilizce[currentWordIndex].get('imageUrl') ?? '';
      if (imageUrl.isNotEmpty) {
        return Image.network(
          imageUrl,
          height: 250,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        );
      }
    }
    // Varsayılan bir resim göster
    return Image.asset(
      "images/beyaz.jpg",
      height: 250,
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    );
  }

  void _checkAnswer(String answer) {
    if (ingilizce.isEmpty || currentWordIndex >= questionCount) {
      print('Quiz bitti');
      _showQuizFinishedScreen();
      return;
    }

    String? correctAnswer = ingilizce[currentWordIndex].get('turkce');
    if (correctAnswer != null &&
        answer.toLowerCase() == correctAnswer.toLowerCase()) {
      // Doğru cevaplandığında
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Your answer is correct.'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // Toplam doğru sayısını artır ve ard arda doğru sayısını güncelle
      _updateCorrectCounts(true);
    } else {
      // Yanlış cevaplandığında
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.close, color: Colors.white),
              SizedBox(width: 8),
              Text('Your answer is incorrect.'),
            ],
          ),
          duration: Duration(seconds: 1, milliseconds: 30),
          backgroundColor: Colors.red,
        ),
      );

      // Toplam doğru sayısını sıfırla ve ard arda doğru sayısını sıfırla
      _updateCorrectCounts(false);
    }

    if (currentWordIndex >= questionCount - 1) {
      print('Reached question limit');
      _showQuizFinishedScreen();
      return;
    }
    _nextWord();
  }

  void _showQuizFinishedScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Bitti'),
          content: Text('Tebrikler! Quiz tamamlandı.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Geri dönme fonksiyonu
              },
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _updateCorrectCounts(bool isCorrect) {
    // Toplam doğru sayısını artır veya sıfırla
    String totalCorrectField = 'toplamDogru';
    String consecutiveCorrectField = 'artArdaDogru';
    String totalWrongField = 'toplamYanlis';

    // Doğru sayısını artır veya sıfırla
    if (isCorrect) {
      // Doğru cevaplandığında
      ingilizce[currentWordIndex].reference.update({
        totalCorrectField: FieldValue.increment(1),
        consecutiveCorrectField: FieldValue.increment(1),
      });
    } else {
      // Yanlış cevaplandığında ard arda doğru sayısını sıfırla
      ingilizce[currentWordIndex].reference.update({
        consecutiveCorrectField: 0,
        totalWrongField: FieldValue.increment(1),
      });
    }
  }
}
