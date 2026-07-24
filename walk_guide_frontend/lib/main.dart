import 'package:flutter/material.dart';
import 'Login.dart';

void main() {
  runApp(const WalkGuideApp());
}

// 앱 전체의 기본 설정(테마, 첫 화면 등)을 담당하는 최상위 클래스
class WalkGuideApp extends StatelessWidget {
  const WalkGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walk Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF27722F)),
      home: const LoginPage(), // 앱이 시작되면 띄울 첫 화면
    );
  }
}
