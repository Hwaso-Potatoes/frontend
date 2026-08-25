// lib/widgets/decoration/accessory_grid.dart

import 'package:flutter/material.dart';
import '../../models/decoration_model.dart';
import '../icons/accessory_icon.dart';

const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

/// 악세사리 그리드 (한 줄에 4개, 72x72 고정, 줄 사이 구분선)
class AccessoryGrid extends StatelessWidget {
  final List<AccessoryItem> items;
  final ValueChanged<AccessoryItem> onTap;

  const AccessoryGrid({
    super.key,
    required this.items,
    required this.onTap,
  });

  static const int _itemsPerRow = 4;
  static const double _boxSize = 72;
  static const double _horizontalGap = 18;

  @override
  Widget build(BuildContext context) {
    final List<List<AccessoryItem>> rows = [];
    for (int i = 0; i < items.length; i += _itemsPerRow) {
      final end =
          (i + _itemsPerRow > items.length) ? items.length : i + _itemsPerRow;
      rows.add(items.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows.length, (rowIndex) {
        final row = rows[rowIndex];
        final bool isLastRow = rowIndex == rows.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (int i = 0; i < row.length; i++) ...[
                  if (i != 0) const SizedBox(width: _horizontalGap),
                  _buildBox(row[i]),
                ],
              ],
            ),
            if (!isLastRow) ...[
              const SizedBox(height: 16),
              Container(
                height: 1,
                width: double.infinity,
                color: const Color(0xFFA9AA80).withOpacity(0.5),
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildBox(AccessoryItem item) {
    return GestureDetector(
      onTap: item.isOwned ? () => onTap(item) : null,
      child: Container(
        width: _boxSize,
        height: _boxSize,
        decoration: BoxDecoration(
          color: const Color(0xFFA9AA80).withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: item.isOwned
              ? AccessoryIcon(imageUrl: item.image, category: item.category.name)
              : ColorFiltered(
                  colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                  child: AccessoryIcon(
                    imageUrl: item.image,
                    category: item.category.name,
                  ),
                ),
        ),
      ),
    );
  }
}