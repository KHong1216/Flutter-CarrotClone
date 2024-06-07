import 'package:carrot_clone/screen/chat_screen.dart';
import 'package:carrot_clone/screen/create_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/layout/product_detail.dart';
import 'package:carrot_clone/screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 3, vsync: this);
    controller.addListener(tabListener);
  }

  //컨트롤러 붙은거는 항상 initState 후 dispose 필수!!
  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  //탭 변경시 실행할 함수
  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '대학교 책 중고거래',
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: '채팅'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined), label: '프로필')
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CreateScreen()));
        },
        child: Icon(Icons.add),
      ),
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(), //스크롤해서 넘길 수 없게
        controller: controller,
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('product')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final productDocs = snapshot.data!.docs;

                return ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.network(
                              productDocs[index]['imagePath'],
                            ),
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 250,
                                height: 25,
                                child: Text(
                                  productDocs[index]['title'],
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                height: 25,
                                child: Row(
                                  children: [
                                    Text(productDocs[index]['region'],
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12.0)),
                                    const SizedBox(
                                      width: 6.0,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      height: 25,
                                      child: Text(
                                          '${productDocs[index]['price']}원',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0)),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductDetail(
                                  id: int.parse(productDocs[index]['id']),
                                  ImagePath: productDocs[index]['imagePath'],
                                  sellUser: productDocs[index]['sellUser'],
                                  content: productDocs[index]['content'],
                                  price: productDocs[index]['price'],
                                  productName: productDocs[index]['title'],
                                )));
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemCount: productDocs.length,
                );
              }),
          Center(
            child: ChatScreen(user: FirebaseAuth.instance.currentUser!),
          ),
          ProfileScreen(user: FirebaseAuth.instance.currentUser),
        ],
      ),
    );
  }
}
