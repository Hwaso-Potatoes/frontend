// lib/models/accessory_box_model.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. accessory 응답에 rarity(등급: Common/Rare/Epic) 필드가 없음 -> 확인 필요.
//    현재는 등급이 없어서, 박스 그림(초록/분홍/노랑)은 "연출용"으로만 임시 랜덤 배정함.
//    (주의: 이 랜덤은 박스 그림 색깔에만 적용되는 것이고, 실제로 나오는 악세사리
//     자체는 랜덤이 아니라 서버가 정해서 내려주는 값 그대로 씀 - 2번 참고)
// 2. 미션 보상 수령 시 실제로 아래와 같은 형태로 응답이 옴 (2026-XX-XX 확인):
//    {
//      "accessory": {
//        "id": 2,
//        "name": "헤어핀2",
//        "image": "/media/accessories/IMG_2650_1.png",
//        "category": "HAIR"
//      }
//    }
//    -> image가 절대경로가 아니라 "/media/..." 형태의 상대경로로 옴.
//       실제 서비스 레이어 연결 시 base URL(예: http://localhost 또는 배포 도메인)을
//       앞에 붙여줘야 화면에 이미지가 정상적으로 뜸. 지금은 mock에서만 쓰고 있어서
//       일단 그대로 둠 -> 서비스 레이어 작업 시 반드시 처리할 것.
// 3. 미션 보상 수령 엔드포인트의 정확한 URL/HTTP method 확인 필요
//    (지금은 서비스 레이어 연결 전이라 mockClaimMissionReward()로 대체 중)
// 4. 등급별 필요 터치 횟수(지금은 전부 4번, 프론트 임의)를 기획에서
//    다르게 가져가고 싶어할 수도 있음 -> 확인해두면 좋음
//
// 박스 그림(초록/노랑/분홍) 자체는 백엔드가 안 주는 순수 프론트 정적 에셋이라
// png로 직접 관리함 (assets/box/ 폴더)

import 'dart:math';

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
      id: json['id'] as int?,
      name: json['name'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
    );
  }
}

/// 박스 열기 화면에서 쓰는 데이터
class AccessoryBoxData {
  final BoxRarity rarity; // TODO(backend): 실제 응답에 없어서 연출용으로만 임시 지정
  final BoxAccessoryResult result;

  const AccessoryBoxData({
    required this.rarity,
    required this.result,
  });

  /// 미션 보상 수령 응답 형태 { "accessory": {...} } 를 그대로 파싱.
  /// rarity는 백엔드 응답에 없으므로 파라미터로 받되, 안 넘기면 common으로 기본 처리.
  factory AccessoryBoxData.fromRewardJson(
    Map<String, dynamic> json, {
    BoxRarity rarity = BoxRarity.common,
  }) {
    final accessoryJson = json['accessory'] as Map<String, dynamic>;
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
    'image': 'http://127.0.0.1:8000/media/accessories/crown_pin.png',
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

  // rarity는 백엔드가 안 주니, 박스 연출(어떤 색 박스로 보여줄지)용으로만 임시 랜덤 배정
  final random = Random();
  final rarity = BoxRarity.values[random.nextInt(BoxRarity.values.length)];

  return AccessoryBoxData.fromRewardJson(responseJson, rarity: rarity);
}