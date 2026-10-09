import 'package:flutter/material.dart';
import '../models/accessory_render_catalog.dart';
import '../services/api_service.dart';

/// 카탈로그의 이름은 표시용이며 보상/보유 여부는 서버 응답을 그대로 사용한다.
String rewardAccessoryDisplayName(int? accessoryId, String? serverName) {
  for (final item in previewAccessories) {
    if (item.accessoryId == accessoryId) return item.name;
  }
  final name = serverName?.trim();
  return name == null || name.isEmpty ? '액세서리 정보 확인 중' : name;
}

/// 서버 accessory.id를 PNG에 매핑하고 썸네일 경계로 투명 여백을 제거한다.
class RewardAccessoryImage extends StatelessWidget {
  final int? accessoryId;
  final String? serverImage;
  final double size;
  const RewardAccessoryImage({
    super.key,
    required this.accessoryId,
    this.serverImage,
    required this.size,
  });

  Widget _missing() => Icon(Icons.image_not_supported_outlined,
    size: size * 0.55, color: const Color(0xFF636037));

  @override
  Widget build(BuildContext context) {
    final spec = accessoryRenderCatalog[accessoryId];
    if (spec != null) {
      final bounds = spec.thumbnailBounds;
      return SizedBox(width: size, height: size,
        child: Padding(padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(spec.asset,
            // 에셋 전체를 먼저 로드해야 경계 바깥까지 포함한 PNG가 잘린다.
            frameBuilder: (context, image, frame, synchronouslyLoaded) {
              if (frame == null && !synchronouslyLoaded) {
                return const Center(child: SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)));
              }
              return FittedBox(fit: BoxFit.contain,
                child: ClipRect(child: SizedBox(
                  width: bounds.width, height: bounds.height,
                  child: Stack(clipBehavior: Clip.hardEdge, children: [
                    Positioned(left: -bounds.left, top: -bounds.top,
                      width: spec.canvasSize.width, height: spec.canvasSize.height,
                      child: image),
                  ]),
                )));
            },
            fit: BoxFit.fill,
            errorBuilder: (_, error, __) {
              debugPrint('[출석 액세서리 $accessoryId] 카탈로그 에셋 로딩 실패: ${spec.asset}');
              return _missing();
            },
          ),
        ),
      );
    }
    // 신규 ID가 아직 카탈로그에 없으면 서버 URL을 사용할 수 있다.
    final image = ApiService.resolveMediaUrl(serverImage);
    return SizedBox(width: size, height: size,
      child: image == null ? _missing()
          : image.startsWith('assets/')
              ? Image.asset(image, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _missing())
              : Image.network(image, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _missing()));
  }
}
