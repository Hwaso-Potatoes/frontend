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
// 4. 친구 삭제(DELETE api/friends/:friend_id/) 버튼 위치(스와이프/롱프레스 등) 미정.
//    -> mock 함수만 만들어두고 화면 연결은 보류.

import 'dart:async';
import 'dart:math';

/// 친구의 반려견 정보 (친구 목록 응답의 pets 배열 안 항목)
/// 가정: 한 유저는 반려견을 한 마리만 키운다고 가정하고, pets[0]만 사용함.
class FriendPet {
  final int id;
  final String name;
  final String breed;

  const FriendPet({
    required this.id,
    required this.name,
    required this.breed,
  });

  factory FriendPet.fromJson(Map<String, dynamic> json) {
    return FriendPet(
      id: json['id'] as int,
      name: json['name'] as String,
      breed: json['breed'] as String,
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
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      pets: petsJson
          .map((p) => FriendPet.fromJson(p as Map<String, dynamic>))
          .toList(),
      // 아래 두 값은 실제 응답에 없어서 기본값으로 둠 (mock에서 별도 주입)
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
      id: json['id'] as int,
      nickname: json['nickname'] as String,
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
      id: json['id'] as int,
      requesterId: requester['id'] as int,
      requesterNickname: requester['nickname'] as String,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TEMP MOCK: 서비스 레이어(services/friend_service.dart) 연결 전까지
// 쓰는 가짜 호출들. TODO(backend): 실제 HTTP 연동 코드로 교체할 것.
// ══════════════════════════════════════════════════════════════

/// GET api/friends/ 를 흉내낸 mock. 산책 상태는 화면 확인용으로 임시로 채움.
Future<List<Friend>> mockFetchMyFriends() async {
  await Future.delayed(const Duration(milliseconds: 300));

  final raw = [
    {
      'id': 1,
      'nickname': '토리보호자',
      'pets': [
        {'id': 1, 'name': '토리', 'breed': '포메라니안'}
      ],
    },
    {
      'id': 2,
      'nickname': '밀크보호자',
      'pets': [
        {'id': 2, 'name': '밀크', 'breed': '말티즈'}
      ],
    },
    {
      'id': 3,
      'nickname': '휴지보호자',
      'pets': [
        {'id': 3, 'name': '휴지', 'breed': '푸들'}
      ],
    },
    {
      'id': 4,
      'nickname': '초코보호자',
      'pets': [
        {'id': 4, 'name': '초코', 'breed': '닥스훈트'}
      ],
    },
    {
      'id': 5,
      'nickname': '뭉치보호자',
      'pets': [
        {'id': 5, 'name': '뭉치', 'breed': '사모예드'}
      ],
    },
  ];

  final friends = raw.map((j) => Friend.fromJson(j)).toList();

  // TODO(backend): 아래 산책 상태는 전부 mock. 실제 필드 확정되면 삭제.
  final walkStatuses = <(bool, String)>[
    (true, '지금 산책 중 · 12분째'),
    (false, '2시간 전 산책 완료'),
    (false, '5시간 전 산책 완료'),
    (false, '3시간 전 산책 완료'),
    (false, '12시간 전 산책 완료'),
  ];

  return List.generate(friends.length, (i) {
    final (isWalking, text) = walkStatuses[i];
    return friends[i].copyWith(isWalkingNow: isWalking, walkStatusText: text);
  });
}

/// GET /api/friends/search/?nickname= 를 흉내낸 mock.
/// 최대 5명, 입력값이 nickname에 포함되는 유저만 반환한다는 명세를 그대로 흉내냄.
Future<List<FriendSearchResult>> mockSearchFriends(String query) async {
  await Future.delayed(const Duration(milliseconds: 200));

  if (query.trim().isEmpty) return [];

  final mockUsers = [
    const FriendSearchResult(id: 10, nickname: '보리보호자'),
    const FriendSearchResult(id: 11, nickname: '뭉치사랑'),
    const FriendSearchResult(id: 12, nickname: '초코맘'),
    const FriendSearchResult(id: 13, nickname: '해피독'),
    const FriendSearchResult(id: 14, nickname: '뽀삐아빠'),
    const FriendSearchResult(id: 15, nickname: '몽이보호자'),
  ];

  return mockUsers
      .where((u) => u.nickname.contains(query))
      .take(5)
      .toList();
}

/// POST api/friends/ (receiver_id) 를 흉내낸 mock. 201 -> { "id": N } 형태.
Future<int> mockSendFriendRequest(int receiverId) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return Random().nextInt(1000); // 실제로는 응답의 request id
}

/// DELETE api/friends/:friend_id/ 를 흉내낸 mock. 204 No Content.
Future<void> mockDeleteFriend(int friendId) async {
  await Future.delayed(const Duration(milliseconds: 200));
}

/// GET api/friends/requests/ 를 흉내낸 mock. 화면 연결은 보류 상태.
Future<List<FriendRequest>> mockFetchFriendRequests() async {
  await Future.delayed(const Duration(milliseconds: 200));
  return [
    FriendRequest.fromJson({
      'id': 3,
      'requester': {'id': 2, 'nickname': '사용자B'},
    }),
  ];
}

/// POST api/friends/requests/:request_id/accept/ 를 흉내낸 mock. 204.
Future<void> mockAcceptFriendRequest(int requestId) async {
  await Future.delayed(const Duration(milliseconds: 200));
}

/// POST api/friends/requests/:request_id/reject/ 를 흉내낸 mock. 204.
Future<void> mockRejectFriendRequest(int requestId) async {
  await Future.delayed(const Duration(milliseconds: 200));
}