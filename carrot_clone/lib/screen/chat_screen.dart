import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/chatting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          } else {
            final chatDocs = snapshot.data!.docs;
            final recentChats = _getRecentChats(chatDocs);
            return ListView.builder(
                itemBuilder: (context, index) {
                  final chat = recentChats[index];
                  return GestureDetector(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(chat['to'] ==
                                          FirebaseAuth
                                              .instance.currentUser!.email
                                      ? (chat['from'] !=
                                              FirebaseAuth
                                                  .instance.currentUser!.email
                                          ? chat['from']
                                          : chat['to'])
                                      : (chat['from'] ==
                                              FirebaseAuth
                                                  .instance.currentUser!.email
                                          ? chat['to']
                                          : chat['from'])),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(chat['text'])
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChattingScreen(
                                id: chat['productId'],
                                name: chat['product'],
                                sellUser: chat['sellUser'],
                                price: chat['price'])));
                      });
                },
                itemCount: recentChats.length);
          }
        },
      ),
    );
  }
}

List<QueryDocumentSnapshot> _getRecentChats(
    List<QueryDocumentSnapshot> chatDocs) {
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
  final recentChatsMap = <String, QueryDocumentSnapshot>{};

  for (var chatDoc in chatDocs) {
    final to = chatDoc['to'];
    final from = chatDoc['from'];

    if (to == currentUserEmail || from == currentUserEmail) {
      final otherUser = to == currentUserEmail ? from : to;
      final existingChat = recentChatsMap[otherUser];

      // 최근 채팅이 없거나 현재 채팅이 더 최근일 경우 갱신
      final Timestamp chatTimestamp = chatDoc['timestamp'] as Timestamp;
      final DateTime chatDateTime = chatTimestamp.toDate();

      final DateTime? existingChatDateTime = existingChat != null
          ? (existingChat['timestamp'] as Timestamp).toDate()
          : null;

      if (existingChat == null || chatDateTime.isAfter(existingChatDateTime!)) {
        recentChatsMap[otherUser] = chatDoc;
      }
    }
  }
  return recentChatsMap.values.toList();
}
