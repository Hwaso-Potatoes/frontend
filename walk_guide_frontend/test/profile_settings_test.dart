import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk_guide_frontend/models/active_pet_model.dart';
import 'package:walk_guide_frontend/screens/account_settings_screen.dart';
import 'package:walk_guide_frontend/screens/edit_profile_screen.dart';
import 'package:walk_guide_frontend/services/active_pet_store.dart';

void main() {
  setUp(() {
    final store = ActivePetStore.instance;
    store.reset();
    store.user = {
      'id': 1,
      'nickname': '반려인',
      'email': 'reader@example.invalid',
    };
    store.pet = const ActivePet(
      id: 1,
      name: '두부',
      breed: '비숑',
      birthDate: null,
      personalities: ['timid'],
      level: 1,
    );
  });
  testWidgets('missing birthday is safe and prevents saving invented age', (
    tester,
  ) async {
    for (final size in [const Size(320, 640), const Size(402, 874)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('생년월일을 선택해 주세요'), findsOneWidget);
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[0].controller!.text, '반려인');
      expect(fields[1].controller!.text, '두부');
      await tester.tap(find.text('저장하기'));
      await tester.pumpAndSettle();
      expect(find.text('생년월일을 선택해주세요.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets(
    'account email is readonly with no email-change route or chevron',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      await tester.pumpWidget(const MaterialApp(home: AccountSettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('reader@example.invalid'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await tester.tap(find.text('이메일'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountSettingsScreen), findsOneWidget);
      expect(find.text('이메일 변경'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    },
  );
}
