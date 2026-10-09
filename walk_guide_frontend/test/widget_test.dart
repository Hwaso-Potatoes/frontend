import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk_guide_frontend/models/friend_model.dart';
import 'package:walk_guide_frontend/models/active_pet_model.dart';
import 'package:walk_guide_frontend/services/active_pet_store.dart';
import 'package:walk_guide_frontend/screens/report_screen.dart';
import 'package:walk_guide_frontend/screens/badge_book_screen.dart';
import 'package:walk_guide_frontend/models/badge_model.dart';
import 'package:walk_guide_frontend/screens/friend_screen.dart';
import 'package:walk_guide_frontend/widgets/custom_widgets.dart';
import 'package:walk_guide_frontend/widgets/decoration/dog_character.dart';

final captureKey = GlobalKey();
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter');
    inter.addFont(rootBundle.load('assets/fonts/Inter_18pt-Regular.ttf'));
    for (final weight in ['Medium', 'SemiBold', 'Bold']) {
      inter.addFont(rootBundle.load('assets/fonts/Inter_18pt-$weight.ttf'));
    }
    await inter.load();
    final sdkRoot = Platform.environment['FLUTTER_ROOT'];
    final iconsFile = File(
      '$sdkRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (iconsFile.existsSync()) {
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        Future.value(ByteData.sublistView(iconsFile.readAsBytesSync())),
      );
      await icons.load();
    }
    final koreanFile = File('C:/Windows/Fonts/malgun.ttf');
    if (koreanFile.existsSync()) {
      final korean = FontLoader('Korean');
      korean.addFont(
        Future.value(ByteData.sublistView(koreanFile.readAsBytesSync())),
      );
      final boldFile = File('C:/Windows/Fonts/malgunbd.ttf');
      if (boldFile.existsSync()) {
        korean.addFont(
          Future.value(ByteData.sublistView(boldFile.readAsBytesSync())),
        );
      }
      await korean.load();
    }
  });
  Widget harness(Widget screen, int index) => RepaintBoundary(
    key: captureKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        fontFamilyFallback: const ['Korean'],
      ),
      home: Scaffold(
        extendBody: true,
        body: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => screen),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: index,
          onTap: (_) {},
        ),
      ),
    ),
  );
  Future<void> capture(WidgetTester tester, String name) async {
    expect(tester.takeException(), isNull);
    const directory = String.fromEnvironment('CAPTURE_DIR');
    if (directory.isEmpty) return;
    await tester.runAsync(() async {
      final boundary =
          captureKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(directory).create(recursive: true);
      await File(
        '$directory/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('Report periods and date navigation render without overflow', (
    tester,
  ) async {
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(402, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = ActivePetStore()
      ..pet = ActivePet.fromJson({'id': 1, 'name': '두부', 'breed': '비숑'});
    Future<dynamic> request(
      String method,
      String path, {
      Map<String, dynamic>? body,
    }) async {
      if (path == '/api/attendance/summary/')
        return {'current_streak': 5, 'best_streak': 9};
      final query = Uri.parse(path).queryParameters;
      final period = query['period']!;
      final labels = period == 'DAY'
          ? ['아침', '점심', '오후', '저녁']
          : period == 'MONTH'
          ? ['1주', '2주', '3주', '4주']
          : ['7월', '8월', '9월', '10월'];
      final peak = period == 'DAY'
          ? '저녁'
          : period == 'MONTH'
          ? '3주'
          : '10월';
      return {
        'period': period,
        'date': query['date'],
        'start_date': query['date'],
        'end_date': query['date'],
        'comparison': {
          'current_distance_km': 3.0,
          'baseline_distance_km': 2.0,
          'difference_km': 1.0,
          'baseline_type': period == 'DAY'
              ? 'RECENT_AVERAGE'
              : period == 'MONTH'
              ? 'PREVIOUS_MONTH'
              : 'PREVIOUS_YEAR',
        },
        'trend': {
          'current': [
            {'key': 0, 'label': '시작', 'distance_km': 0.0},
            {'key': 1, 'label': '끝', 'distance_km': 3.0},
          ],
          'comparison': [
            {'key': 0, 'label': '시작', 'distance_km': 1.0},
            {'key': 1, 'label': '끝', 'distance_km': 2.0},
          ],
        },
        'highlight': {
          'top_label': peak,
          'top_distance_km': 1.8,
          'items': labels
              .map(
                (label) => {
                  'key': label,
                  'label': label,
                  'distance_km': label == peak ? 1.8 : 0.4,
                },
              )
              .toList(),
        },
      };
    }

    await tester.pumpWidget(
      harness(ReportScreen(store: store, request: request), 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('하루'), findsOneWidget);
    expect(find.text('저녁'), findsOneWidget);
    await capture(tester, 'report-day');
    await tester.tap(find.text('월간'));
    await tester.pumpAndSettle();
    expect(find.text('3주'), findsOneWidget);
    await capture(tester, 'report-month');
    await tester.tap(find.text('연간'));
    await tester.pumpAndSettle();
    expect(find.text('10월'), findsOneWidget);
    await capture(tester, 'report-year');
    await tester.tap(find.byTooltip('이전 기간'));
    await tester.pumpAndSettle();
    expect(find.text('${DateTime.now().year - 1}년'), findsOneWidget);
    await tester.tap(find.byTooltip('다음 기간'));
    await tester.pumpAndSettle();
    expect(find.text('${DateTime.now().year}년'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(320, 640);
    await tester.pumpAndSettle();
    for (final label in ['하루', '월간', '연간']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();
      final lastLabel = label == '하루'
          ? '저녁'
          : label == '월간'
          ? '4주'
          : '10월';
      expect(
        tester.getBottomLeft(find.text(lastLabel)).dy,
        lessThanOrEqualTo(
          tester.getTopLeft(find.byType(CustomBottomNavBar)).dy,
        ),
      );
      expect(tester.takeException(), isNull);
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
    }
    debugDisableShadows = true;
  });
  testWidgets(
    'Badge book renders server ownership, details and retry at narrow widths',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = ActivePetStore()
        ..pet = ActivePet.fromJson({'id': 1, 'name': '두부', 'breed': '비숑'});
      var fail = false;
      Future<List<BadgeModel>> loader(int id) async {
        if (fail) throw StateError('offline');
        return List.generate(
          19,
          (i) => BadgeModel(
            id: i + 1,
            name: i == 0
                ? '첫 친구'
                : i == 1
                ? '진화의 달인'
                : '뱃지 ${i + 1}',
            description: i == 0 ? '처음 친구 추가시 획득' : '서버 획득 조건',
            isOwned: {1, 5, 13}.contains(i + 1),
            acquiredAt: {1, 5, 13}.contains(i + 1)
                ? DateTime.utc(2026, 10, 9, 1)
                : null,
          ),
        );
      }

      await tester.pumpWidget(
        harness(BadgeBookScreen(store: store, loader: loader), 4),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 / 19 보유'), findsOneWidget);
      await capture(tester, 'badge-book');
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pumpAndSettle();
      expect(find.text('첫 친구'), findsOneWidget);
      await capture(tester, 'badge-owned');
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).at(2));
      await tester.pumpAndSettle();
      expect(find.text('진화의 달인'), findsOneWidget);
      await capture(tester, 'badge-unowned');
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      fail = true;
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
      );
      await tester.pumpAndSettle();
      expect(find.text('다시 조회'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('다시 조회'));
      await tester.pumpAndSettle();
      expect(find.text('3 / 19 보유'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Friend detail, cancel, deletion, re-fetch and preview refresh', (
    tester,
  ) async {
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(harness(const FriendScreen(), 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('더보기'));
    await tester.pumpAndSettle();
    expect(find.text('5명'), findsOneWidget);
    await capture(tester, 'friends-list');
    await tester.tap(find.text('토리 (포메라니안)'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<DogCharacter>(find.byType(DogCharacter)).breed,
      '포메라니안',
    );
    await capture(tester, 'friend-detail');
    await tester.tap(find.byTooltip('친구 메뉴'));
    await tester.pumpAndSettle();
    await capture(tester, 'friend-menu');
    await tester.tap(find.text('친구 삭제하기'));
    await tester.pumpAndSettle();
    await capture(tester, 'friend-delete-confirm');
    await tester.tap(find.text('아니요'));
    await tester.pumpAndSettle();
    expect((await mockFetchMyFriends()).length, 5);
    await tester.tap(find.text('토리 (포메라니안)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('친구 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('친구 삭제하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('토리 (포메라니안)'), findsNothing);
    expect(find.text('4명'), findsOneWidget);
    expect(find.text('친구 삭제가 완료되었습니다.'), findsOneWidget);
    expect((await mockFetchMyFriends()).any((f) => f.id == 1), false);
    final rowPosition = tester.getTopLeft(find.text('밀크 (말티즈)'));
    await capture(tester, 'friend-deleted');
    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.text('친구 삭제가 완료되었습니다.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('친구 삭제가 완료되었습니다.'), findsNothing);
    expect(tester.getTopLeft(find.text('밀크 (말티즈)')), rowPosition);
    expect(find.text('4명'), findsOneWidget);
    await capture(tester, 'friend-feedback-hidden');
    await tester.tap(find.text('밀크 (말티즈)'));
    await tester.pumpAndSettle();
    expect(tester.widget<DogCharacter>(find.byType(DogCharacter)).breed, '말티즈');
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pumpAndSettle();
    expect(find.text('토리 (포메라니안)'), findsNothing);
    expect(find.text('밀크 (말티즈)'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '휴지');
    await tester.pumpAndSettle();
    expect(find.text('휴지 (푸들)'), findsOneWidget);
    expect(find.text('밀크 (말티즈)'), findsNothing);
    expect(tester.takeException(), isNull);
    debugDisableShadows = true;
  });
}
