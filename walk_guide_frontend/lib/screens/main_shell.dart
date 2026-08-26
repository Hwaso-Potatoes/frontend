import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import 'home.dart';
import 'report_screen.dart';
import 'walk_tracking.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  final bool showPermissionDialog;
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.showPermissionDialog = false,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return HomeScreen(showPermissionDialog: widget.showPermissionDialog);
      case 1:
        return const ReportScreen();
      case 3:
        return _buildPlaceholderScreen('친구 목록');
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(showPermissionDialog: widget.showPermissionDialog);
    }
  }

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: Center(
        child: Text(
          '$title 화면 준비 중입니다.',
          style: const TextStyle(fontSize: 16, color: Colors.black45),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // 💡 산책 버튼 클릭 시 지도 전체 화면으로 진입
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalkTrackingScreen()),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: _getBody(_currentIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
