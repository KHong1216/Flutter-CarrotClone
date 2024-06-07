import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  final User user;

  const LogoutScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: '내 프로필',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '현재 로그인 유저명 : ${user.email}',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _logOut(context);
                  },
                  child: Text('로그아웃')),
            ],
          ),
        ));
  }

  Future<void> _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')));
    }
  }
}
