// lib/screens/qr_friend_success_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/friend_model.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color darkGreenButton = Color(0xFF386628);

class QrFriendSuccessScreen extends StatelessWidget {
  final Friend friend;

  const QrFriendSuccessScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    final petName = friend.primaryPet?.name ?? friend.nickname;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 상단 소형 안내 문구
            Text(
              'QR 스캔 완료.',
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // 메인 센터 흰색 둥근 카드
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // ── 축하 하트 & 겹쳐진 강아지 일러스트 ──
                      SizedBox(
                        width: 180,
                        height: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. 하트 빛줄기 아이콘 (상단)
                            Positioned(
                              top: 0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(
                                    Icons.favorite,
                                    size: 38,
                                    color: Color(0xFF5E9A3E),
                                  ),
                                ],
                              ),
                            ),

                            // 2. 초록색 서클 뱃지 안에 포개진 2마리 강아지
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 140,
                                height: 120,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF76A846),
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 좌측 강아지
                                    Positioned(
                                      left: 12,
                                      bottom: 10,
                                      child: Image.asset(
                                        'assets/dogs/bichon.png',
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.pets,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                      ),
                                    ),
                                    // 우측 강아지
                                    Positioned(
                                      right: 12,
                                      bottom: 10,
                                      child: Image.asset(
                                        'assets/dogs/samoyed.png',
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.pets,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── 축하 문구 ──
                      Text(
                        '“$petName”와\n친구가 되었어요!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '이제 서로의 산책 소식을\n볼 수 있어요',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          height: 1.3,
                        ),
                      ),

                      const Spacer(),

                      // ── 하단 "프로필 보러가기" 다크 그린 버튼 ──
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkGreenButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '프로필 보러가기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── "닫기" 텍스트 버튼 ──
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          '닫기',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
