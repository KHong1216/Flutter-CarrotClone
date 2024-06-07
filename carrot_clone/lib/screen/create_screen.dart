import 'dart:io';
import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _contentController = TextEditingController();
  final _regionController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final stroage = FirebaseStorage.instance;
  User? loginUser;
  final bool isImage = false;
  ImagePicker picker = ImagePicker();
  File? selectedImage;
  String imagePath = '';

//   final String name;
//   final int id;
//   final int price;
//   final String sellUser;
//   final String region;
//   final String content;
//   final String imagePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loginUser = user;
      }
    } catch (err) {
      debugPrint('getUser ; $err');
    }
  }

  Future<void> createInfo() async {
    _titleController.text = _titleController.text.trim();
    _priceController.text = _priceController.text.trim();
    _contentController.text = _contentController.text.trim();
    _regionController.text = _regionController.text.trim();

    int id = 1;

    if (_titleController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _contentController.text.isNotEmpty &&
        _regionController.text.isNotEmpty) {
      // 제품 컬렉션에서 마지막 문서 가져오기
      var querySnapshot = await FirebaseFirestore.instance
          .collection('product')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      // 새로운 id 생성
      if (querySnapshot.docs.isNotEmpty) {
        var lastDoc = querySnapshot.docs.first;
        id = int.parse(lastDoc['id']) + 1;
      }

      var ref = stroage.ref().child('Image/$id.png');
      await ref.putFile(selectedImage!);
      final url = await ref.getDownloadURL();

      // 제품 추가
      FirebaseFirestore.instance.collection('product').doc(id.toString()).set({
        'title': _titleController.text,
        'price': _priceController.text,
        'content': _contentController.text,
        'region': _regionController.text,
        'imagePath': url,
        'timestamp': Timestamp.now(),
        'sellUser': FirebaseAuth.instance.currentUser!.email,
        'id': id.toString()
      }).then((_) {
        // 제품 추가 후 실행할 코드
      }).catchError((error) {
        print('Error adding product: $error');
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    await Permission.camera.request();
    await Permission.storage.request();
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '상품 등록하기',
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: (selectedImage != null)
                  ? Image.file(
                      selectedImage!,
                      fit: BoxFit.fill,
                    )
                  : IconButton(
                      onPressed: () {
                        pickImageFromGallery();
                      },
                      icon: Icon(Icons.image)),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: _regionController,
              decoration: InputDecoration(labelText: '지역'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: '금액'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '내용'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
                onPressed: () {
                  createInfo();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text('등록하기'))
          ],
        ),
      ),
    );
  }
}
