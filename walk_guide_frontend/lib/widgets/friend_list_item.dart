// lib/widgets/friend_list_item.dart

import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import 'icons/dog_icon.dart';

/// 친구 목록 한 줄 (아바타 + 이름/견종 + 산책 상태)
/// 친구 화면(미리보기)과 내 친구 화면(전체 목록)에서 공통으로 씀
class FriendListItem extends StatelessWidget {
  final Friend friend;

  const FriendListItem({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    final pet = friend.primaryPet;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── 강아지 그림 배경 (55 x 53, radius 26.5, A9AA80 15%) ──
        Container(
          width: 55,
          height: 53,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFA9AA80).withOpacity(0.15),
            borderRadius: BorderRadius.circular(26.5),
          ),
          child: DogIcon(
            breed: pet?.breed ?? '',
            size: 53,
          ),
        ),
        const SizedBox(width: 12),
        // ── 이름(견종) + 산책 상태 ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${pet?.name ?? friend.nickname} (${pet?.breed ?? ''})',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                friend.walkStatusText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  height: 1.0,
                  color: friend.isWalkingNow
                      ? const Color(0xFF72AA4F)
                      : const Color(0xFF636037).withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}