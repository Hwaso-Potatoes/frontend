import 'dart:async';
import 'package:flutter/material.dart';

/// Shared, route-local feedback. It never reserves space in the friend list,
/// and its timer is restarted on success and cancelled when the screen leaves.
mixin FriendDeleteFeedback<T extends StatefulWidget> on State<T> {
  Timer? _feedbackTimer;
  bool _feedbackVisible = false;

  void showFriendDeleteFeedback() {
    _feedbackTimer?.cancel();
    setState(() => _feedbackVisible = true);
    _feedbackTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _feedbackVisible = false);
    });
  }

  Widget buildFriendDeleteFeedback(Widget child) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      if (_feedbackVisible)
        Positioned(
          left: 24,
          right: 24,
          bottom: MediaQuery.paddingOf(context).bottom + 56,
          child: const IgnorePointer(
            child: Center(
              child: Text(
                '친구 삭제가 완료되었습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF636037),
                ),
              ),
            ),
          ),
        ),
    ],
  );

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
