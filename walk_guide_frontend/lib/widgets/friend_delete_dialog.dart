import 'package:flutter/material.dart';
import '../models/friend_model.dart';

Future<bool> showFriendDeleteDialog(BuildContext context, Friend friend) async {
  return await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .32),
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 58),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${friend.primaryPet?.name ?? friend.nickname}를\n친구에서 삭제할까요?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '삭제하면 ${friend.primaryPet?.name ?? friend.nickname}의 산책 소식을 더 이상 볼 수 없고,\n함께한 산책 기록에서도 사라져요.\n상대방에게는 알림이 가지 않아요.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9.5,
                    height: 1.25,
                    color: Color(0xFF636037),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _button(context, '아니요', false)),
                    const SizedBox(width: 14),
                    Expanded(child: _button(context, '삭제', true)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

Widget _button(BuildContext context, String label, bool delete) => SizedBox(
  height: 36,
  child: ElevatedButton(
    onPressed: () => Navigator.of(context).pop(delete),
    style: ElevatedButton.styleFrom(
      backgroundColor: delete ? const Color(0xFF27722F) : Colors.white,
      foregroundColor: delete ? Colors.white : Colors.black54,
      elevation: 3,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: delete
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFA9AA80), width: 1.5),
      ),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  ),
);
