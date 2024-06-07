import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/home_screen.dart';

class UpdateScreen extends StatefulWidget {
  final int id;
  const UpdateScreen({
    super.key,
    required this.id,
  });

  @override
  State<UpdateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<UpdateScreen> {
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
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getData();
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

  void getData() async {
    String docId = (widget.id).toString();
    var productDoc =
        await FirebaseFirestore.instance.collection('product').doc(docId).get();

    _titleController.text = productDoc['title'];
    _priceController.text = productDoc['price'];
    _contentController.text = productDoc['content'];
    _regionController.text = productDoc['region'];
    url = productDoc['imagePath'];
  }

  Future<void> updateInfo() async {
    _titleController.text = _titleController.text.trim();
    _priceController.text = _priceController.text.trim();
    _contentController.text = _contentController.text.trim();
    _regionController.text = _regionController.text.trim();

    String docId = (widget.id).toString();

    if (_titleController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _contentController.text.isNotEmpty &&
        _regionController.text.isNotEmpty) {
      // 제품 컬렉션에서 마지막 문서 가져오기
      await FirebaseFirestore.instance.collection('product').doc(docId).update({
        'title': _titleController.text,
        'price': _priceController.text,
        'content': _contentController.text,
        'region': _regionController.text,
        // 다른 필드들도 필요에 따라 추가
      });

      // 제품 수정
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
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.fill,
              ),
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
                  updateInfo();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text('수정하기')),
            ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('product')
                      .doc((widget.id).toString())
                      .delete();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text('삭제하기'))
          ],
        ),
      ),
    );
  }
}
