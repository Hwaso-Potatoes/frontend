import 'package:flutter/material.dart';
import 'screens/login.dart';
// 💡 언니 개발/테스트용 스크린 import 목록 (필요시 주석 해제)
// import 'screens/profile_screen.dart';
// import 'screens/mission_screen.dart';
// import 'screens/report_screen.dart';
// import 'screens/decorate_screen.dart';
// import 'screens/accessory_box_screen.dart';
// import 'models/accessory_box_model.dart';

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
      theme: ThemeData(
        primaryColor: const Color(0xFF27722F),
        scaffoldBackgroundColor: const Color(0xFFF8F9E5),
      ),
      // 1. 기본 정상 진입 화면 (로그인 화면)
      home: const LoginPage(),

      // 2. 언니가 단독 화면 테스트할 때 아래처럼 home을 교체해서 사용 가능:
      // home: AccessoryBoxScreen(boxData: dummyBoxData),
    );
  }
}
