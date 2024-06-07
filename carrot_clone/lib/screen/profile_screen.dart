import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/logout_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_2,
              size: 50,
            ),
            Text(
              '${FirebaseAuth.instance.currentUser!.email}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 110.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LogoutScreen(
                          user: user!,
                        )));
              },
              child: Text('프로필 보기'),
            ),
          ],
        ),
      ),
    ));
  }
}
