// lib/models/decoration_model.dart

enum AccessoryCategory { hair, cape, clothes, shoes }

extension AccessoryCategoryLabel on AccessoryCategory {
  String get label {
    switch (this) {
      case AccessoryCategory.hair:
        return '헤어';
      case AccessoryCategory.cape:
        return '케이프';
      case AccessoryCategory.clothes:
        return '옷';
      case AccessoryCategory.shoes:
        return '신발';
    }
  }
}

/// 백엔드 category 문자열("HAIR" 등) -> enum 변환
AccessoryCategory accessoryCategoryFromString(String value) {
  switch (value.toUpperCase()) {
    case 'HAIR':
      return AccessoryCategory.hair;
    case 'CAPE':
      return AccessoryCategory.cape;
    case 'CLOTHES':
      return AccessoryCategory.clothes;
    case 'SHOES':
      return AccessoryCategory.shoes;
    default:
      // 알 수 없는 값이 오면 일단 헤어로 처리 (앱이 죽지 않도록 방어)
      return AccessoryCategory.hair;
  }
}

/// Designer coordinates use the full 350 x 350 dog canvas.
class AccessoryPlacement {
  final double xPercent, yPercent, sizePercent, rotationDegrees;
  const AccessoryPlacement(
    this.xPercent,
    this.yPercent, {
    this.sizePercent = 100,
    this.rotationDegrees = 0,
  });
  double get scale => (sizePercent == 0 ? 100 : sizePercent) / 100;
}

class DogAccessoryLayout {
  final AccessoryPlacement hat, pin, cape, clothes, shoes;
  const DogAccessoryLayout({
    required this.hat,
    required this.pin,
    required this.cape,
    required this.clothes,
    required this.shoes,
  });
}

/// Snapshot of equipped state; no HTTP or mutable list state in the renderer.
class EquippedAccessories {
  final AccessoryItem? hair, cape, clothes, shoes;
  const EquippedAccessories({this.hair, this.cape, this.clothes, this.shoes});
  factory EquippedAccessories.fromItems(Iterable<AccessoryItem> items) {
    final selected = <AccessoryCategory, AccessoryItem>{};
    for (final item in items.where((item) => item.isEquipped)) {
      selected[item.category] = item;
    }
    return EquippedAccessories(
      hair: selected[AccessoryCategory.hair],
      cape: selected[AccessoryCategory.cape],
      clothes: selected[AccessoryCategory.clothes],
      shoes: selected[AccessoryCategory.shoes],
    );
  }
}

extension AccessoryCategoryApi on AccessoryCategory {
  String get apiValue => name.toUpperCase();
}

/// 악세사리 아이템 하나
///
/// 실제 API 응답 구조가 두 겹으로 감싸져 있어서 id가 2개 있음:
/// { id: 보유기록 id, accessory: { id: 카탈로그 id, name, image, category }, is_equipped }
/// - ownershipId: "내가 이걸 가지고 있다"는 기록 자체의 id (지금은 화면에서 안 씀)
/// - accessoryId: 악세사리 카탈로그 자체의 id (착용/해제 API 호출할 때 이 값을 씀)
class AccessoryItem {
  final int? ownershipId; // 미보유 더미 항목은 null (보유기록이 없으니까)
  final int accessoryId;
  final String name;
  final String image;
  final AccessoryCategory category;
  final bool isOwned;
  final bool isEquipped;

  const AccessoryItem({
    required this.ownershipId,
    required this.accessoryId,
    required this.name,
    required this.image,
    required this.category,
    required this.isOwned,
    required this.isEquipped,
  });

  /// "보유 액세서리 조회" API 응답 하나를 파싱
  /// 예: { "id":1, "accessory":{"id":1,"name":"헤어핀1","image":"...","category":"HAIR"}, "is_equipped":true }
  factory AccessoryItem.fromJson(Map<String, dynamic> json) {
    final accessoryJson = json['accessory'] as Map<String, dynamic>;
    return AccessoryItem(
      ownershipId: json['id'] as int,
      accessoryId: accessoryJson['id'] as int,
      name: accessoryJson['name'] as String,
      image: accessoryJson['image'] as String,
      category: accessoryCategoryFromString(
        accessoryJson['category'] as String,
      ),
      isOwned: true, // 이 API는 보유한 것만 내려주므로 항상 true
      isEquipped: json['is_equipped'] as bool,
    );
  }

