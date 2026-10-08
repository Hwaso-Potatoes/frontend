import 'decoration_model.dart';

// lib/models/friend_model.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 (추후 논의사항, 지우지 말 것) ──
// 1. GET api/friends/ 응답에 "지금 산책 중 / N시간 전 산책 완료" 같은 산책 상태
//    필드가 없음. 이 정보가 friends 응답에 필드로 추가되는 건지, 아니면
//    pet별 별도 엔드포인트를 호출해야 하는 건지 확인 필요.
//    -> 지금은 walkStatusText/isWalkingNow를 프론트에서 mock으로만 채워둠.
// 2. 검색 결과(GET api/friends/search/)를 눌렀을 때 UI가 어떻게 되는지
//    (바로 요청 보내기? 별도 버튼?) 피그마 디자인 아직 없음.
//    -> 지금은 검색 결과를 기본 리스트로만 보여주고, 탭하면 sendFriendRequest만
//       호출하도록 임시 연결해둠. 디자인 오면 교체할 것.
// 3. 받은 친구 요청(GET api/friends/requests/) 보여주는 화면/위치 미정.
//    -> 이 파일에 관련 모델/mock 함수는 만들어두되, 화면 연결은 보류.
// 4. 삭제 UI는 연결됨. 실제 DELETE API 연결은 services에서 교체 필요.

// Compatibility for existing QR callers; mock behavior lives in services.
export '../services/friend_mock_service.dart';

/// 친구의 반려견 정보 (친구 목록 응답의 pets 배열 안 항목)
/// 가정: 한 유저는 반려견을 한 마리만 키운다고 가정하고, pets[0]만 사용함.
class FriendPet {
  final int id;
  final String name;
  final String breed;

  final EquippedAccessories equipped;
  final int? age;
  final List<String> personalityTags;
  const FriendPet({
    required this.id,
    required this.name,
    required this.breed,
    this.age,
    this.equipped = const EquippedAccessories(),
    this.personalityTags = const [],
  });

  factory FriendPet.fromJson(Map<String, dynamic> json) {
    return FriendPet(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? ''),
      personalityTags: List<String>.from(
        json['personalities'] as List? ?? const [],
      ),
    );
  }
}

/// 친구 한 명의 데이터
class Friend {
  final int id;
  final String nickname;
  final List<FriendPet> pets;

  // TODO(backend): 아래 두 필드는 실제 API에 없음. 산책 상태 필드 확정되면
  // fromJson에서 실제 응답으로 채우도록 교체할 것. 지금은 mock 데이터에서만 채움.
  final bool isWalkingNow;
  final String walkStatusText; // 예: "지금 산책 중 · 12분째" / "2시간 전 산책 완료"

  const Friend({
    required this.id,
    required this.nickname,
    required this.pets,
    this.isWalkingNow = false,
    this.walkStatusText = '',
  });

  /// 한 마리만 키운다는 가정 하에 대표 반려견
  FriendPet? get primaryPet => pets.isNotEmpty ? pets.first : null;

  factory Friend.fromJson(Map<String, dynamic> json) {
    final petsJson = json['pets'] as List<dynamic>? ?? [];
    return Friend(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nickname: json['nickname']?.toString() ?? '',
      pets: petsJson
          .map((p) => FriendPet.fromJson(p as Map<String, dynamic>))
          .toList(),
      isWalkingNow: false,
      walkStatusText: '',
    );
  }

  Friend copyWith({bool? isWalkingNow, String? walkStatusText}) {
    return Friend(
      id: id,
      nickname: nickname,
      pets: pets,
      isWalkingNow: isWalkingNow ?? this.isWalkingNow,
      walkStatusText: walkStatusText ?? this.walkStatusText,
    );
  }
}

/// 검색 결과 한 명 (GET api/friends/search/) - pets 정보 없이 nickname만 옴
class FriendSearchResult {
  final int id;
  final String nickname;

  const FriendSearchResult({required this.id, required this.nickname});

  factory FriendSearchResult.fromJson(Map<String, dynamic> json) {
    return FriendSearchResult(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nickname: json['nickname']?.toString() ?? '',
    );
  }
}

/// 받은 친구 요청 (GET api/friends/requests/) - 화면 연결은 보류 상태
class FriendRequest {
  final int id; // request_id
  final int requesterId;
  final String requesterNickname;

  const FriendRequest({
    required this.id,
    required this.requesterId,
    required this.requesterNickname,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>;
    return FriendRequest(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      requesterId: requester['id'] is int
          ? requester['id']
          : int.tryParse(requester['id']?.toString() ?? '0') ?? 0,
      requesterNickname: requester['nickname']?.toString() ?? '',
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TEMP MOCK: 서비스 레이어(services/friend_service.dart) 연결 전까지
// 쓰는 가짜 호출들. TODO(backend): 실제 HTTP 연동 코드로 교체할 것.
// ══════════════════════════════════════════════════════════════

/// POST api/friends/qr/ 응답 모델 (나의 QR 생성)
class QrCodeGenerateResponse {
  final String token;
  final int expiresIn;

  const QrCodeGenerateResponse({required this.token, required this.expiresIn});

  factory QrCodeGenerateResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeGenerateResponse(
      token: json['token']?.toString() ?? '',
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse(json['expires_in']?.toString() ?? '300') ?? 300,
    );
  }
}
