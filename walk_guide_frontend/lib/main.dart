import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'screens/main_shell.dart';
import 'screens/home.dart';
import 'screens/findPWreset.dart';


void main() {
  runApp(const WalkGuideApp());
}


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

      // 일반적으로 앱에 들어왔을 때
      home: const LoginPage(),

      // 비밀번호 재설정 이메일 링크로 들어왔을 때
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == '/reset-password') {
          final uid = uri.queryParameters['uid'];
          final token = uri.queryParameters['token'];

          if (uid != null &&
              uid.isNotEmpty &&
              token != null &&
              token.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => FindPWReset(
                uid: uid,
                token: token,
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => const LoginPage(),
          );
        }

        return null;
      },
    );
  }
}