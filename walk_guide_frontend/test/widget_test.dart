import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk_guide_frontend/models/friend_model.dart';
import 'package:walk_guide_frontend/screens/report_screen.dart';
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
    await tester.pumpWidget(harness(const ReportScreen(), 1));
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
    expect(find.text('${DateTime.now().year - 1}'), findsOneWidget);
    await tester.tap(find.byTooltip('다음 기간'));
    await tester.pumpAndSettle();
    expect(find.text('${DateTime.now().year}'), findsOneWidget);
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
