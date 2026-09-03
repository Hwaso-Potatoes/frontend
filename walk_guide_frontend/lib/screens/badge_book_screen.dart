// =============================================================================
// TODO (백엔드 팀에게 요청 필요) — badge_model.dart 상단 TODO 참고
// - 전체 뱃지 마스터 목록 API 없음 → 지금은 BadgeModel.dummyMasterList() 사용
// - description(획득 조건 문구), location(획득 위치) 필드 없음 → 지금은
//   더미 텍스트 / 빈 값으로 처리, API 나오면 owned 병합 로직에서 교체 예정
// - "보유 뱃지 조회" API 연동 지점은 이 파일의 _loadBadges()에 표시해둠
// =============================================================================

import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../widgets/icons/badge_icon.dart';

const _kBgColor = Color(0xFFF8F9E5);
const _kOliveText = Color(0xFF636037);
const _kNeutralGrayKhaki = Color(0xFFA9AA80);
const _kModalBg = Color(0xFFECEDD6);
const _kCloseIconColor = Color(0xFF817F5A);
const _kAccentGreen = Color(0xFF27722F);

class BadgeBookScreen extends StatefulWidget {
  const BadgeBookScreen({super.key});

  @override
  State<BadgeBookScreen> createState() => _BadgeBookScreenState();
}

class _BadgeBookScreenState extends State<BadgeBookScreen> {
  List<BadgeModel> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    // TODO(백엔드 연동): 실제로는 아래 두 가지를 합쳐야 함
    //   1) 전체 뱃지 마스터 목록 (없음 → dummyMasterList로 대체 중)
    //   2) GET /badges/owned/ 같은 "보유 뱃지 조회" API
    //      응답 예: [{ "badge": {id,name,image}, "acquired_at": "..." }]
    //      → List<BadgeModel> owned = response.map(BadgeModel.fromOwnedJson)
    // 지금은 화면 먼저 완성하려고 마스터 목록 중 1/5/13번째만
    // 보유(owned)한 것처럼 더미로 표시함.
    final master = BadgeModel.dummyMasterList();
    final ownedIds = {1, 5, 13}; // TODO: 실제 보유 뱃지 API 응답으로 교체

    setState(() {
      _badges = master
          .map((b) => ownedIds.contains(b.id)
              ? b.copyWith(isOwned: true, acquiredAt: DateTime.now())
              : b)
          .toList();
      _isLoading = false;
    });
  }

  void _openBadgeModal(BadgeModel badge) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => _BadgeDetailModal(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownedCount = _badges.where((b) => b.isOwned).length;

    return Scaffold(
      backgroundColor: _kBgColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 뒤로가기 + "뱃지 도감" 타이틀 + 보유 개수
                    // (내 친구 화면과 스타일 통일: 아이콘 24, 제목 Inter w600) ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 24,
                            color: _kOliveText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '뱃지 도감',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                            height: 1.1,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$ownedCount / ${_badges.length} 보유',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.0,
                            color: _kOliveText.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _BadgeGrid(
                          badges: _badges,
                          onTap: _openBadgeModal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// 4열 그리드 + 4개마다(한 줄마다) 구분선.
/// badge_row.dart(Wrap 기반)는 줄바꿈 위치가 콘텐츠에 따라 유동적이라
/// "줄마다 구분선"이라는 이 화면 스펙엔 안 맞아서, 여기서는 행 단위로
/// 직접 나눠서 그림. (badge_row.dart는 다른 화면에서 계속 재사용됨)
class _BadgeGrid extends StatelessWidget {
  final List<BadgeModel> badges;
  final ValueChanged<BadgeModel> onTap;

  const _BadgeGrid({required this.badges, required this.onTap});

  static const _cellSize = 72.0;
  static const _hSpacing = 19.0;
  static const _colCount = 4;

  @override
  Widget build(BuildContext context) {
    final rows = <List<BadgeModel>>[];
    for (var i = 0; i < badges.length; i += _colCount) {
      rows.add(badges.sublist(
        i,
        (i + _colCount > badges.length) ? badges.length : i + _colCount,
      ));
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          Row(
            children: [
              for (var c = 0; c < rows[r].length; c++) ...[
                if (c != 0) const SizedBox(width: _hSpacing),
                _BadgeCell(
                  badge: rows[r][c],
                  onTap: () => onTap(rows[r][c]),
                ),
              ],
            ],
          ),
          if (r != rows.length - 1) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: _kNeutralGrayKhaki.withOpacity(0.5),
            ),
            const SizedBox(height: 29),
          ],
        ],
      ],
    );
  }
}

class _BadgeCell extends StatelessWidget {
  final BadgeModel badge;
  final VoidCallback onTap;

  const _BadgeCell({required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _BadgeGrid._cellSize,
        height: _BadgeGrid._cellSize,
        decoration: BoxDecoration(
          color: badge.isOwned
              ? _kAccentGreen.withOpacity(0.12)
              : _kNeutralGrayKhaki.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: badge.isOwned
              ? Border.all(color: _kAccentGreen, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(9),
        child: badge.isOwned
            ? BadgeIcon(imageUrl: badge.image, size: 54)
            : Opacity(
                opacity: 0.45,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: BadgeIcon(imageUrl: badge.image, size: 54),
                ),
              ),
      ),
    );
  }
}

class _BadgeDetailModal extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeDetailModal({required this.badge});

  String _formatAcquiredAt() {
    final d = badge.acquiredAt;
    if (d == null) return '';
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final locationLine = badge.location; // TODO: 백엔드 필드 생기면 채우기
    final timeLine = _formatAcquiredAt();
    final metaText = [
      if (locationLine != null && locationLine.isNotEmpty) locationLine,
      if (timeLine.isNotEmpty) timeLine,
    ].join('\n');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        width: 332,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: BoxDecoration(
          color: _kModalBg,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 32,
                    color: _kCloseIconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 254,
              height: 254,
              child: badge.isOwned
                  ? BadgeIcon(imageUrl: badge.image, size: 254)
                  : Opacity(
                      opacity: 0.45,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: BadgeIcon(imageUrl: badge.image, size: 254),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: _kNeutralGrayKhaki.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          height: 1.1,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        // TODO: description 백엔드 필드 없음 → 더미 문구 표시 중
                        badge.description ?? '',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          height: 1.1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                if (metaText.isNotEmpty)
                  Text(
                    metaText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      height: 1.0,
                      color: _kOliveText.withOpacity(0.65),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}