import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/active_pet_model.dart';

class PetIdentity extends StatelessWidget {
  final ActivePet pet;
  final bool centered;
  const PetIdentity({super.key, required this.pet, this.centered = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      Text(
        pet.name,
        style: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '${pet.breed} · ${pet.age == null ? '생일 미등록' : '${pet.age}세'}${centered ? ' · Lv.${pet.level}' : ''}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
        ),
      ),
    ],
  );
}
