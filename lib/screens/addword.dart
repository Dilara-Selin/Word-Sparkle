import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home.dart';

class AddWord extends StatefulWidget {
  const AddWord({Key? key}) : super(key: key);

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  String? _imageUrl;
  final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _turkceController = TextEditingController();
  final _ingilizceController = TextEditingController();
  final _cumleController = TextEditingController();

  @override
  void dispose() {
    _turkceController.dispose();
    _ingilizceController.dispose();
    _cumleController.dispose();
    super.dispose();
  }

  Future<void> getImageGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No Image Picked');
      }
    });
  }

  Future<void> addDataToFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      final wordsRef =
          _firestore.collection('users').doc(userId).collection('words');

      if (_image != null) {
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() async {
          _imageUrl = await storageReference.getDownloadURL();
        });
      }

      final kelimeData = {
        'turkce': _turkceController.text,
        'ingilizce': _ingilizceController.text,
        'cumle': _cumleController.text,
        'imageUrl': _imageUrl,
        'nextTestDate': Timestamp.now(),
        'addedDate': Timestamp.now(),
      };

      await wordsRef.add(kelimeData);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'KELİME EKLE',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
              InkWell(
                onTap: getImageGallery,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.75),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 30,
                            ),
                          ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _turkceController,
                              label: 'Türkçe Kelime',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Türkçe kelime boş olamaz';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _ingilizceController,
                              label: 'İngilizce Kelime',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'İngilizce kelime boş olamaz';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _cumleController,
                        label: 'Örnek Cümleler',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Örnek cümleler boş olamaz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await addDataToFirestore();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          } else {
                            _showSnackBar(
                                context, 'Lütfen tüm alanları doldurun');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor: Colors.black.withOpacity(0.75),
                        ),
                        child: const Text(
                          'EKLE',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
