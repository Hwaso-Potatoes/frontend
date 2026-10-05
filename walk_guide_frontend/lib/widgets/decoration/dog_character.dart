import 'package:flutter/material.dart';
import '../../models/decoration_model.dart';
import '../icons/dog_icon.dart';

/// Shared by decoration and friend scenes. Other accessory categories can be
/// added here once their assets and breed-specific anchors are available.
class DogCharacter extends StatelessWidget {
  final String breed;
  final double size;
  final AccessoryItem? equippedHair;

  const DogCharacter({
    super.key,
    required this.breed,
    required this.size,
    this.equippedHair,
  });

  @override
  Widget build(BuildContext context) {
    final anchor = defaultAnchors[AccessoryCategory.hair]!;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          DogIcon(breed: breed, size: size),
          if (equippedHair != null && equippedHair!.image.isNotEmpty)
            Align(
              alignment: Alignment(
                anchor.position.dx * 2 - 1,
                anchor.position.dy * 2 - 1,
              ),
              child: FractionallySizedBox(
                widthFactor: anchor.scale,
                child: Image.network(
                  equippedHair!.image,
                  errorBuilder: (_, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
