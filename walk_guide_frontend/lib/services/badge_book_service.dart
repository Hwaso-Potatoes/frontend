import '../models/badge_model.dart';
import 'api_service.dart';

/// Ownership is determined only by a successful server response.
List<BadgeModel> mergeBadges(List<dynamic> master, List<dynamic> owned) {
  final ownership = <int, BadgeModel>{};
  for (final row in owned) {
    final badge = BadgeModel.fromOwnedJson(
      Map<String, dynamic>.from(row as Map),
    );
    ownership[badge.id] = badge;
  }
  final result = master.map((row) {
    final badge = BadgeModel.fromJson(Map<String, dynamic>.from(row as Map));
    final acquired = ownership[badge.id];
    return acquired == null
        ? badge
        : badge.copyWith(isOwned: true, acquiredAt: acquired.acquiredAt);
  }).toList()..sort((a, b) => a.id.compareTo(b.id));
  return result;
}

class BadgeBookService {
  static Future<List<BadgeModel>> load(int petId) async {
    final results = await Future.wait([
      ApiService.requestData('GET', '/api/badges/'),
      ApiService.requestData('GET', '/api/pets/$petId/badges/'),
    ]);
    return mergeBadges(results[0] as List, results[1] as List);
  }
}
