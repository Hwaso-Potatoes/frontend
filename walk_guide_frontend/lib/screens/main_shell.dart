import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import 'home.dart';
import 'report_screen.dart';
import 'walk_tracking.dart';
import 'profile_screen.dart';
import 'friend_screen.dart';

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

  // 💡 핵심: 탭마다(홈/리포트/친구/프로필) 자기만의 "화면 스택"을 갖게 하려고
  // Navigator를 4개 따로 만듦. 이 키로 각 탭의 Navigator를 나중에 찾아서 조작함.
  // (index 2는 "산책"인데, 탭 전환이 아니라 화면 전체를 덮는 push라서 여기 없음)
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 0: 홈
    GlobalKey<NavigatorState>(), // 1: 리포트
    GlobalKey<NavigatorState>(), // 3: 친구
    GlobalKey<NavigatorState>(), // 4: 프로필
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // 바텀바의 탭 index(0,1,3,4)를 _navigatorKeys 배열 index(0,1,2,3)로 바꿔주는 함수
  // (2번은 산책이라 배열에 자리가 없어서 이렇게 건너뛰는 매핑이 필요함)
  int _navKeyIndex(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  // 각 탭을 누르면 "제일 처음 보여줄 화면"이 뭔지 정의
  Widget _rootScreenFor(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return HomeScreen(showPermissionDialog: widget.showPermissionDialog);
      case 1:
        return const ReportScreen();
      case 3:
        return const FriendScreen();
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(showPermissionDialog: widget.showPermissionDialog);
    }
  }

  // 💡 여기가 핵심: 각 탭을 "자기만의 미니 Navigator"로 감싸는 부분.
  // 이 안에서 Navigator.push(context, ...)를 부르면, 이 미니 Navigator 안에
  // 새 화면이 쌓이는 거라서 바깥의 바텀바는 그대로 남아있음.
  // (예: 홈 탭 안에서 "더보기" 눌러 미션 화면으로 가도, 바는 안 사라짐)
  Widget _buildTabNavigator(int tabIndex) {
    return Navigator(
      key: _navigatorKeys[_navKeyIndex(tabIndex)],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => _rootScreenFor(tabIndex),
        );
      },
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // 산책 버튼: 탭 전환이 아니라 화면 전체를 덮는 push (여기서만 바가 사라짐)
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => const WalkTrackingScreen()),
      );
      return;
    }

    _navigatorKeys[_navKeyIndex(index)].currentState
        ?.popUntil((route) => route.isFirst);

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: IndexedStack(
        index: _navKeyIndex(_currentIndex),
        children: [
          _buildTabNavigator(0),
          _buildTabNavigator(1),
          _buildTabNavigator(3),
          _buildTabNavigator(4),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}