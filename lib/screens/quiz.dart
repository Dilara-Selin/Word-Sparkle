import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'constants.dart'; // constants.dart dosyasını ekledik

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

  Duration calculateNextDate(int consecutiveCorrectCount) {
    switch (consecutiveCorrectCount) {
      case 0:
        return Duration.zero; // Aynı gün
      case 1:
        return Duration(days: 1); // Bir sonraki gün
      case 2:
        return Duration(days: 7); // Bir hafta sonra
      case 3:
        return Duration(days: 30); // 1 ay sonra
      case 4:
        return Duration(days: 90); // 3 ay sonra
      case 6:
        return Duration(days: 180); // 6 ay sonra
      default:
        return Duration.zero; // Varsayılan olarak aynı gün
    }
  }

  void _loadWords() async {
    try {
      String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;

      if (kullaniciId != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(kullaniciId)
            .collection('words')
            .get();

        List<DocumentSnapshot> allWords = querySnapshot.docs;

        DateTime now = DateTime.now();
        setState(() {
          // Sadece nextTestDate bugünden önce veya bugüne eşit olan kelimeleri filtrele
          ingilizce = allWords.where((word) {
            Timestamp? nextTestDate = word.get('nextTestDate');
            if (nextTestDate != null) {
              return now.isAfter(nextTestDate.toDate()) ||
                  now.isAtSameMomentAs(nextTestDate.toDate());
            }
            return true; // Eğer nextTestDate yoksa, o kelimeyi dahil et
          }).toList();
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
        answerController.clear();
      });

      // Tarihe göre bir sonraki kelimeye geç
      DocumentSnapshot nextWord = ingilizce[currentWordIndex];
      Timestamp? nextTestDate = nextWord.get('nextTestDate');
      DateTime now = DateTime.now();

      if (nextTestDate != null && now.isBefore(nextTestDate.toDate())) {
        // Test tarihi gelmedi, bir sonraki kelimeye geç
        _nextWord();
        return;
      }

      // Test tarihi geldi, yeni soruyu göster
      setState(() {
        // Diğer işlemler...
      });
    } else {
      _showQuizFinishedScreen();
      return;
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

    // Doğru cevaplanan veya yanlış cevaplanan kelimenin test tarihini güncelle
    _updateTestDate();

    if (currentWordIndex >= questionCount - 1) {
      print('Reached question limit');
      _showQuizFinishedScreen();
      return;
    }
    _nextWord();
  }

  void _updateTestDate() async {
    try {
      DocumentSnapshot wordSnapshot = ingilizce[currentWordIndex];
      int consecutiveCorrect = wordSnapshot.get(consecutiveCorrectField) ?? 0;

      // Doğru cevaplandığında, bir sonraki test tarihini hesapla
      Duration nextTestDuration = calculateNextDate(consecutiveCorrect);

      // Yeni test tarihini hesapla ve Firebase'e kaydet
      DateTime now = DateTime.now();
      DateTime nextTestDate = now.add(nextTestDuration);

      // Güncellenen tarihi şu anki zamana ayarla
      Timestamp timestamp = Timestamp.fromDate(nextTestDate);

      // Kullanıcıya ait kelimenin referansını alın ve nextTestDate alanını güncelleyin
      await wordSnapshot.reference.update({
        'nextTestDate': timestamp,
      });
    } catch (error) {
      print('Test tarihi güncellenirken bir hata oluştu: $error');
    }
  }

  bool isTestDateValid() {
    // Burada, kullanıcının test tarihini kontrol edin ve geçerli olup olmadığını döndürün
    // Örneğin, Firebase'den test tarihini alıp geçerli tarihe karşı kontrol edebilirsiniz.
    // Örneğin:
    // DateTime testDate = getTestDateFromFirebase(); // Firebase'den test tarihini al
    // return DateTime.now().isBefore(testDate); // Şu anki tarih, test tarihinden önce mi kontrol et
    return true; // Geçici olarak her zaman geçerli olduğunu varsayalım
  }

  void _showDailyQuestionsFinishedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Günlük Sorularınız Bitmiştir'),
          content: Text('Günlük sorularınız için test tarihi geçmiştir.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Ana ekrana dön
              },
              child: Text('Ana Ekrana Dön'),
            ),
          ],
        );
      },
    );
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

  void _updateCorrectCounts(bool isCorrect) async {
    try {
      DocumentSnapshot wordSnapshot = ingilizce[currentWordIndex];

      // wordSnapshot.data()'yı Map<String, dynamic> olarak cast edin
      Map<String, dynamic>? data = wordSnapshot.data() as Map<String, dynamic>?;

      if (data == null) {
        print('Veri alınamadı.');
        return;
      }

      // Eğer artArdaDogru alanı yoksa, sıfır olarak başlatın
      if (!data.containsKey(consecutiveCorrectField)) {
        await wordSnapshot.reference.update({
          consecutiveCorrectField: 0,
        });
      }

      if (isCorrect) {
        int consecutiveCorrect = data[consecutiveCorrectField] ?? 0;
        consecutiveCorrect++;
        await wordSnapshot.reference.update({
          totalCorrectField: FieldValue.increment(1),
          consecutiveCorrectField: consecutiveCorrect,
        });

        if (consecutiveCorrect >= 6) {
          await _moveWordToKnownWords(); // Kelimeyi bilinen kelimeler havuzuna taşı
        }
      } else {
        await wordSnapshot.reference.update({
          consecutiveCorrectField: 0,
          totalWrongField: FieldValue.increment(1),
        });
      }

      // Son doğru tarihi güncelle
      await updateLastCorrectDate(wordSnapshot.reference);
    } catch (error) {
      print('Doğru sayısı güncellenirken bir hata oluştu: $error');
    }
  }

  Future<void> updateLastCorrectDate(DocumentReference wordRef) async {
    try {
      String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;
      if (kullaniciId != null) {
        // Güncellenen tarihi şu anki zamana ayarla
        DateTime now = DateTime.now();
        Timestamp timestamp = Timestamp.fromDate(now);

        // Kullanıcıya ait kelimenin referansını alın ve lastCorrectDate alanını güncelleyin
        await wordRef.update({
          'lastCorrectDate': timestamp,
        });
      } else {
        print('Kullanıcı oturumu açmamış.');
      }
    } catch (error) {
      print('Son doğru tarihi güncellenirken bir hata oluştu: $error');
    }
  }

  Future<void> _moveWordToKnownWords() async {
    try {
      DocumentSnapshot wordSnapshot = ingilizce[currentWordIndex];

      // Kullanıcının UID'sini alın
      String? kullaniciId = FirebaseAuth.instance.currentUser?.uid;
      if (kullaniciId != null) {
        // Kullanıcının bilinen kelimeler koleksiyonunu oluşturun
        await FirebaseFirestore.instance
            .collection('users')
            .doc(kullaniciId)
            .collection('known_words')
            .add({
          'ingilizce': wordSnapshot.get('ingilizce'),
          'turkce': wordSnapshot.get('turkce'),
          // Diğer alanlar...
        });

        // Kelimeyi orijinal koleksiyondan silme
        await wordSnapshot.reference.delete();
        print('Kelime bilinen kelimeler havuzuna taşındı.');
      } else {
        print('Kullanıcı oturumu açmamış.');
      }
    } catch (error) {
      print('Kelime taşınırken bir hata oluştu: $error');
    }
  }
}
