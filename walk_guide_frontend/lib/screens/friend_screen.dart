// lib/screens/friend_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../widgets/friend_list_item.dart';
import 'all_friends_screen.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

/// 친구 화면 (첫 화면)
/// - 검색창: 입력 멈추고 300ms 후 자동 검색 + 검색 버튼 누르면 즉시 검색
/// - 내 친구 미리보기 최대 3명 + "더보기" -> 전체 목록 화면으로 이동
class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Friend> _friends = [];
  bool _isLoadingFriends = true;

  List<FriendSearchResult>? _searchResults; // null이면 검색 모드 아님
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    // TODO(backend): mockFetchMyFriends() -> 실제 GET api/friends/ 호출로 교체
    final friends = await mockFetchMyFriends();
    if (!mounted) return;
    setState(() {
      _friends = friends;
      _isLoadingFriends = false;
    });
  }

  /// 입력이 멈추고 300ms 후 자동 호출
  void _onSearchChanged() {
    _debounce?.cancel();

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = null); // 검색 모드 해제 -> 내 친구 목록으로 복귀
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  /// 검색 버튼을 누르면 디바운스 없이 즉시 호출
  void _onSearchButtonPressed() {
    _debounce?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    _runSearch(query);
  }

  Future<void> _runSearch(String query) async {
    setState(() => _isSearching = true);

    // TODO(backend): mockSearchFriends() -> 실제 GET /api/friends/search/?nickname= 호출로 교체
    final results = await mockSearchFriends(query);

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _onSearchResultTap(FriendSearchResult user) async {
    // TODO(design): 검색 결과를 탭했을 때 UI가 아직 미정 (추후 논의사항 #2).
    // 지금은 바로 친구 요청을 보내고 스낵바로만 알림.
    await mockSendFriendRequest(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.nickname}님에게 친구 요청을 보냈어요')),
    );
  }

  void _goToAllFriends() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AllFriendsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchMode = _searchResults != null;
    final previewFriends = _friends.take(3).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── 타이틀 "친구" ──
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

              // ── 검색창 ──
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFA9AA80),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _onSearchButtonPressed(),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: '고유 이름으로 검색',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onSearchButtonPressed,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.search,
                          size: 24,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // ── 검색 모드일 때: 검색 결과 / 아닐 때: 내 친구 미리보기 ──
              if (isSearchMode) ...[
                const Text(
                  '검색 결과',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_searchResults!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      '검색 결과가 없어요',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  )
                else
                  // TODO(design): 검색 결과 아이템 디자인 미정. 피그마 오면 교체할 것.
                  Expanded(
                    child: ListView.separated(
                      itemCount: _searchResults!.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: const Color(0xFFA9AA80).withOpacity(0.5),
                      ),
                      itemBuilder: (context, index) {
                        final user = _searchResults![index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            user.nickname,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () => _onSearchResultTap(user),
                            child: const Text('친구 요청'),
                          ),
                        );
                      },
                    ),
                  ),
              ] else ...[
                // ── "내 친구" + "더보기" ──
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
                          color: const Color(0xFF636037).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ── 내 친구 미리보기 리스트 (최대 3명) ──
                if (_isLoadingFriends)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: previewFriends.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: const Color(0xFFA9AA80).withOpacity(0.5),
                      ),
                    ),
                    itemBuilder: (context, index) {
                      return FriendListItem(friend: previewFriends[index]);
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}