// =============================================================================
// TODO (백엔드 팀에게 요청 필요) — 뱃지 도감 화면 관련
// =============================================================================
// 1. [필수] 전체 뱃지 마스터 목록 조회 API 없음
//    - 지금 "보유 뱃지 조회" 엔드포인트는 유저가 "획득한 것만" 내려줌.
//      (예: [{ "badge": {id, name, image}, "acquired_at": "..." }])
//    - 뱃지 도감은 미보유 뱃지도 회색으로 같이 보여줘야 해서(3/19 보유 형태),
//      전체 19종 뱃지 목록(id, name, image, description, condition 등)을
//      내려주는 별도 엔드포인트가 필요함. (예: GET /badges/ 전체 목록)
//    - 지금은 아래 BadgeModel.dummyMasterList()로 19개를 하드코딩해서 화면만
//      먼저 구현함. 백엔드 API 나오면 이 더미 리스트를 API 응답으로 교체.
//
// 2. [필수] 뱃지 설명(description) 필드 없음
//    - 모달에 "처음 친구추가시 획득" 같은 설명 텍스트가 필요한데
//      보유 뱃지 API 응답엔 name/image/acquired_at 뿐, description 없음.
//    - 전체 목록 API 만들 때 description 필드도 같이 넣어달라고 요청 필요.
//
// 3. [필수] 뱃지 획득 "위치" 정보 없음
//    - 모달 스펙에 "뱃지 받은 위치, 시간, 날짜" 텍스트 표시 요구되는데
//      API엔 acquired_at(시간)만 있고 위치 정보가 아예 없음.
//    - 위치 정보를 애초에 안 주는 건지, 프론트에서 GPS 찍어서 보내는 구조인지
//      기획/백엔드 쪽 확인 필요. 지금은 위치란은 비워두거나 생략 처리.
//
// 4. [참고] 이미지 URL 인코딩/절대경로 이슈
//    - image 값이 "http://127.0.0.1:8000/media/badges/한글파일명.png" 형태로
//      옴 (한글 파일명이 퍼센트 인코딩되어 있음). 배포 환경에서 도메인
//      바뀔 때 절대경로 그대로 오는 게 맞는지 재확인 필요 (다른 API는
//      상대경로로 오는 경우도 있었음 — 브리핑 참고).
//
// 5. [참고] 획득 조건(condition) 값 없음
//    - "LV.50 달성시 획득", "누적 15km 산책시 획득" 같은 조건 텍스트를
//      지금은 description에 하드코딩해서 대체 중. 실제로는 조건이 코드로
//      판단되니(레벨업, 거리누적 등) description은 사람이 읽는 문구로
//      백엔드에서 같이 내려주는 게 맞을 듯.
// =============================================================================

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

  /// 보유 뱃지 조회 API 응답 파싱용
  /// 예: { "badge": { "id":1, "name":"첫 산책", "image":"..." }, "acquired_at":"..." }
  factory BadgeModel.fromOwnedJson(Map<String, dynamic> json) {
    final badge = json['badge'] as Map<String, dynamic>;
    return BadgeModel(
      id: badge['id'] as int,
      name: badge['name'] as String,
      image: badge['image'] as String?,
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
      BadgeModel(
        id: 1,
        name: '첫 친구',
        description: '처음 친구추가시 획득',
      ),
      BadgeModel(
        id: 2,
        name: '진화의 달인',
        description: 'LV.50 달성시 획득',
      ),
      BadgeModel(
        id: 3,
        name: '완전 진화',
        description: '최종 단계까지 진화시 획득',
      ),
      BadgeModel(
        id: 4,
        name: '성장의 증표',
        description: '레벨 10 달성시 획득',
      ),
      BadgeModel(
        id: 5,
        name: '첫 산책',
        description: '첫 산책 시작시 획득',
      ),
      BadgeModel(
        id: 6,
        name: '5시간 산책',
        description: '누적 산책시간 5시간 달성시 획득',
      ),
      BadgeModel(
        id: 7,
        name: '10시간 산책',
        description: '누적 산책시간 10시간 달성시 획득',
      ),
      BadgeModel(
        id: 8,
        name: '50시간 산책',
        description: '누적 산책시간 50시간 달성시 획득',
      ),
      BadgeModel(
        id: 9,
        name: '5km 산책',
        description: '누적 5km 산책시 획득',
      ),
      BadgeModel(
        id: 10,
        name: '50km 산책',
        description: '누적 50km 산책시 획득',
      ),
      BadgeModel(
        id: 11,
        name: '100km 산책',
        description: '누적 100km 산책시 획득',
      ),
      BadgeModel(
        id: 12,
        name: '500km 산책',
        description: '누적 500km 산책시 획득',
      ),
      BadgeModel(
        id: 13,
        name: '첫날 산책',
        description: '가입 첫날 산책 완료시 획득',
      ),
      BadgeModel(
        id: 14,
        name: '3일 연속 산책',
        description: '3일 연속 산책시 획득',
      ),
      BadgeModel(
        id: 15,
        name: '매일 산책러',
        description: '연속 산책 기록 달성시 획득',
      ),
      BadgeModel(
        id: 16,
        name: '1주 연속 산책',
        description: '7일 연속 산책시 획득',
      ),
      BadgeModel(
        id: 17,
        name: '새로운 장소',
        description: '새로운 산책 장소 방문시 획득',
      ),
      BadgeModel(
        id: 18,
        name: '탐험가',
        description: '여러 장소 방문시 획득',
      ),
      BadgeModel(
        id: 19,
        name: '도시 탐험',
        description: '도심 코스 산책 완료시 획득',
      ),
    ];
  }
}