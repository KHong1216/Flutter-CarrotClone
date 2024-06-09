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
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChattingScreen(
                            id: chat['productId'],
                            name: chat['product'],
                            sellUser: chat['sellUser'],
                            price: chat['price'])));
                  },
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                    title: Text(
                        chat['to'] == FirebaseAuth.instance.currentUser!.email
                            ? (chat['from'] !=
                                    FirebaseAuth.instance.currentUser!.email
                                ? chat['from']
                                : chat['to'])
                            : (chat['from'] ==
                                    FirebaseAuth.instance.currentUser!.email
                                ? chat['to']
                                : chat['from'])),
                    subtitle: Text(chat['text']),
                  ),
                );
              },
              itemCount: recentChats.length,
            );
          }
        },
      ),
    );
  }
}

List<QueryDocumentSnapshot> _getRecentChats(
    List<QueryDocumentSnapshot> chatDocs) {
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
  final recentChats = <String, Map<String, QueryDocumentSnapshot>>{};

  for (var chatDoc in chatDocs) {
    final to = chatDoc['to'];
    final from = chatDoc['from'];
    final productId = chatDoc['productId'];

    // 채팅 상대가 현재 사용자와 관련된 채팅인지 확인
    if (to == currentUserEmail || from == currentUserEmail) {
      final otherUser = to == currentUserEmail ? from : to;
      final existingChatsByProduct =
          recentChats.putIfAbsent(otherUser, () => {});

      if (existingChatsByProduct[productId] == null) {
        // 해당 사용자와의 최초의 제품별 채팅인 경우에만 추가
        existingChatsByProduct[productId] = chatDoc;
      } else {
        // 이미 존재하는 제품별 채팅과 비교하여 최신 채팅 선택
        final existingChat = existingChatsByProduct[productId]!;
        final existingTimestamp = existingChat['timestamp'] as Timestamp;
        final chatTimestamp = chatDoc['timestamp'] as Timestamp;

        if (chatTimestamp.compareTo(existingTimestamp) > 0) {
          existingChatsByProduct[productId] = chatDoc;
        }
      }
    }
  }

  // 결과를 평면화하여 최신 채팅 목록을 반환
  final List<QueryDocumentSnapshot> recentChatsFlat = [];
  recentChats.values.forEach((chatMap) {
    recentChatsFlat.addAll(chatMap.values);
  });

  return recentChatsFlat;
}
