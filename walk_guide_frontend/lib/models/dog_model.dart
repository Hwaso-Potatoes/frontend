// lib/models/dog_model.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 (나중에 물어볼 목록) ──
// 1. personalities 필드에 들어오는 전체 값 목록 (지금 확인된 건 "energy" 뿐)
// 2. "권장 산책 거리"(monthlyWalkGoal) 값을 어디서 받아올지
// 3. "연속 산책일수"(consecutiveDays)를 어디서 받아올지
// 4. "전체 누적 거리"(totalDistance, 평생 누적)를 받을 수 있는지

/// 프로필 화면에서 쓰는 강아지 데이터
class DogModel {
  final String name;
  final String breed;
  final int age;
  final int level;

  final List<String> personalityTags;

  final int currentExp;
  final int requiredExp;

  final double monthlyWalkDistance;
  final double monthlyWalkGoal;
  final int achievementRate;

  final double totalDistance;
  final int consecutiveDays;
  final int badgeCount;
  final List<String> ownedBadgeImagePaths;

  const DogModel({
    required this.name,
    required this.breed,
    required this.age,
    required this.level,
    required this.personalityTags,
    required this.currentExp,
    required this.requiredExp,
    required this.monthlyWalkDistance,
    required this.monthlyWalkGoal,
    required this.achievementRate,
    required this.totalDistance,
    required this.consecutiveDays,
    required this.badgeCount,
    required this.ownedBadgeImagePaths,
  });
}

/// birth_date("2024-08-01" 같은 문자열)로 나이 계산
int calculateAgeFromBirthDate(String birthDate) {
  final birth = DateTime.parse(birthDate);
  final now = DateTime.now();
  int age = now.year - birth.year;
  if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
    age -= 1;
  }
  return age;
}

/// 더미 데이터
final DogModel dummyDog = DogModel(
  name: '두부',
  breed: '비숑', // png export 완료되어 원래대로 복원
  age: calculateAgeFromBirthDate('2024-08-01'),

  level: 1,
  currentExp: 30,
  requiredExp: 100,

  personalityTags: const ['에너지형', '호기심형'],

  monthlyWalkDistance: 0.0,
  monthlyWalkGoal: 48.0,
  achievementRate: 0,

  totalDistance: 286.0,
  consecutiveDays: 12,

  badgeCount: 3,
  ownedBadgeImagePaths: [
    'http://127.0.0.1:8000/media/badges/example1.png',
    'http://127.0.0.1:8000/media/badges/example2.png',
    'http://127.0.0.1:8000/media/badges/example3.png',
  ],
);