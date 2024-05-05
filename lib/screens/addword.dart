import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:word_sparkle/screens/home.dart';

class AddWord extends StatefulWidget {
  const AddWord({super.key});

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  String? _imageUrl;
  final picker = ImagePicker();

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // widget.imgUrl = null;
      } else {
        print("No Image Picked");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController turkceController = TextEditingController();
    TextEditingController ingilizceController = TextEditingController();
    TextEditingController cumleController = TextEditingController();

    Future<void> addDataToFirestore() async {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        String userId = user.uid;
        CollectionReference usersRef = _firestore.collection('users');
        // Reference to the subcollection
        CollectionReference wordsRef = usersRef.doc(userId).collection('words');

        if (_image != null) {
          Reference storageReference = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now().millisecondsSinceEpoch.toString()}');
          UploadTask uploadTask = storageReference.putFile(_image!);
          await uploadTask.whenComplete(() async {
            _imageUrl = await storageReference.getDownloadURL();
          });
        }

        Map<String, dynamic> kelimeData = {
          'turkce': turkceController.text,
          'ingilizce': ingilizceController.text,
          'cumle': cumleController.text,
          'imageUrl': _imageUrl,
        };

        await wordsRef.add(kelimeData);
      }
    }

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFFFBE1EF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: deviceWidth,
              height: deviceHeight / 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFBE1EF),
              ),
              child: Row(
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
                  const Padding(
                    padding: EdgeInsets.only(left: 90),
                    child: Text(
                      "KELİME EKLE",
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                getImageGallery();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: _image != null
                        ? Image.file(_image!.absolute, fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 30,
                            ),
                          )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Türkçe Kelime",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: TextField(
                              controller: turkceController,
                              decoration: const InputDecoration(
                                  filled: true, fillColor: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "İngilizce Kelime",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: TextField(
                              controller: ingilizceController,
                              decoration: const InputDecoration(
                                  filled: true, fillColor: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Örnek Cümleler",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 200,
                child: TextField(
                  controller: cumleController,
                  expands: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ElevatedButton(
                onPressed: () async {
                  print(turkceController.text);
                  print(ingilizceController.text);
                  print(cumleController.text);

                  await addDataToFirestore();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: Colors.black.withOpacity(0.75),
                ),
                child: const Text("EKLE",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
