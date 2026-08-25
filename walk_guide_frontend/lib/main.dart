import 'package:flutter/material.dart';
import 'Login.dart';
import 'screens/profile_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/report_screen.dart';
import 'screens/decorate_screen.dart';
import 'screens/accessory_box_screen.dart';
import 'models/accessory_box_model.dart';

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
      home: AccessoryBoxScreen(boxData: dummyBoxData), // 앱이 시작되면 띄울 첫 화면 LoginPage()으로 바꿔야해!!!
    );
  }
}
