// lib/models/accessory_box_model.dart
// 출석 보상 화면은 Common 박스만 사용한다.
// 실제 액세서리 이름/이미지는 출석 보상 API 응답을 표시한다.
// 기존 boxData 진입 코드의 호환을 위해 기존 모델 이름은 유지한다.

import '../config/api_config.dart';

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

/// 박스 안에서 나온 악세사리 (백엔드 accessory 응답 형태 그대로)
class BoxAccessoryResult {
  final int? id; // 백엔드 응답엔 있음. 지금은 화면에서 안 쓰지만 나중에
  // "이미 보유한 악세사리인지" 체크할 때 쓸 수 있어서 남겨둠.
  final String name;
  final String image;
  final String category;

  const BoxAccessoryResult({
    this.id,
    required this.name,
    required this.image,
    required this.category,
  });

  /// 단일 accessory 객체 형태를 그대로 파싱
  /// 예: { "id": 2, "name": "헤어핀2", "image": "...", "category": "HAIR" }
  factory BoxAccessoryResult.fromJson(Map<String, dynamic> json) {
    return BoxAccessoryResult(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}

/// 박스 열기 화면에서 쓰는 데이터
class AccessoryBoxData {
  final BoxRarity rarity; // 구형 boxData 호출과의 호환용
  final BoxAccessoryResult result;

  const AccessoryBoxData({required this.rarity, required this.result});

  /// 미션 보상 수령 응답 형태 { "accessory": {...} } 를 그대로 파싱.
  /// rarity는 백엔드 응답에 없으므로 파라미터로 받되, 안 넘기면 common으로 기본 처리.
  factory AccessoryBoxData.fromRewardJson(
    Map<String, dynamic> json, {
    BoxRarity rarity = BoxRarity.common,
  }) {
    final rawAccessory = json['accessory'];
    if (rawAccessory is! Map) {
      throw const FormatException('액세서리 응답 형식이 올바르지 않습니다.');
    }
    final accessoryJson = Map<String, dynamic>.from(rawAccessory);
    return AccessoryBoxData(
      rarity: rarity,
      result: BoxAccessoryResult.fromJson(accessoryJson),
    );
  }
}

/// 등급 상관없이 동일: 점 3개, 필요 터치 4번
const int kBoxDotCount = 3;
const int kBoxRequiredTaps = 4;

/// 기존에 화면 미리보기/단독 테스트용으로 쓰던 더미 데이터.
/// mission_screen.dart의 실제 흐름에서는 이제 안 쓰지만,
/// 다른 곳(위젯 미리보기, 테스트 등)에서 참조하고 있을 수 있어 삭제하지 않고 유지함.
final AccessoryBoxData dummyBoxData = AccessoryBoxData(
  rarity: BoxRarity.common,
  result: BoxAccessoryResult.fromJson({
    'name': '왕관 핀',
    'image': '$kApiBaseUrl/media/accessories/crown_pin.png',
    'category': 'HAIR',
  }),
);

// ── TEMP MOCK: 미션 보상 수령 API 연결 전까지 쓰는 가짜 호출 ──
// TODO(backend): 실제 서비스 레이어(예: services/mission_service.dart)가 생기면
// 이 함수를 지우고, 실제 HTTP 응답을 AccessoryBoxData.fromRewardJson()으로
// 파싱하는 코드로 교체할 것. (엔드포인트 URL/method는 아직 확인 전 - 위 TODO 3번 참고)
Future<AccessoryBoxData> mockClaimMissionReward() async {
  // 실제 네트워크 호출처럼 약간의 지연을 흉내냄
  await Future.delayed(const Duration(milliseconds: 300));

  // 실제 백엔드가 준 보상 수령 응답 예시를 그대로 하드코딩해둠
  const responseJson = {
    'accessory': {
      'id': 2,
      'name': '헤어핀2',
      'image': '/media/accessories/IMG_2650_1.png',
      'category': 'HAIR',
    },
  };

  // 구형 호출과의 호환용이며 출석 화면에서는 사용하지 않는다.
  return AccessoryBoxData.fromRewardJson(responseJson);
}
