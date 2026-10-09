/// 뱃지 도감 한 칸(뱃지 1개)을 표현하는 모델
class BadgeModel {
  final int id;
  final String name;
  final String? image; // null/빈 값이면 BadgeIcon이 placeholder 처리
  final String? description; // TODO: 백엔드에 필드 추가 요청 (위 TODO 2번)
  final String? location; // TODO: 백엔드에 필드 추가 요청 (위 TODO 3번)
  final DateTime? acquiredAt; // 보유 뱃지 API의 acquired_at
  final bool isOwned;

  const BadgeModel({
    required this.id,
    required this.name,
    this.image,
    this.description,
    this.location,
    this.acquiredAt,
    this.isOwned = false,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    image: json['image'] as String?,
    description: json['description'] as String?,
  );

  /// 보유 뱃지 조회 API 응답 파싱용
  /// 예: { "badge": { "id":1, "name":"첫 산책", "image":"..." }, "acquired_at":"..." }
  factory BadgeModel.fromOwnedJson(Map<String, dynamic> json) {
    final badge = json['badge'] as Map<String, dynamic>;
    return BadgeModel(
      id: badge['id'] as int,
      name: badge['name'] as String,
      image: badge['image'] as String?,
      description: badge['description'] as String?,
      acquiredAt: json['acquired_at'] != null
          ? DateTime.tryParse(json['acquired_at'] as String)
          : null,
      isOwned: true,
    );
  }

  BadgeModel copyWith({
    String? image,
    String? description,
    String? location,
    DateTime? acquiredAt,
    bool? isOwned,
  }) {
    return BadgeModel(
      id: id,
      name: name,
      image: image ?? this.image,
      description: description ?? this.description,
      location: location ?? this.location,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isOwned: isOwned ?? this.isOwned,
    );
  }

  // ---------------------------------------------------------------------
  // TODO: 아래 더미 데이터는 전체 뱃지 마스터 목록 API가 생기면 통째로
  // 삭제하고, API 응답을 List<BadgeModel>로 매핑하는 코드로 교체할 것.
  // 이름/설명/조건 문구는 스크린샷 아이콘 느낌으로만 추정해서 채운
  // 임시값이라 실제 기획 문구와 다를 수 있음.
  // ---------------------------------------------------------------------
  static List<BadgeModel> dummyMasterList() {
    return const [
      BadgeModel(id: 1, name: '첫 친구', description: '첫 친구 추가'),
      BadgeModel(id: 2, name: '진화의 달인', description: '레벨 50 달성'),
      BadgeModel(id: 3, name: '촉촉한 발자국', description: '비 오는 날 산책'),
      BadgeModel(id: 4, name: '눈길 탐험가', description: '눈 오는 날 산책'),
      BadgeModel(id: 5, name: '시동걸기', description: '누적 산책 60분'),
      BadgeModel(id: 6, name: '산책의 맛', description: '누적 산책 300분'),
      BadgeModel(id: 7, name: '산책 중독', description: '누적 산책 600분'),
      BadgeModel(id: 8, name: '산책의 달인', description: '누적 산책 3000분'),
      BadgeModel(id: 9, name: '가벼운 발걸음', description: '누적 산책 거리 5km'),
      BadgeModel(id: 10, name: '마라토너', description: '누적 산책 거리 10km'),
      BadgeModel(id: 11, name: '끝없는 발자국', description: '누적 산책 거리 30km'),
      BadgeModel(id: 12, name: '정복왕', description: '누적 산책 거리 50km'),
      BadgeModel(id: 13, name: '첫 발자국', description: '첫 산책'),
      BadgeModel(id: 14, name: '출석왕', description: '30일 연속 산책'),
      BadgeModel(id: 15, name: '삼시세끼 산책', description: '하루 산책 3회'),
      BadgeModel(id: 16, name: '주간 완주왕', description: '7일 연속 산책'),
      BadgeModel(id: 17, name: '낯선 산책', description: '새로운 지역 산책'),
      BadgeModel(id: 18, name: '숲길 탐험가', description: '숲속 산책'),
      BadgeModel(id: 19, name: '도시 여행자', description: '도시 산책'),
    ];
  }
}
