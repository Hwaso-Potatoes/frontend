import 'package:flutter/material.dart';

/// 통계 카드 1개 (예: "286km 누적 거리")
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA9AA80), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center, // spec: 가로정렬 가운데
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              height: 1.1,
              color: Color(0xFF000000), // spec: 색상 명시
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center, // spec: 가로정렬 가운데
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.0,
              color: const Color(0xFF636037).withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}