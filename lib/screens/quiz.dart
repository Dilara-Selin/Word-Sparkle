import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final double questionCount;

  const Question({Key? key, required this.questionCount}) : super(key: key);

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
            .limit(questionCount.toInt()) // İstenen kadar kelimeyi al
            .get();
        setState(() {
          ingilizce = querySnapshot.docs;
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
    setState(() {
      currentWordIndex++;
      if (currentWordIndex >= ingilizce.length) {
        currentWordIndex = 1;
      }
    });
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
                decoration: BoxDecoration(
                  color: Color(0xFFFBE1EF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
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
    if (ingilizce.isEmpty || currentWordIndex >= ingilizce.length) {
      print('No more words available');
      return;
    }

    String? correctAnswer = ingilizce[currentWordIndex].get('turkce');
    if (correctAnswer != null &&
        answer.toLowerCase() == correctAnswer.toLowerCase()) {
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
    } else {
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
    }

    if (currentWordIndex >= questionCount) {
      print('Reached question limit');
      return;
    }
    _nextWord();
  }
}
