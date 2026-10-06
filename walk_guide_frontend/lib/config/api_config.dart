// lib/config/api_config.dart
//
// 서버 주소를 한 곳에서만 관리하기 위한 설정 파일.
// - 기존에는 API는 'http://localhost'(nginx, 80포트),
//   이미지(media)는 'http://127.0.0.1:8000'(Django runserver)로 서로 다른 서버를
//   하드코딩하고 있어서, docker/nginx로 백엔드를 띄우면 8000 포트는 닫혀 있어
//   ERR_CONNECTION_REFUSED가 발생했음.
//
// 실행 시 주소를 바꾸고 싶으면:
//   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
//   flutter run -d chrome --dart-define=USE_MOCK=false

/// 백엔드 API/미디어 공통 base URL (끝에 '/' 붙이지 말 것)
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost',
);

/// true면 ApiService가 실제 서버 대신 목 데이터를 반환
const bool kUseMockData = bool.fromEnvironment('USE_MOCK', defaultValue: true);

/// 백엔드가 "/media/..." 같은 상대경로를 내려주는 경우가 있어서(accessory 응답 등)
/// 화면에 띄우기 전에 절대 URL로 바꿔주는 헬퍼.
String? resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return path.startsWith('/') ? '$kApiBaseUrl$path' : '$kApiBaseUrl/$path';
}
