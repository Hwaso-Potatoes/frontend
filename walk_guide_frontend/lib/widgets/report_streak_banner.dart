import 'package:flutter/material.dart';

class ReportStreakBanner extends StatelessWidget {
  final String dogName;
  final int days;
  final int recordDays;
  const ReportStreakBanner({
    super.key,
    required this.dogName,
    required this.days,
    required this.recordDays,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFE2F3C2),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFA5D179),
          child: Icon(
            Icons.local_fire_department,
            color: Color(0xFFE2F3C2),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                days == 0
                    ? '$dogName의 연속 산책을 시작해보세요!'
                    : '$dogName와 $days일 연속 산책중!',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF27722F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                days >= recordDays && days > 0
                    ? '최장 기록 ${days > recordDays ? days : recordDays}일을 이어가고 있어요.'
                    : '최장 기록 $recordDays일까지 ${(recordDays - days).clamp(0, recordDays)}일 남았어요.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF85845F)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
