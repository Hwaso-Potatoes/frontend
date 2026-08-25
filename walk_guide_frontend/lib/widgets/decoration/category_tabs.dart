// lib/widgets/decoration/category_tabs.dart

import 'package:flutter/material.dart';
import '../../models/decoration_model.dart';

/// 헤어/케이프/옷/신발 카테고리 탭
/// 텍스트 길이에 맞게 알아서 늘어나는 pill (스펙상 탭 폭이 제각각인 게
/// "텍스트 길이 + 좌우 패딩"으로 계산됨을 확인해서 하드코딩 대신 이렇게 처리)
/// 탭 사이 간격은 11px로 고정 (스펙 좌표 확인 결과 일정함)
class CategoryTabs extends StatelessWidget {
  final AccessoryCategory selected;
  final ValueChanged<AccessoryCategory> onChanged;

  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AccessoryCategory.values.map((category) {
        final bool isSelected = category == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 11),
          child: GestureDetector(
            onTap: () => onChanged(category),
            child: Container(
              height: 33,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF27722F)
                    : const Color(0xFFA9AA80).withOpacity(0.15),
                borderRadius: BorderRadius.circular(35),
                border: isSelected
                    ? Border.all(color: const Color(0xFF27722F), width: 1)
                    : null,
              ),
              child: Text(
                category.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.0,
                  color: isSelected ? Colors.white : const Color(0xFF5E5F56),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}