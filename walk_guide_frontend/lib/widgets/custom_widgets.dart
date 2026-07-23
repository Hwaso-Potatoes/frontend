import 'package:flutter/material.dart';

// 메인 테마 그린 컬러
const Color primaryGreen = Color(0xFF27722F);

/// 공통 입력창 (E-mail, Password, 이름 등)
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
    return Center(
      child: SizedBox(
        width: 336,
        height: 49,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryGreen, width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 공통 초록색 버튼 (로그인, 회원가입, 다음으로 등)
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 336,
        height: 49,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
