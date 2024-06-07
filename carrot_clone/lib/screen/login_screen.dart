import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/home_screen.dart';
import 'package:carrot_clone/screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String _statusMessage = '';

  Future<void> _login() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          setState(() {
            _statusMessage = '이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요';
          });
        } else {
          setState(() {
            _statusMessage = '로그인 성공';
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = e.message ?? '로그인 실패';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '로그인',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignupScreen()));
              },
              child: Text('회원가입'),
            ),
            SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
