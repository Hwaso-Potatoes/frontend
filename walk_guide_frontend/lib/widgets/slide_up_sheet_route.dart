// lib/widgets/slide_up_sheet_route.dart

// NOTE: 피그마 스펙의 "변경창(402 799 75 ...)"은 화면 상단 75px는 이전 화면이
// 그대로 보이고 그 아래로 새 화면이 시트처럼 덮는 형태를 뜻함. 이메일 변경 /
// 비밀번호 재설정 화면에서 이 함수로 열어야 함 (일반 Navigator.push 아님).
// 모서리 둥글기(radius 30)는 스펙에 값이 없어서 임의로 지정한 것 -> 확정
// 디자인 받으면 kSheetTopRadius 값만 바꾸면 됨.

import 'package:flutter/material.dart';

const double kSheetTopInset = 75;
const double kSheetTopRadius = 30;

Future<T?> pushSlideUpSheet<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Padding(
          padding: const EdgeInsets.only(top: kSheetTopInset),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(kSheetTopRadius),
              topRight: Radius.circular(kSheetTopRadius),
            ),
            child: builder(context),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  );
}