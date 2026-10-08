// lib/widgets/box/touch_counter_dots.dart

import 'package:flutter/material.dart';

/// 박스 터치 진행 표시 동그라미 (기본 3개)
/// filledCount가 dotCount보다 커도(예: 4번째 터치) 3개까지만 꽉 찬 상태로 표시
class TouchCounterDots extends StatelessWidget {
  final int dotCount;
  final int filledCount;

  const TouchCounterDots({
    super.key,
    required this.dotCount,
    required this.filledCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (index) {
        final bool filled = index < filledCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 19.76,
            height: 19.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? const Color(0xFF72AA4F) : const Color(0xFFEDEDD6),
            ),
          ),
        );
      }),
    );
  }
}