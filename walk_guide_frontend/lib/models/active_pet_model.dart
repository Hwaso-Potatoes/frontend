import 'decoration_model.dart';
import 'accessory_render_catalog.dart';

const personalityLabels = <String, String>{
  'energy': '에너지형',
  'social': '사회성형',
  'timid': '겁쟁이형',
  'curious': '호기심형',
  'relaxed': '느긋형',
  'calm': '얌전형',
};

DateTime? parseBirthDate(dynamic value) {
  final text = value?.toString() ?? '';
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return null;
  final date = DateTime.tryParse(text);
  if (date == null || apiDate(date) != text || date.isAfter(DateTime.now()))
    return null;
  return DateTime(date.year, date.month, date.day);
}

String apiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
int? petAge(DateTime? birth, {DateTime? today}) {
  if (birth == null) return null;
  final now = today ?? DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day))
    age--;
  return age < 0 ? null : age;
}

class ActivePet {
  final int id, level;
  final String name, breed;
  final DateTime? birthDate;
  final List<String> personalities;
  const ActivePet({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.personalities,
    required this.level,
  });
  factory ActivePet.fromJson(Map<String, dynamic> json) => ActivePet(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    breed: json['breed']?.toString() ?? '',
    birthDate: parseBirthDate(json['birth_date']),
    personalities: List<String>.from(json['personalities'] as List? ?? []),
    level: (json['level'] as num?)?.toInt() ?? 1,
  );
  int? get age => petAge(birthDate);
  List<String> get traits =>
      personalities.map((p) => personalityLabels[p] ?? p).toList();
}

List<AccessoryItem> mergeAccessories(List<dynamic> all, List<dynamic> owned) {
  final byId = <int, Map<String, dynamic>>{};
  for (final value in owned) {
    final record = Map<String, dynamic>.from(value as Map);
    final accessory = record['accessory'] as Map;
    byId[(accessory['id'] as num).toInt()] = record;
  }
  final result = <AccessoryItem>[];
  for (final value in all) {
    final item = Map<String, dynamic>.from(value as Map);
    final id = (item['id'] as num).toInt();
    final record = byId[id];
    final category = item['category']?.toString();
    if (!['HAIR', 'CAPE', 'CLOTHES', 'SHOES'].contains(category)) continue;
    result.add(
      AccessoryItem(
        ownershipId: (record?['id'] as num?)?.toInt(),
        accessoryId: id,
        name: item['name'] as String,
        image: accessoryRenderCatalog[id]?.asset ?? '',
        category: accessoryCategoryFromString(category!),
        isOwned: record != null,
        isEquipped: record?['is_equipped'] == true,
      ),
    );
  }
  result.sort((a, b) => a.accessoryId.compareTo(b.accessoryId));
  return result;
}
