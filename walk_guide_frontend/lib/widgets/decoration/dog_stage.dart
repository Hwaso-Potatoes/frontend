// lib/widgets/decoration/dog_stage.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../icons/dog_icon.dart';
import '../../models/decoration_model.dart';

/// 강아지 + 언덕 배경 씬
///
/// 디자인 원본 좌표는 402x520 기준인데, 강아지가 top:118부터 시작해서
/// 그 위(0~118)가 빈 하늘이라 여백이 많아 보였음.
/// _topCrop만큼 전체를 위로 당겨서(모든 top 값에서 빼서) 여백을 줄임.
///
/// 언덕/그림자는 진짜 벡터라 svg 그대로 사용, 강아지만 png 사용
/// (강아지 svg는 사실 래스터 이미지를 감싼 것들이라 png로 교체했었음)
///
/// z-order: 왼쪽(맨뒤) -> 오른쪽(중간) -> 가운데(맨앞, 메인 언덕)
class DogStage extends StatelessWidget {
  final String dogBreed;
  final AccessoryItem? equippedHair;

  const DogStage({
    super.key,
    required this.dogBreed,
    this.equippedHair,
  });

  static const double designWidth = 402;
  static const double _topCrop = 90; // 위쪽 빈 하늘 잘라내는 양
  static const double designHeight = 520 - _topCrop; // 430

  @override
  Widget build(BuildContext context) {
    final hairAnchor = defaultAnchors[AccessoryCategory.hair]!;

    return AspectRatio(
      aspectRatio: designWidth / designHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double scale = constraints.maxWidth / designWidth;
          double s(double v) => v * scale;
          // 원본 디자인 top 좌표에서 _topCrop만큼 뺀 뒤 스케일 적용
          double sy(double originalTop) => (originalTop - _topCrop) * scale;

          return ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 왼쪽 언덕 (맨 뒤) - 진짜 벡터 svg
                Positioned(
                  top: sy(279),
                  left: s(-125),
                  child: SvgPicture.asset(
                    'assets/decoration/왼쪽언덕.svg',
                    width: s(276),
                    height: s(208),
                  ),
                ),
                // 오른쪽 언덕 (중간, 180도 회전)
                Positioned(
                  top: sy(251),
                  left: s(178),
                  child: Transform.rotate(
                    angle: 3.14159265359,
                    child: SvgPicture.asset(
                      'assets/decoration/오른쪽언덕.svg',
                      width: s(332),
                      height: s(208),
                    ),
                  ),
                ),
                // 가운데 언덕 (맨 앞, 메인 언덕)
                Positioned(
                  top: sy(301),
                  left: s(-40),
                  child: SvgPicture.asset(
                    'assets/decoration/가운데언덕.svg',
                    width: s(483),
                    height: s(208),
                  ),
                ),
                // 그림자
                Positioned(
                  top: sy(341),
                  left: s(114),
                  child: SvgPicture.asset(
                    'assets/decoration/그림자.svg',
                    width: s(172),
                    height: s(15),
                  ),
                ),
                // 강아지(png) + 헤어 악세사리 오버레이
                Positioned(
                  top: sy(118),
                  left: s(63),
                  child: SizedBox(
                    width: s(256),
                    height: s(256),
                    child: Stack(
                      children: [
                        DogIcon(breed: dogBreed, size: s(256)),
                        if (equippedHair != null)
                          Align(
                            alignment: Alignment(
                              hairAnchor.position.dx * 2 - 1,
                              hairAnchor.position.dy * 2 - 1,
                            ),
                            child: FractionallySizedBox(
                              widthFactor: hairAnchor.scale,
                              child: Image.network(
                                equippedHair!.image,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}