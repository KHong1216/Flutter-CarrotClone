import 'package:carrot_clone/screen/update_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/chatting_screen.dart';

class ProductDetail extends StatelessWidget {
  final int id;
  final String productName;
  final String ImagePath;
  final String sellUser;
  final String content;
  final String price;

  ProductDetail({
    Key? key,
    required this.id,
    required this.productName,
    required this.ImagePath,
    required this.sellUser,
    required this.content,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: productName,
      child: Column(
        children: [
          SizedBox(
              height: 280,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.network(
                  ImagePath,
                ),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.person_2_outlined,
                size: 50,
              ),
              const SizedBox(
                width: 20.0,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '판매자 : ',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(
                        sellUser,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Text(
            '내용',
            style: TextStyle(fontSize: 15.0),
          ),
          const Divider(),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                content,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$price원'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            FirebaseAuth.instance.currentUser!.email == sellUser
                                ? UpdateScreen(
                                    id: id,
                                  )
                                : ChattingScreen(
                                    id: id.toString(),
                                    name: productName,
                                    sellUser: sellUser,
                                    price: price,
                                  )));
                  },
                  child: Text(
                      FirebaseAuth.instance.currentUser!.email == sellUser
                          ? '수정하기'
                          : '채팅하기'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
