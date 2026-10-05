import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import 'decoration/dog_stage.dart';
import 'personality_tag.dart';
import 'friend_delete_dialog.dart';

/// Returns true only after a confirmed deletion succeeds.
Future<bool> showFriendDetails(BuildContext context, Friend friend) async {
  final requestDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .32),
    builder: (_) => FriendDetailDialog(friend: friend),
  );
  if (requestDelete != true || !context.mounted) return false;
  if (!await showFriendDeleteDialog(context, friend) || !context.mounted) {
    return false;
  }
  // Keep the underlying list blocked while the request is in flight.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator(color: Color(0xFF27722F))),
    ),
  );
  try {
    await mockDeleteFriend(friend.id);
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    return true;
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구를 삭제하지 못했어요. 다시 시도해주세요.')),
      );
    }
    return false;
  }
}

class FriendDetailDialog extends StatefulWidget {
  final Friend friend;
  const FriendDetailDialog({super.key, required this.friend});
  @override
  State<FriendDetailDialog> createState() => _FriendDetailDialogState();
}

class _FriendDetailDialogState extends State<FriendDetailDialog> {
  bool _menuOpen = false;
  @override
  Widget build(BuildContext context) {
    final pet = widget.friend.primaryPet;
    return Dialog(
      backgroundColor: const Color(0xFFF8F9E5),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: AspectRatio(
          aspectRatio: 310 / 414,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: DogStage(
                  dogBreed: pet?.breed ?? '',
                  characterScale: .84,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 128,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              pet?.name ?? widget.friend.nickname,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '${pet?.breed ?? '반려견'}${pet?.age == null ? '' : ' · ${pet!.age}세'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF636037),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (pet?.personalityTags ?? [])
                            .map(
                              (tag) => PersonalityTag(
                                label: tag,
                                backgroundColor: tag == '겁쟁이형'
                                    ? const Color(0xFFFFDDE2)
                                    : null,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  tooltip: '친구 메뉴',
                  onPressed: () => setState(() => _menuOpen = !_menuOpen),
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF85845F)),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  tooltip: '닫기',
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, color: Color(0xFF85845F)),
                ),
              ),
              if (_menuOpen)
                Positioned(
                  top: 30,
                  left: 12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF636037),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('친구 삭제하기'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
