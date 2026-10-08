import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/decoration_model.dart';
import '../../models/accessory_render_catalog.dart';
import '../../models/dog_accessory_layouts.dart';
import '../icons/dog_icon.dart';
import '../asset_viewport.dart';

/// Shared character compositor. Coordinates include the dog's transparent canvas.
class DogCharacter extends StatelessWidget {
  final String breed;
  final double size;
  final EquippedAccessories equipped;
  const DogCharacter({
    super.key,
    required this.breed,
    required this.size,
    this.equipped = const EquippedAccessories(),
  });

  @override
  Widget build(BuildContext context) {
    final layout = dogAccessoryLayouts[dogBreedKey(breed)];
    final hairSpec = accessoryRenderCatalog[equipped.hair?.accessoryId];
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DogIcon(breed: breed, size: size),
          if (layout != null) ...[
            ..._layer(equipped.shoes, layout.shoes),
            ..._layer(equipped.clothes, layout.clothes),
            ..._layer(equipped.cape, layout.cape),
            if (hairSpec?.hairType != null)
              ..._layer(
                equipped.hair,
                hairSpec!.hairType == HairRenderType.hat
                    ? layout.hat
                    : layout.pin,
              ),
          ],
        ],
      ),
    );
  }

  List<Widget> _layer(AccessoryItem? item, AccessoryPlacement placement) {
    if (item == null) return const [];
    final spec = accessoryRenderCatalog[item.accessoryId];
    // Unknown IDs never inherit a guessed subtype or incorrect local asset.
    if (spec == null) return const [];
    placement =
        dogAccessoryPlacementOverrides[dogBreedKey(breed)]?[item.accessoryId] ??
        placement;
    final scale = size / 350 * placement.scale;
    final width = spec.originalSize.width * scale;
    final height = spec.originalSize.height * scale;
    return [
      Positioned(
        key: ValueKey('accessory-${item.accessoryId}'),
        left: size * placement.xPercent / 100,
        top: size * placement.yPercent / 100,
        child: Transform.rotate(
          angle: placement.rotationDegrees * math.pi / 180,
          alignment: Alignment.topLeft,
          child: AccessoryArtwork(spec: spec, width: width, height: height),
        ),
      ),
    ];
  }
}

/// Removes export padding through a viewport, without altering the original PNG.
class AccessoryArtwork extends StatelessWidget {
  final AccessoryRenderSpec spec;
  final double width, height;
  const AccessoryArtwork({
    super.key,
    required this.spec,
    required this.width,
    required this.height,
  });
  @override
  Widget build(BuildContext context) {
    final frame = spec.sourceFrame;
    if (frame == null) {
      return Image.asset(spec.asset, width: width, height: height);
    }
    return AssetViewport(
      asset: spec.asset,
      canvas: spec.canvasSize,
      frame: frame,
      width: width,
      height: height,
    );
  }
}
