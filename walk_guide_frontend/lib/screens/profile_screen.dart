import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/active_pet_store.dart';
import '../widgets/decoration/dog_character.dart';
import '../widgets/pet_identity.dart';
import '../widgets/personality_tag.dart';
import '../widgets/stat_card.dart';
import '../widgets/exp_bar.dart';
import '../widgets/icons/badge_icon.dart';
import 'badge_book_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ActivePetStore.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ActivePetStore.instance,
    builder: (context, _) {
      final state = ActivePetStore.instance;
      final pet = state.pet;
      if (pet == null)
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9E5),
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
      final growth = state.growth;
      final required = int.tryParse(
        growth?['required_experience']?.toString() ?? '',
      );
      final current = int.tryParse(growth?['experience']?.toString() ?? '');
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9E5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '프로필',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Color(0xFF636037),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9AA80).withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DogCharacter(
                        breed: pet.breed,
                        size: 190,
                        equipped: state.equipped,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(child: PetIdentity(pet: pet, centered: true)),
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: pet.traits
                          .map((t) => PersonalityTag(label: t, homeStyle: true))
                          .toList(),
                    ),
                  ),
                  if (state.accessoriesError != null)
                    Center(
                      child: TextButton(
                        onPressed: state.reloadAccessories,
                        child: const Text('장착 정보 다시 조회'),
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (current != null && required != null && required > 0)
                    ExpBar(currentExp: current, requiredExp: required)
                  else
                    Text(
                      state.summaryError ?? '경험치 정보가 없습니다.',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      const Expanded(
                        child: StatCard(value: '—', label: '누적 거리'),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: StatCard(value: '—', label: '연속 산책'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: state.badges == null
                              ? '—'
                              : '${state.badges!.length}개',
                          label: '획득 뱃지',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '보유 뱃지',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BadgeBookScreen(),
                          ),
                        ),
                        child: const Text('더보기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  if (state.badges != null && state.badges!.isEmpty)
                    const Text('아직 획득한 뱃지가 없습니다.')
                  else
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: (state.badges ?? []).take(3).map<Widget>((row) {
                        final badge = row['badge'] as Map;
                        return Container(
                          width: 65,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFA9AA80,
                            ).withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: BadgeIcon(
                            badgeId: (badge['id'] as num).toInt(),
                            imageUrl: null,
                            size: 54,
                          ),
                        );
                      }).toList(),
                    ),
                  if (state.summaryError != null)
                    TextButton(
                      onPressed: state.refresh,
                      child: const Text('프로필 정보 다시 조회'),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
