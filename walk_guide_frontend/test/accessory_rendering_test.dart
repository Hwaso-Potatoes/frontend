import 'package:flutter/material.dart';
import 'package:walk_guide_frontend/services/active_pet_store.dart';
import 'package:walk_guide_frontend/models/active_pet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk_guide_frontend/models/accessory_render_catalog.dart';
import 'package:walk_guide_frontend/models/decoration_model.dart';
import 'package:walk_guide_frontend/models/dog_accessory_layouts.dart';
import 'package:walk_guide_frontend/widgets/decoration/dog_character.dart';
import 'package:walk_guide_frontend/screens/decorate_screen.dart';
import 'package:walk_guide_frontend/models/friend_model.dart';
import 'package:walk_guide_frontend/widgets/friend_detail_dialog.dart';
import 'package:walk_guide_frontend/widgets/icons/accessory_icon.dart';
import 'package:walk_guide_frontend/widgets/asset_viewport.dart';

void main() {
  testWidgets('narrow cards keep thumbnail bounds centered and unclipped', (
    tester,
  ) async {
    for (final availableSize in [24.0, 42.0]) {
      for (final spec in accessoryRenderCatalog.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.square(
                dimension: availableSize,
                child: AccessoryIcon(imageUrl: spec.asset),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final finder = find.byType(AssetViewport);
        final viewport = tester.widget<AssetViewport>(finder);
        expect(viewport.width, lessThanOrEqualTo(availableSize));
        expect(viewport.height, lessThanOrEqualTo(availableSize));
        expect(
          (tester.getCenter(finder) -
                  tester.getCenter(find.byType(AccessoryIcon)))
              .distance,
          lessThan(0.001),
        );
        expect(
          viewport.width / viewport.height,
          closeTo(
            spec.thumbnailBounds.width / spec.thumbnailBounds.height,
            0.0001,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });
  testWidgets(
    'server IDs keep Figma order and thumbnails use independent artwork bounds',
    (tester) async {
      expect(
        previewAccessories.map((item) => item.accessoryId).toList(),
        List.generate(23, (i) => i + 1),
      );
      expect(accessoryRenderCatalog[1]!.asset, endsWith('beanie_brown.png'));
      expect(accessoryRenderCatalog[14]!.asset, endsWith('cape_birthday.png'));
      expect(accessoryRenderCatalog[18]!.asset, endsWith('clothes_green.png'));
      for (final spec in accessoryRenderCatalog.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.square(
                dimension: 72,
                child: AccessoryIcon(imageUrl: spec.asset),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final viewport = tester.widget<AssetViewport>(
          find.byType(AssetViewport),
        );
        expect(viewport.frame, spec.thumbnailBounds);
        expect(viewport.width <= 48 && viewport.height <= 48, isTrue);
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('friend detail uses the same equipped character renderer', (
    tester,
  ) async {
    final equipped = EquippedAccessories.fromItems([
      for (final id in [4, 17, 20, 22])
        previewAccessories
            .firstWhere((item) => item.accessoryId == id)
            .copyWith(isEquipped: true),
    ]);
    final friend = Friend(
      id: 99,
      nickname: '검증 친구',
      pets: [FriendPet(id: 99, name: '두부', breed: '비숑', equipped: equipped)],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FriendDetailDialog(friend: friend)),
      ),
    );
    await tester.pumpAndSettle();
    for (final id in [4, 17, 20, 22]) {
      expect(find.byKey(ValueKey('accessory-$id')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
  test('PDF zero size fallback and 18 breed mappings', () {
    expect(dogAccessoryLayouts.length, 18);
    expect(dogAccessoryLayouts['bichon']!.clothes.scale, 1);
    expect(dogAccessoryLayouts['beagle']!.clothes.rotationDegrees, -10.7);
    expect(AccessoryCategory.values.map((x) => x.apiValue), [
      'HAIR',
      'CAPE',
      'CLOTHES',
      'SHOES',
    ]);
  });
  testWidgets('all breeds and assets render at two sizes without exceptions', (
    tester,
  ) async {
    for (final size in [128.0, 256.0]) {
      for (final breed in dogAccessoryLayouts.keys) {
        for (final item in previewAccessories) {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: DogCharacter(
                  breed: breed,
                  size: size,
                  equipped: EquippedAccessories.fromItems([
                    item.copyWith(isEquipped: true),
                  ]),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$breed ${item.name} $size',
          );
          expect(
            find.byKey(ValueKey('accessory-${item.accessoryId}')),
            findsOneWidget,
          );
        }
      }
    }
  });
  testWidgets(
    'category toggle keeps other categories and unequips on second tap',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(402, 874));
      final owned = previewAccessories
          .map(
            (item) => {
              'id': item.accessoryId,
              'accessory': {'id': item.accessoryId},
              'is_equipped': false,
            },
          )
          .toList();
      final catalog = previewAccessories
          .map(
            (item) => {
              'id': item.accessoryId,
              'name': item.name,
              'category': item.category.apiValue,
            },
          )
          .toList();
      final store = ActivePetStore(
        request: (method, path, {body}) async {
          if (method == 'POST') {
            final id = int.parse(path.split('/')[5]);
            final item = previewAccessories.firstWhere(
              (item) => item.accessoryId == id,
            );
            for (final row in owned) {
              final rowId = row['id'] as int;
              if (previewAccessories
                      .firstWhere((item) => item.accessoryId == rowId)
                      .category ==
                  item.category)
                row['is_equipped'] = false;
            }
            owned.firstWhere((row) => row['id'] == id)['is_equipped'] = path
                .endsWith('/equip/');
            return {};
          }
          return path == '/api/accessories/' ? catalog : owned;
        },
      );
      store.pet = const ActivePet(
        id: 1,
        name: '두부',
        breed: '비숑',
        birthDate: null,
        personalities: [],
        level: 1,
      );
      store.accessories = mergeAccessories(catalog, owned);
      await tester.pumpWidget(
        MaterialApp(home: DecorationScreen(store: store)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('accessory-choice-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('accessory-1')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('accessory-choice-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('accessory-1')), findsNothing);
      expect(find.byKey(const ValueKey('accessory-2')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('accessory-choice-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('accessory-2')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('accessory-choice-1')));
      await tester.tap(find.text('케이프'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('accessory-choice-14')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('accessory-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('accessory-14')), findsOneWidget);
      await tester.binding.setSurfaceSize(const Size(320, 640));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    },
  );
}
