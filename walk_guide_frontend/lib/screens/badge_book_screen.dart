import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../services/active_pet_store.dart';
import '../services/badge_book_service.dart';
import '../services/api_service.dart';
import '../widgets/icons/badge_icon.dart';

const _kBgColor = Color(0xFFF8F9E5);
const _kOliveText = Color(0xFF636037);
const _kNeutralGrayKhaki = Color(0xFFA9AA80);
const _kCloseIconColor = Color(0xFF817F5A);
const _kAccentGreen = Color(0xFF27722F);

class BadgeBookScreen extends StatefulWidget {
  final ActivePetStore? store;
  final Future<List<BadgeModel>> Function(int)? loader;
  const BadgeBookScreen({super.key, this.store, this.loader});

  @override
  State<BadgeBookScreen> createState() => _BadgeBookScreenState();
}

class _BadgeBookScreenState extends State<BadgeBookScreen> {
  List<BadgeModel> _badges = [];
  bool _isLoading = true;
  String? _error;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final request = ++_request;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final state = widget.store ?? ActivePetStore.instance;
      await state.ensureLoaded();
      final petId = state.pet?.id;
      if (petId == null) throw StateError('대표 반려견 정보를 조회하지 못했습니다.');
      final badges = await (widget.loader ?? BadgeBookService.load)(petId);
      if (!mounted || request != _request) return;
      setState(() => _badges = badges);
    } catch (e) {
      if (!mounted || request != _request) return;
      setState(
        () => _error = e is ApiException
            ? e.message
            : '뱃지 정보를 불러오지 못했습니다. 다시 시도해주세요.',
      );
    } finally {
      if (mounted && request == _request) setState(() => _isLoading = false);
    }
  }

  void _openBadgeModal(BadgeModel badge) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _loadBadges,
                      child: const Text('다시 조회'),
                    ),
                  ],
                ),
              )
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
                            color: _kOliveText.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadBadges,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _badges.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('등록된 뱃지가 없습니다.'),
                                )
                              : _BadgeGrid(
                                  badges: _badges,
                                  onTap: _openBadgeModal,
                                ),
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
  static const _colCount = 4;

  @override
  Widget build(BuildContext context) {
    final rows = <List<BadgeModel>>[];
    for (var i = 0; i < badges.length; i += _colCount) {
      rows.add(
        badges.sublist(
          i,
          (i + _colCount > badges.length) ? badges.length : i + _colCount,
        ),
      );
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          Row(
            children: [
              for (var c = 0; c < rows[r].length; c++) ...[
                if (c != 0) const SizedBox(width: 12),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _BadgeCell(
                      badge: rows[r][c],
                      onTap: () => onTap(rows[r][c]),
                    ),
                  ),
                ),
              ],
              for (var c = rows[r].length; c < _colCount; c++) ...[
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
          if (r != rows.length - 1) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: _kNeutralGrayKhaki.withValues(alpha: 0.5),
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
              ? _kAccentGreen.withValues(alpha: 0.12)
              : _kNeutralGrayKhaki.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
          border: badge.isOwned
              ? Border.all(color: _kAccentGreen, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(9),
        child: badge.isOwned
            ? BadgeIcon(badgeId: badge.id, imageUrl: badge.image, size: 54)
            : Opacity(
                opacity: 0.45,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: BadgeIcon(
                    badgeId: badge.id,
                    imageUrl: badge.image,
                    size: 54,
                  ),
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
    final d = badge.acquiredAt?.toLocal();
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
          color: Colors.white,
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
                  ? BadgeIcon(
                      badgeId: badge.id,
                      imageUrl: badge.image,
                      size: 254,
                    )
                  : Opacity(
                      opacity: 0.45,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: BadgeIcon(
                          badgeId: badge.id,
                          imageUrl: badge.image,
                          size: 254,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: _kNeutralGrayKhaki.withValues(alpha: 0.5),
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
                        // Server-provided acquisition condition.
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
                      color: _kOliveText.withValues(alpha: 0.65),
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
