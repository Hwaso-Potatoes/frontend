// lib/models/mission_model.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 (나중에 물어볼 목록, 지우지 말 것) ──
// 1. 미션 목록에 보상 미리보기 정보(reward_type, reward_name/image, reward_exp 등) 추가 필요
// 2. status 값 전체 목록 (지금까지 확인된 건 "IN_PROGRESS" 뿐)
// 3. 보상 수령 엔드포인트 정확한 URL
// 4. 뱃지/경험치 보상일 때 claim 응답 형태
// 5. 이미지 URL 경로 불일치 (이전 뱃지 API는 절대경로, 이번 액세서리는 상대경로) -> base URL 확인 필요
//
// 지금은 이 정보들이 없어서, 아래 모델은 전부 Figma 디자인 기준 "더미" 필드로 구성됨.
// 실제 연결 시 이 파일 구조를 API 버전으로 다시 바꿔야 함.

/// 미션 하나의 데이터를 담는 모델 (Figma 디자인 기준)
class MissionModel {
  final int order;              // 순서 번호 (미완료일 때 원 안에 표시되는 숫자)
  final String title;           // 미션 제목 (예: "첫 산책 시작하기")
  final String rewardText;      // 보상 설명 (예: "보상: 뱃지 '첫 발걸음' + 10 XP")
  final bool isCompleted;       // 완료 여부 (완료면 왼쪽 원이 체크 표시로 바뀜)
  final double progress;        // 진행률 0.0 ~ 1.0 (게이지바 채워지는 정도)
  final String? progressLabel;  // "0/2 완료" 같은 진행 카운트 텍스트, 없으면 null
  final bool hasBoxReward;      // true면 게이지 100% 찼을 때 "박스 열기" 버튼 표시

  const MissionModel({
    required this.order,
    required this.title,
    required this.rewardText,
    required this.isCompleted,
    required this.progress,
    this.progressLabel,
    this.hasBoxReward = false,
  });
}

/// 더미 데이터 - 일일 미션
/// 나중에 서버 연결되면 API 응답을 이 형태로 매핑해서 교체하면 됨
final List<MissionModel> dummyDailyMissions = [
  const MissionModel(
    order: 1,
    title: '첫 산책 시작하기',
    rewardText: "보상: 뱃지 '첫 발걸음' + 10 XP",
    isCompleted: true,
    progress: 1.0,
  ),
  const MissionModel(
    order: 2,
    title: '새로운 친구 반려견 만나기',
    rewardText: '보상: + 15XP',
    isCompleted: false,
    progress: 0.0,
    progressLabel: '0 / 2 완료',
  ),
  const MissionModel(
    order: 3,
    title: '30분 이상 산책하기',
    rewardText: '보상: 액세서리 박스 + 10XP',
    isCompleted: false,
    progress: 1.0, // 게이지 꽉 참 -> 박스 열기 버튼 노출
    hasBoxReward: true,
  ),
  const MissionModel(
    order: 4,
    title: '저녁 시간대 산책하기',
    rewardText: "보상: 뱃지 '노을' + 5 PX",
    isCompleted: false,
    progress: 0.0,
  ),
];

/// 더미 데이터 - 주간 미션
final List<MissionModel> dummyWeeklyMissions = [
  const MissionModel(
    order: 1,
    title: '산책 중 사진 공유하기',
    rewardText: '보상: + 10 XP',
    isCompleted: true,
    progress: 1.0,
  ),
  const MissionModel(
    order: 2,
    title: '새 친구 찾기',
    rewardText: '보상: + 15XP',
    isCompleted: false,
    progress: 0.0,
    progressLabel: '0 / 3 완료',
  ),
  MissionModel(
    order: 3,
    title: '누적 15km 산책하기',
    rewardText: '보상: 액세서리 박스 + 20XP',
    isCompleted: false,
    progress: 2 / 15, // 아직 게이지 안 참 -> 박스 열기 버튼 숨김
    progressLabel: '2 / 15 완료',
    hasBoxReward: true,
  ),
  const MissionModel(
    order: 4,
    title: '새로운 산책경로 2곳 가보기',
    rewardText: '보상: 액세서리 박스 + 10 PX',
    isCompleted: false,
    progress: 0.0, // 아직 게이지 안 참 -> 박스 열기 버튼 숨김
    progressLabel: '0 / 2 완료',
    hasBoxReward: true,
  ),
  MissionModel(
    order: 5,
    title: '5일 연속 산책하기',
    rewardText: "보상: 뱃지 '산책의 달인' + 20 PX",
    isCompleted: false,
    progress: 1 / 5,
    progressLabel: '1 / 5 완료',
  ),
];