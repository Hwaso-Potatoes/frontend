// lib/models/accessory_box_model.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. accessory 응답에 rarity(등급: Common/Rare/Epic) 필드가 없음 -> 확인 필요
// 2. "박스 열기"가 별도 엔드포인트인지, 아니면 이미 미션 보상 수령 API가
//    즉시 accessory 결과를 알려주는 걸 화면에서 연출만 하는 건지 확인 필요
// 3. 등급별 필요 터치 횟수(지금은 전부 4번, 프론트 임의)를 기획에서
//    다르게 가져가고 싶어할 수도 있음 -> 확인해두면 좋음
//
// 박스 그림(초록/노랑/분홍) 자체는 백엔드가 안 주는 순수 프론트 정적 에셋이라
// png로 직접 관리함 (assets/box/ 폴더)

import 'package:flutter/material.dart';

enum BoxRarity { common, rare, epic }

extension BoxRarityLabel on BoxRarity {
  String get label {
    switch (this) {
      case BoxRarity.common:
        return 'Common';
      case BoxRarity.rare:
        return 'Rare';
      case BoxRarity.epic:
        return 'Epic';
    }
  }

  /// 등급별 박스 그림 (초록=Common, 분홍=Rare, 노랑=Epic)
  String get boxImagePath {
    switch (this) {
      case BoxRarity.common:
        return 'assets/box/box_common.png';
      case BoxRarity.rare:
        return 'assets/box/box_rare.png';
      case BoxRarity.epic:
        return 'assets/box/box_epic.png';
    }
  }
}

/// 박스 안에서 나온 악세사리 (accessory 응답 형태 그대로)
class BoxAccessoryResult {
  final String name;
  final String image;
  final String category;

  const BoxAccessoryResult({
    required this.name,
    required this.image,
    required this.category,
  });

  factory BoxAccessoryResult.fromJson(Map<String, dynamic> json) {
    return BoxAccessoryResult(
      name: json['name'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
    );
  }
}

/// 박스 열기 화면에서 쓰는 데이터
class AccessoryBoxData {
  final BoxRarity rarity; // TODO(backend): 실제 응답에 없어서 임시로 더미 지정
  final BoxAccessoryResult result;

  const AccessoryBoxData({
    required this.rarity,
    required this.result,
  });
}

/// 등급 상관없이 동일: 점 3개, 필요 터치 4번
const int kBoxDotCount = 3;
const int kBoxRequiredTaps = 4;

/// 더미 데이터 (실제로는 미션 보상 수령 API 응답을 그대로 씀)
final AccessoryBoxData dummyBoxData = AccessoryBoxData(
  rarity: BoxRarity.common,
  result: BoxAccessoryResult.fromJson({
    'name': '왕관 핀',
    'image': 'http://127.0.0.1:8000/media/accessories/crown_pin.png',
    'category': 'HAIR',
  }),
);