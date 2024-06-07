import 'package:carrot_clone/layout/default_layout.dart';
import 'package:carrot_clone/screen/login_screen.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// 1. 유저가 홈화면에 입장 시도
// 2. 3초간 데이터를 받아오는 delay 발생
// 3. 데이터를 받아오지 못했다면 에러 발생
// 4. 데이터를 받아왔다면 홈화면 그려줌
// 5. 3번과4번이 아니라면 splashScreen 그려줌
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool dataLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    complete();
  }

  void complete() async {
    try {
      await Future.delayed(Duration(seconds: 3));
      dataLoading = !dataLoading;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExtendedImage.asset(
                'assets/image/book.png',
                width: MediaQuery.of(context).size.width / 2,
              ),
              const SizedBox(height: 16.0),
              CircularProgressIndicator(
                color: Colors.blue,
              )
            ],
          ),
        ),
      ),
    );
  }
}
