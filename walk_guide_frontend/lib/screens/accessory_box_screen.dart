// lib/screens/accessory_box_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/accessory_box_model.dart';
import '../widgets/box/touch_counter_dots.dart';
import '../widgets/reward_accessory_image.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

class AccessoryBoxResult {
  final AttendanceRewardItem reward;
  final bool goToDecorate;
  final bool goHome;
  const AccessoryBoxResult(
    this.reward, {
    this.goToDecorate = false,
    this.goHome = false,
  });
}

/// 악세사리 박스 열기 화면
class AccessoryBoxScreen extends StatefulWidget {
  final AccessoryBoxData? boxData;
  final AttendanceRewardItem? reward;
  final String boxAssetDirectory;

  const AccessoryBoxScreen({
    super.key,
    this.boxData,
    this.reward,
    this.boxAssetDirectory = 'assets/box',
  }) : assert(boxData != null || reward != null);

  @override
  State<AccessoryBoxScreen> createState() => _AccessoryBoxScreenState();
}

class _AccessoryBoxScreenState extends State<AccessoryBoxScreen>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  bool _opened = false;
  bool _opening = false;
  bool _allowPop = false;
  bool _needsReconcile = false;
  String? _openError;
  AttendanceRewardItem? _openedReward;

  late final AnimationController _tapController;
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.reward?.opened == true) {
      _openedReward = widget.reward;
      _opened = true;
      _revealController.value = 1;
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _handleBoxTap() {
    if (_opened ||
        _opening ||
        _openError != null ||
        _tapCount >= kBoxRequiredTaps)
      return;

    setState(() => _tapCount++);

    if (_tapCount >= kBoxRequiredTaps) {
      HapticFeedback.mediumImpact();
      if (widget.reward == null) {
        // 기존 미션 등에서 boxData로 진입하는 흐름은 그대로 유지한다.
        setState(() => _opened = true);
        _revealController.forward();
      } else {
        _openAttendanceReward();
      }
    } else {
      HapticFeedback.lightImpact();
      _tapController.forward(from: 0);
    }
  }

  Future<void> _openAttendanceReward() async {
    final reward = widget.reward;
    if (reward == null || _opening || _opened) return;
    setState(() {
      _opening = true;
      _openError = null;
    });
    try {
      AttendanceRewardItem? confirmed;
      if (_needsReconcile) {
        final rewards = await ApiService.getAttendanceRewards();
        for (final item in rewards) {
          if (item.id == reward.id) {
            confirmed = item;
            break;
          }
        }
        if (confirmed == null) {
          throw ApiException(502, '보상 상태를 확인하지 못했습니다. 출석 화면에서 다시 확인해주세요.');
        }
        if (!confirmed.opened) confirmed = null;
      }
      final result =
          confirmed ?? await ApiService.openAttendanceReward(reward.id);
      if (!result.opened) {
        throw ApiException(502, '서버의 보상 수령 완료 상태를 확인하지 못했습니다.');
      }
      if (!mounted) return;
      setState(() {
        _openedReward = result;
        _opened = true;
        _needsReconcile = false;
      });
      _revealController.forward(from: 0);
    } catch (error) {
      if (!mounted) return;
      _needsReconcile =
          _needsReconcile || error is! ApiException || error.statusCode >= 500;
      setState(
        () => _openError = error is ApiException
            ? error.message
            : '선물을 열지 못했습니다. 연결 상태를 확인해주세요.',
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  // 출석 보상은 노말(Common) 박스만 사용한다.
  String get _rarityLabel => 'Common';

  String get _boxImagePath {
    final directory = widget.boxAssetDirectory.replaceAll(RegExp(r'/+$'), '');
    return '$directory/box_common.png';
  }

  int? get _resultAccessoryId => widget.reward == null
      ? widget.boxData!.result.id
      : _openedReward?.accessory?.id;

  String get _resultName => rewardAccessoryDisplayName(
    _resultAccessoryId,
    widget.reward == null
        ? widget.boxData!.result.name
        : _openedReward?.accessory?.name,
  );

  String get _resultSubtitle {
    if (widget.reward != null && _openedReward?.accessory == null) {
      return '출석 화면에서 보상 정보를 다시 확인해주세요';
    }
    final category = widget.reward == null
        ? widget.boxData!.result.category
              .toString()
              .split('.')
              .last
              .toUpperCase()
        : _openedReward?.accessory?.category?.toUpperCase();
    switch (category) {
      case 'HAIR':
      case 'PIN':
        return '새 헤어 액세서리 획득';
      case 'CAPE':
        return '새 케이프 획득';
      case 'CROWN':
        return '새 왕관 획득';
      default:
        return '새 액세서리 획득';
    }
  }

  Widget _resultIcon(double size) => RewardAccessoryImage(
    accessoryId: _resultAccessoryId,
    serverImage: widget.reward == null
        ? widget.boxData!.result.image
        : _openedReward?.accessory?.image,
    size: size,
  );

  void _leave({bool goHome = false, bool goToDecorate = false}) {
    if (_opening || _allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reward = _openedReward;
      Navigator.of(context).pop(
        reward == null
            ? null
            : AccessoryBoxResult(
                reward,
                goHome: goHome,
                goToDecorate: goToDecorate,
              ),
      );
    });
  }

  /// "홈으로" 버튼 처리.
  /// 전제: 이 화면은 항상 홈 탭(MainShellScreen의 index 0) 안에서
  /// 홈 → 미션 → 박스 열기 순서로만 push 되어 들어옴.
  /// 즉 이 화면이 속한 Navigator의 첫 화면(route.isFirst)이 곧 HomeScreen이라서,
  /// popUntil로 첫 화면까지 되돌리면 결과적으로 홈 화면으로 가게 됨.
  ///
  /// TODO: 만약 나중에 미션/박스 화면이 홈 탭이 아닌 다른 탭(예: 프로필)에서도
  /// 진입 가능해지면, 이 방식은 "그 탭의 첫 화면"으로 가버려서 홈이 아닐 수 있음.
  /// 그때는 MainShellScreen 쪽에 "홈 탭으로 강제 전환 + 리셋"하는 공용 함수를
  /// 만들어서 여기서 호출하도록 바꿔야 함.
  void _goHome() {
    if (widget.reward != null) {
      _leave(goHome: true);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = math.min(
      299.0,
      math.max(0.0, MediaQuery.sizeOf(context).width - 48),
    );
    return PopScope<Object?>(
      canPop: _allowPop || (!_opening && (widget.reward == null || !_opened)),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_opening) _leave();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 타이틀 위치를 좀 더 아래로 (44 -> 70)
                    const SizedBox(height: 70),
                    Text(
                      '액세서리 박스',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansKr(
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _opened ? '새 액세서리를 획득했어요' : '박스를 터치해서 열어보세요',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansKr(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.0,
                        color: const Color(0xFF636037).withOpacity(0.75),
                      ),
                    ),

                    const SizedBox(height: 48),

                    if (!_opened) ...[
                      Text(
                        _rarityLabel,
                        style: GoogleFonts.notoSansKr(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          height: 1.1,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ── 박스 배경 + 그림 (닫힘 상태) ──
                      Center(
                        child: GestureDetector(
                          onTap: _handleBoxTap,
                          child: SizedBox(
                            width: boxSize,
                            height: boxSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: math.min(265.0, boxSize),
                                  height: 226,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEDD6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _tapController,
                                  builder: (context, child) {
                                    final t = _tapController.value;
                                    final double bounceScale =
                                        1 + (math.sin(t * math.pi) * 0.12);
                                    final double wiggle =
                                        math.sin(t * math.pi * 6) *
                                        0.06 *
                                        (1 - t);

                                    return Transform.rotate(
                                      angle: wiggle,
                                      child: Transform.scale(
                                        scale: bounceScale,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    _boxImagePath,
                                    width: boxSize,
                                    height: boxSize,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.card_giftcard,
                                        size: 200,
                                        color: Color(0xFF72AA4F),
                                      );
                                    },
                                  ),
                                ),
                                if (_opening)
                                  const CircularProgressIndicator(
                                    color: Color(0xFF27722F),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TouchCounterDots(
                        dotCount: kBoxDotCount,
                        filledCount: _tapCount > kBoxDotCount
                            ? kBoxDotCount
                            : _tapCount,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _opening
                            ? '선물을 열고 있어요…'
                            : _openError != null
                            ? '선물 열기에 실패했어요'
                            : '${kBoxRequiredTaps - _tapCount}번 더 터치하면 열려요',
                        style: GoogleFonts.notoSansKr(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: const Color(0xFF636037).withOpacity(0.75),
                        ),
                      ),
                      if (_openError != null) ...[
                        const SizedBox(height: 12),
                        Text(_openError!, textAlign: TextAlign.center),
                        TextButton(
                          onPressed: _openAttendanceReward,
                          child: Text('다시 시도'),
                        ),
                      ],
                    ] else ...[
                      // ── 결과 이미지 (열림 상태) - 배경 카드 자체를 좀 더 작게 ──
                      Center(
                        child: AnimatedBuilder(
                          animation: _revealController,
                          builder: (context, child) {
                            final curved = CurvedAnimation(
                              parent: _revealController,
                              curve: Curves.elasticOut,
                            );
                            final glowFade = CurvedAnimation(
                              parent: _revealController,
                              curve: const Interval(
                                0.0,
                                0.5,
                                curve: Curves.easeOut,
                              ),
                            );

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: (1 - glowFade.value).clamp(0.0, 0.6),
                                  child: Transform.scale(
                                    scale: 0.6 + glowFade.value * 1.4,
                                    child: Container(
                                      width: 170,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(
                                          0xFF72AA4F,
                                        ).withOpacity(0.25),
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: curved.value,
                                  child: child,
                                ),
                              ],
                            );
                          },
                          // 배경 카드 265x226 -> 190x160 (좀 더 작게)
                          child: Container(
                            width: math.min(265.0, boxSize),
                            height: 226,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECEDD6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              // AccessoryIcon에 size를 명시해야 함 (안 그러면
                              // 기본값 48로 고정되거나 반대로 배경보다 커져서
                              // 삐져나올 수 있음). 배경(160)보다 확실히 작게.
                              child: _resultIcon(170),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── 설명 카드 ──
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 89),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF27722F),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 55,
                              height: 53,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFA9AA80,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                // 55x53 박스 안에 정확히 들어가도록 size 명시
                                // (패딩 8씩 감안해서 32로, 박스 벗어나던 문제 해결)
                                child: _resultIcon(32),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _resultName,
                                    style: GoogleFonts.notoSansKr(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      height: 1.1,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _resultSubtitle,
                                    style: GoogleFonts.notoSansKr(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: const Color(
                                        0xFF636037,
                                      ).withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _goHome,
                        child: Container(
                          width: double.infinity,
                          height: 49,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF27722F),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFF27722F),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(3, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            '홈으로',
                            style: GoogleFonts.notoSansKr(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
