// lib/screens/decorate_screen.dart

import 'package:flutter/material.dart';
import '../services/active_pet_store.dart';
import '../models/decoration_model.dart';
import '../widgets/decoration/category_tabs.dart';
import '../widgets/decoration/accessory_grid.dart';
import '../widgets/decoration/dog_stage.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

/// 악세사리 꾸미기 화면
class DecorationScreen extends StatefulWidget {
  final ActivePetStore? store;
  final String? initialAccessoryName;
  final AccessoryItem? initialAccessoryItem;

  const DecorationScreen({
    super.key,
    this.store,
    this.initialAccessoryName,
    this.initialAccessoryItem,
  });

  @override
  State<DecorationScreen> createState() => _DecorationScreenState();
}

class _DecorationScreenState extends State<DecorationScreen> {
  AccessoryCategory _selectedCategory = AccessoryCategory.hair;
  ActivePetStore get _store => widget.store ?? ActivePetStore.instance;
  List<AccessoryItem> get _items => _store.accessories;
  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.initialAccessoryItem?.category ?? AccessoryCategory.hair;
    _store.ensureLoaded();
  }

  List<AccessoryItem> get _filteredItems =>
      _items.where((item) => item.category == _selectedCategory).toList();

  Future<void> _handleTap(AccessoryItem tapped) async {
    try {
      await _store.setAccessory(tapped);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) => _buildDecoration(context),
  );
  Widget _buildDecoration(BuildContext context) {
    final state = _store;
    final dog = state.pet;
    if (dog == null)
      return Scaffold(
        body: Center(
          child: state.loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error ?? '반려견 정보가 없습니다.'),
                    TextButton(
                      onPressed: state.refresh,
                      child: const Text('다시 조회'),
                    ),
                  ],
                ),
        ),
      );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 뒤로가기 + "OO 꾸미기" 타이틀 (내 친구 화면과 스타일 통일) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 24,
                          color: Color(0xFF636037),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${dog.name} 꾸미기',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                          height: 1.1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 언덕(상단 고정) + 크림색 시트(겹쳐서 올라옴) ──
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;

                  // 언덕이 실제로 렌더링될 높이 (AspectRatio 402:430 기준)
                  final double hillRenderedHeight =
                      availableWidth *
                      (DogStage.designHeight / DogStage.designWidth);

                  // 시트 시작점(원본 404, 90만큼 당겼으니 314)을
                  // 언덕의 실제 렌더 높이에 비례해서 계산
                  final double sheetTop =
                      hillRenderedHeight * (314 / DogStage.designHeight);

                  return Stack(
                    children: [
                      // 언덕: 화면 위쪽에 고정
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: DogStage(
                          dogBreed: dog.breed,
                          equipped: EquippedAccessories.fromItems(_items),
                        ),
                      ),
                      // 시트: 언덕 아래쪽과 겹치며 화면 끝까지 채움
                      Positioned(
                        top: sheetTop,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, -5),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CategoryTabs(
                                  selected: _selectedCategory,
                                  onChanged: (category) {
                                    setState(
                                      () => _selectedCategory = category,
                                    );
                                  },
                                ),
                                const SizedBox(height: 25),
                                if (state.accessoriesError != null)
                                  TextButton(
                                    onPressed: state.reloadAccessories,
                                    child: Text(state.accessoriesError!),
                                  ),
                                if (state.equipping || state.loading)
                                  const LinearProgressIndicator(),
                                if (!state.loading &&
                                    state.accessoriesError == null &&
                                    _filteredItems.isEmpty)
                                  const Text('표시할 액세서리가 없습니다.'),
                                IgnorePointer(
                                  ignoring:
                                      state.equipping ||
                                      state.loading ||
                                      state.accessoriesError != null,
                                  child: AccessoryGrid(
                                    items: _filteredItems,
                                    onTap: _handleTap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
