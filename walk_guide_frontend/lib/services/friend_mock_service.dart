import 'dart:math';
import '../models/friend_model.dart';

/// Session-scoped mock storage; replace these calls with the friend API later.
/// Deletions survive re-fetching and navigating between preview/full lists.
class FriendMockService {
  static List<Friend>? _friends;

  static Future<List<Friend>> fetch() async {
    _friends ??= await buildMockFriends();
    return List.unmodifiable(_friends!);
  }

  static Future<void> delete(int friendId) async {
    await fetch();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _friends = _friends!.where((friend) => friend.id != friendId).toList();
  }
}

/// GET api/friends/ 를 흉내낸 mock. 산책 상태는 화면 확인용으로 임시로 채움.
Future<List<Friend>> mockFetchMyFriends() => FriendMockService.fetch();

/// Immutable seed; session storage lives in the mock service.
Future<List<Friend>> buildMockFriends() async {
  await Future.delayed(const Duration(milliseconds: 300));

  final raw = [
    {
      'id': 1,
      'nickname': '토리보호자',
      'pets': [
        {
          'id': 1,
          'name': '토리',
          'breed': '포메라니안',
          'age': 2,
          'personalities': ['에너지형', '겁쟁이형'],
        },
      ],
    },
    {
      'id': 2,
      'nickname': '밀크보호자',
      'pets': [
        {'id': 2, 'name': '밀크', 'breed': '말티즈'},
      ],
    },
    {
      'id': 3,
      'nickname': '휴지보호자',
      'pets': [
        {'id': 3, 'name': '휴지', 'breed': '푸들'},
      ],
    },
    {
      'id': 4,
      'nickname': '초코보호자',
      'pets': [
        {'id': 4, 'name': '초코', 'breed': '닥스훈트'},
      ],
    },
    {
      'id': 5,
      'nickname': '뭉치보호자',
      'pets': [
        {'id': 5, 'name': '뭉치', 'breed': '사모예드'},
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

  return mockUsers.where((u) => u.nickname.contains(query)).take(5).toList();
}

/// POST api/friends/ (receiver_id) 를 흉내낸 mock. 201 -> { "id": N } 형태.
Future<int> mockSendFriendRequest(int receiverId) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return Random().nextInt(1000); // 실제로는 응답의 request id
}

/// DELETE api/friends/:friend_id/ 를 흉내낸 mock. 204 No Content.
Future<void> mockDeleteFriend(int friendId) =>
    FriendMockService.delete(friendId);

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

/// POST api/friends/qr/ (나의 QR 생성) mock
Future<QrCodeGenerateResponse> mockGenerateMyQrCode() async {
  await Future.delayed(const Duration(milliseconds: 250));
  final randomToken = List.generate(
    40,
    (index) =>
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[Random()
            .nextInt(62)],
  ).join();
  return QrCodeGenerateResponse(token: randomToken, expiresIn: 300);
}

/// POST api/friends/qr/redeem/ (QR 스캔 후 친구 추가) mock
Future<Friend> mockRedeemQrCode(String token) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (token.trim().isEmpty) {
    throw Exception('유효하지 않은 QR 토큰입니다.');
  }

  final mockFriendJson = {
    'id': Random().nextInt(100) + 10,
    'nickname': '은비보호자',
    'pets': [
      {'id': 4, 'name': '뭉치', 'breed': '사모예드'},
    ],
  };

  final friend = Friend.fromJson(mockFriendJson);
  return friend.copyWith(
    isWalkingNow: true,
    walkStatusText: '오프라인 QR 코드로 친구 추가됨',
  );
}
