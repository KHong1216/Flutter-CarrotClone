import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carrot_clone/layout/default_layout.dart';

class ChattingScreen extends StatefulWidget {
  final String id;
  final String name;
  final String sellUser;
  final String price;

  const ChattingScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.sellUser,
    required this.price,
  }) : super(key: key);

  @override
  State<ChattingScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChattingScreen> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loginUser;
  //User? othorUser;
  String otherUser = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loginUser = user;
        print(loginUser!.email);
      }
    } catch (err) {
      print('getUser: $err');
    }
  }

  void _sendMessage() {
    _controller.text = _controller.text.trim();

    if (_controller.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chat')
          .where('product', isEqualTo: widget.name)
          .where('from', isEqualTo: loginUser!.email)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final chatDoc = querySnapshot.docs.first;
          FirebaseFirestore.instance.collection('chat').add({
            'text': _controller.text,
            'to': loginUser!.email,
            'from': chatDoc['to'],
            'product': widget.name,
            'productId': widget.id,
            'price': widget.price,
            'sellUser': widget.sellUser,
            'timestamp': Timestamp.now()
          }).then((_) {
            _controller.clear();
            _fetchMessages();
            // 메시지 전송 후 텍스트 필드 클리어
          }).catchError((error) {
            print('Error sending message: $error');
          });
        } else {
          FirebaseFirestore.instance.collection('chat').add({
            'text': _controller.text,
            'to': loginUser!.email,
            'from': widget.sellUser,
            'product': widget.name,
            'productId': widget.id,
            'price': widget.price,
            'sellUser': widget.sellUser,
            'timestamp': Timestamp.now()
          }).then((_) {
            _controller.clear(); // 메시지 전송 후 텍스트 필드 클리어
          }).catchError((error) {
            print('Error sending message: $error');
          });
        }
      }).catchError((error) {
        print('Error retrieving chat document: $error');
      });
    }
  }

  void _fetchMessages() {
    FirebaseFirestore.instance
        .collection('chat')
        .where('product', isEqualTo: widget.name) // 상품명 조건
        .where('from', isEqualTo: loginUser!.email) // 현재 사용자 조건
        .orderBy('timestamp', descending: true)
        .get()
        .then((querySnapshot) {
      // querySnapshot을 사용하여 가져온 메시지를 처리하는 코드
      // 예를 들어, querySnapshot.docs를 사용하여 가져온 메시지 목록에 접근할 수 있음
    }).catchError((error) {
      print('Error retrieving messages: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: '${widget.name} 채팅룸',
        child: Column(
          children: [
            Container(
              height: 100,
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset('assets/image/book.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.name),
                      Text(widget.price.toString())
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat')
                      .where('product',
                          isEqualTo: widget.name) //판매자 + 구매자 + 상품명
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final chatDocs = snapshot.data!.docs;
                    return ListView.builder(
                        itemCount: chatDocs.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final message = chatDocs[index];
                          final bool isMe = message['to'] == loginUser!.email;
                          return Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.grey[300]
                                        : Colors.grey[500],
                                    borderRadius: isMe
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14),
                                            bottomLeft: Radius.circular(14))
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14),
                                            bottomRight: Radius.circular(14))),
                                child: Row(
                                  children: [
                                    isMe
                                        ? Icon(Icons.person)
                                        : SizedBox(), // 예시로 아이콘을 표시함
                                    Text(
                                      message['text'],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(labelText: 'Send a message.....'),
                  )),
                  IconButton(onPressed: _sendMessage, icon: Icon(Icons.send))
                ],
              ),
            ),
          ],
        ));
  }
}
