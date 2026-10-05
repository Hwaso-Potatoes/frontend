// lib/screens/all_friends_screen.dart

import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/friend_detail_dialog.dart';
import '../widgets/friend_delete_feedback.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

/// 내 친구 화면 (친구 화면에서 "더보기"를 누르면 진입하는 전체 목록)
class AllFriendsScreen extends StatefulWidget {
  const AllFriendsScreen({super.key});

  @override
  State<AllFriendsScreen> createState() => _AllFriendsScreenState();
}

class _AllFriendsScreenState extends State<AllFriendsScreen>
    with FriendDeleteFeedback<AllFriendsScreen> {
  List<Friend> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    // TODO(backend): mockFetchMyFriends() -> 실제 GET api/friends/ 호출로 교체
    final friends = await mockFetchMyFriends();
    if (!mounted) return;
    setState(() {
      _friends = friends;
      _isLoading = false;
    });
  }

  Future<void> _showFriend(Friend friend) async {
    if (await showFriendDetails(context, friend) && mounted) {
      await _loadFriends();
      if (mounted) showFriendDeleteFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: buildFriendDeleteFeedback(
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),

                // ── 뒤로가기 + "내 친구" 타이틀 + 인원수 (한 줄) ──
                // NOTE: 뒤로가기 아이콘은 스펙에 명시되어 있지 않았지만, 다른 상세
                // 화면들(mission_screen 등)과의 통일성을 위해 추가함.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '내 친구',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_friends.length}명',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.0,
                        color: const Color(0xFF636037).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── 전체 친구 목록 ──
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _friends.length,
                      separatorBuilder: (_, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: const Color(0xFFA9AA80).withValues(alpha: 0.5),
                        ),
                      ),
                      itemBuilder: (context, index) {
                        return FriendListItem(
                          friend: _friends[index],
                          onTap: () => _showFriend(_friends[index]),
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
