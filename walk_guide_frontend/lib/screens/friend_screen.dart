// lib/screens/friend_screen.dart

import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/friend_detail_dialog.dart';
import '../widgets/friend_delete_feedback.dart';
import 'all_friends_screen.dart';
import 'qr_friend_add_screen.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color qrButtonGreen = Color(0xFF86B453);

/// 친구 메인 화면 (Screen 1 시안 100% 반영)
/// - 상단 "친구" 타이틀
/// - 검색창 ("이름으로 검색") + 우측 초록색 QR 버튼
/// - 기존 내 친구 목록 실시간 필터링
/// - "내 친구" 목록 & "더보기" 링크
class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen>
    with FriendDeleteFeedback<FriendScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];
  bool _isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final friends = await mockFetchMyFriends();
    if (!mounted) return;
    setState(() {
      _allFriends = friends;
      final query = _searchController.text.trim().toLowerCase();
      _filteredFriends = friends
          .where(
            (f) =>
                query.isEmpty ||
                f.nickname.toLowerCase().contains(query) ||
                (f.primaryPet?.name.toLowerCase().contains(query) ?? false),
          )
          .toList();
      _isLoadingFriends = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _allFriends;
      } else {
        _filteredFriends = _allFriends.where((f) {
          final nicknameMatch = f.nickname.toLowerCase().contains(query);
          final petMatch =
              f.primaryPet?.name.toLowerCase().contains(query) ?? false;
          return nicknameMatch || petMatch;
        }).toList();
      }
    });
  }

  void _navigateToQrAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QrFriendAddScreen(initialTab: QrTab.myQr),
      ),
    );
  }

  Future<void> _goToAllFriends() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AllFriendsScreen()));
    if (mounted) await _loadFriends();
  }

  Future<void> _showFriend(Friend friend) async {
    if (await showFriendDetails(context, friend) && mounted) {
      await _loadFriends();
      if (mounted) showFriendDeleteFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewFriends = _filteredFriends.take(3).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: buildFriendDeleteFeedback(
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── 1. 타이틀 "친구" ──
                const Text(
                  '친구',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 22),

                // ── 2. 검색창 + 초록색 QR 버튼 (한 줄) ──
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFA9AA80,
                            ).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: '이름으로 검색',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    color: Colors.black.withValues(alpha: 0.4),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.search,
                              size: 22,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 초록색 QR 코드 버튼 (1번 시안 100% 동일)
                    GestureDetector(
                      onTap: _navigateToQrAddScreen,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: qrButtonGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── 3. "내 친구" 헤더 + "더보기" ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '내 친구',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _goToAllFriends,
                      child: Text(
                        '더보기',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.0,
                          color: const Color(0xFF636037).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── 4. 내 친구 미리보기 목록 ──
                if (_isLoadingFriends)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: qrButtonGreen),
                    ),
                  )
                else if (previewFriends.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        '검색된 친구가 없어요',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: previewFriends.length,
                      separatorBuilder: (_, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: const Color(0xFFA9AA80).withValues(alpha: 0.4),
                        ),
                      ),
                      itemBuilder: (context, index) {
                        return FriendListItem(
                          friend: previewFriends[index],
                          onTap: () => _showFriend(previewFriends[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
