import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF27722F);

// CustomTextField
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Color(0xFFC8E6C9), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// CustomButton
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = primaryGreen,
    this.textColor = Colors.white,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: 1.0)
                  : BorderSide.none,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// CustomDialog
Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

//  공통 하단 네비게이션 바 위젯
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. 하단 바 흰색 직사각형 배경 (상단 얇은 라인 처리)
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, '홈'),
                _buildNavItem(
                  1,
                  Icons.insert_chart_outlined_rounded,
                  Icons.insert_chart_rounded,
                  '리포트',
                ),
                const SizedBox(width: 68), // 중앙 원형 버튼 영역 확보
                _buildNavItem(
                  3,
                  Icons.people_outline_rounded,
                  Icons.people_rounded,
                  '친구',
                ),
                _buildNavItem(
                  4,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  '프로필',
                ),
              ],
            ),
          ),

          // 2. 바 위로 솟아오르는 원형 뒷배경 (바와 동일한 흰색으로 자연스럽게 연결)
          Positioned(
            top: -15,
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. 중앙 연두색 발바닥 원형 버튼 + '산책' 텍스트
          Positioned(
            top: -10,
            child: GestureDetector(
              onTap: () => onTap(2),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: currentIndex == 2
                          ? const Color(0xFF27722F)
                          : const Color(0xFFA5D179),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '산책',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: currentIndex == 2
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: currentIndex == 2
                          ? const Color(0xFF27722F)
                          : const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isSelected = currentIndex == index;
    const activeColor = Color(0xFF27722F);
    const inactiveColor = Color(0xFF9E9E9E);

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
