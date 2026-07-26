import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

class HomeScreen extends StatefulWidget {
  // 회원가입 성공 후 진입 시만 true, 로그인 진입 시 false (기본값 false)
  final bool showPermissionDialog;

  const HomeScreen({super.key, this.showPermissionDialog = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 회원가입 경로일 때만 첫 프레임 이후 권한 팝업 띄우기
    if (widget.showPermissionDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showPermissionDialog(context);
      });
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Text(
          '메인화면',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// 접근 권한 안내 팝업 위젯
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '더 편리한 서비스 이용을 위한\n접근 권한을 안내드립니다.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // 1. 위치 정보
              _buildPermissionItem(
                icon: Icons.location_on_outlined,
                title: '위치 정보',
                isOptional: true,
                description: '산책 경로 기록과 근처 친구 확인',
              ),

              const SizedBox(height: 18),

              // 2. 알림
              _buildPermissionItem(
                icon: Icons.notifications_none_outlined,
                title: '알림',
                isOptional: true,
                description: '산책 리마인더와 주간 리포트 알림',
              ),

              const SizedBox(height: 28),

              // 공통 CustomButton 적용
              CustomButton(
                text: '확인',
                onPressed: () {
                  // [참고] 나중에 permission_handler 라이브러리를 써서
                  // OS 권한 요청을 연동하고 싶다면 이곳에서 호출하시면 됨
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required bool isOptional,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF90C271), width: 1.8),
          ),
          child: Icon(icon, color: Color(0xFF90C271), size: 22),
        ),

        const SizedBox(width: 14),

        // Text 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '(선택)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
