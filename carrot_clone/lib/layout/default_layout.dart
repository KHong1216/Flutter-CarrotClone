import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final String? title;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const DefaultLayout(
      {super.key,
      required this.child,
      this.backgroundColor,
      this.title,
      this.bottomNavigationBar,
      this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      appBar: renderAppBar(),
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor ?? Colors.white,
      floatingActionButton: floatingActionButton,
    );
  }

  AppBar? renderAppBar() {
    if (title == null) {
      return null;
    } else {
      return AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title!,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        foregroundColor: Colors.black,
      );
    }
  }
}