  AccessoryItem copyWith({bool? isEquipped}) {
    return AccessoryItem(
      ownershipId: ownershipId,
      accessoryId: accessoryId,
      name: name,
      image: image,
      category: category,
      isOwned: isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}

/// 더미 데이터
/// - 헤어핀1은 실제 API 샘플(fromJson)로 만듦
/// - 나머지는 화면 그리드 확인용 더미 (isOwned:false 포함 - 실제로는 카탈로그 API 없으면 못 만듦, TODO 3번 참고)
final List<AccessoryItem> dummyAccessories = [
  // 실제 API 응답 예시 그대로 파싱
  AccessoryItem.fromJson({
    "id": 1,
    "accessory": {
      "id": 1,
      "name": "헤어핀1",
      "image": "http://127.0.0.1:8000/media/accessories/IMG_2649_1.png",
      "category": "HAIR",
    },
    "is_equipped": true,
  }),

  // 헤어 - 나머지 더미
  const AccessoryItem(ownershipId: 2, accessoryId: 2, name: '초록 비니', image: 'https://example.com/hair2.png', category: AccessoryCategory.hair, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 3, name: '노란 비니', image: 'https://example.com/hair3.png', category: AccessoryCategory.hair, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 4, accessoryId: 4, name: '카우보이 모자', image: 'https://example.com/hair4.png', category: AccessoryCategory.hair, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 5, name: '노란 리본', image: 'https://example.com/hair5.png', category: AccessoryCategory.hair, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 6, accessoryId: 6, name: '빨간 리본', image: 'https://example.com/hair6.png', category: AccessoryCategory.hair, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 7, name: '민트 리본', image: 'https://example.com/hair7.png', category: AccessoryCategory.hair, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 8, accessoryId: 8, name: '파란 리본', image: 'https://example.com/hair8.png', category: AccessoryCategory.hair, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: 9, accessoryId: 9, name: '빨간 리본핀', image: 'https://example.com/hair9.png', category: AccessoryCategory.hair, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 10, name: '초록 리본핀', image: 'https://example.com/hair10.png', category: AccessoryCategory.hair, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 11, name: '노랑 리본핀', image: 'https://example.com/hair11.png', category: AccessoryCategory.hair, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 12, accessoryId: 12, name: '하트핀', image: 'https://example.com/hair12.png', category: AccessoryCategory.hair, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 13, name: '왕관', image: 'https://example.com/hair13.png', category: AccessoryCategory.hair, isOwned: false, isEquipped: false),

  // 케이프
  const AccessoryItem(ownershipId: 14, accessoryId: 14, name: '체크 케이프', image: 'https://example.com/cape1.png', category: AccessoryCategory.cape, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 15, name: '리본 케이프', image: 'https://example.com/cape2.png', category: AccessoryCategory.cape, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 16, accessoryId: 16, name: '빨간 스카프', image: 'https://example.com/cape3.png', category: AccessoryCategory.cape, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 17, name: '방울목걸이', image: 'https://example.com/cape4.png', category: AccessoryCategory.cape, isOwned: false, isEquipped: false),

  // 옷
  const AccessoryItem(ownershipId: 18, accessoryId: 18, name: '초록 옷', image: 'https://example.com/clothes1.png', category: AccessoryCategory.clothes, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 19, name: '분홍 옷', image: 'https://example.com/clothes2.png', category: AccessoryCategory.clothes, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 20, accessoryId: 20, name: '노란 목걸이', image: 'https://example.com/clothes3.png', category: AccessoryCategory.clothes, isOwned: true, isEquipped: true),

  // 신발
  const AccessoryItem(ownershipId: 21, accessoryId: 21, name: '검정 신발', image: 'https://example.com/shoes1.png', category: AccessoryCategory.shoes, isOwned: true, isEquipped: false),
  const AccessoryItem(ownershipId: null, accessoryId: 22, name: '체크 신발', image: 'https://example.com/shoes2.png', category: AccessoryCategory.shoes, isOwned: false, isEquipped: false),
  const AccessoryItem(ownershipId: 23, accessoryId: 23, name: '파란 신발', image: 'https://example.com/shoes3.png', category: AccessoryCategory.shoes, isOwned: true, isEquipped: false),
];