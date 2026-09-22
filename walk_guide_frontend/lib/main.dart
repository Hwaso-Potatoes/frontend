import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/login.dart';
import 'screens/main_shell.dart';
import 'screens/home.dart';
import 'screens/findPWreset.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 크롬(웹)에서는 javaScriptAppKey가, 앱에서는 nativeAppKey가 자동으로 사용됩니다.
  KakaoSdk.init(
    nativeAppKey: 'f2c25a04d4f1139153a35b4f4c0f1aba',
    javaScriptAppKey: 'b16f7ba54aa906a121c90a11d7827d59',
  );

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
      home: const LoginPage(),
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
              builder: (context) => FindPWReset(uid: uid, token: token),
            );
          }

          return MaterialPageRoute(builder: (context) => const LoginPage());
        }

        return null;
      },
    );
  }
}
