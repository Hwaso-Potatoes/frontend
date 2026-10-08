import 'package:flutter/foundation.dart';
import '../models/active_pet_model.dart';
import '../models/decoration_model.dart';
import 'api_service.dart';

typedef PetRequest =
    Future<dynamic> Function(
      String method,
      String path, {
      Map<String, dynamic>? body,
    });

/// Shared account/pet snapshot. Widgets render it; mutation succeeds only after
/// the server confirms it. No credentials are stored in this notifier.
class ActivePetStore extends ChangeNotifier {
  static final instance = ActivePetStore();
  final PetRequest request;
  final Future<String?> Function() userId;
  final Future<void> Function(int) persistPetId;
  ActivePetStore({
    PetRequest? request,
    Future<String?> Function()? userId,
    Future<void> Function(int)? persistPetId,
  }) : request = request ?? ApiService.requestData,
       userId = userId ?? ApiService.getUserId,
       persistPetId = persistPetId ?? ApiService.savePetId;
  ActivePet? pet;
  Map<String, dynamic> user = {};
  List<AccessoryItem> accessories = [];
  Map<String, dynamic>? growth;
  List<dynamic>? badges;
  String? error, accessoriesError, summaryError;
  int? errorStatus;
  bool loading = false, saving = false, equipping = false;
  bool _accessoryMutationPending = false;
  int _generation = 0;
  Future<void>? _loading;
  EquippedAccessories get equipped =>
      EquippedAccessories.fromItems(accessories);
  void reset() {
    _generation++;
    _loading = null;
    pet = null;
    user = {};
    accessories = [];
    growth = null;
    badges = null;
    error = null;
    errorStatus = null;
    accessoriesError = null;
    summaryError = null;
    loading = false;
    saving = false;
    equipping = false;
    _accessoryMutationPending = false;
    notifyListeners();
  }

  Future<void> ensureLoaded() =>
      _loading ?? (pet == null ? refresh() : Future.value());
  Future<void> refresh() {
    if (_loading != null) return _loading!;
    final future = _load();
    _loading = future;
    return future.whenComplete(() {
      if (identical(_loading, future)) _loading = null;
    });
  }

  Future<void> _load() async {
    final generation = _generation;
    loading = true;
    error = null;
    errorStatus = null;
    notifyListeners();
    try {
      final uid = await userId();
      if (uid == null) throw ApiException(401, '로그인이 필요합니다.');
      final values = await Future.wait([
        request('GET', '/api/users/$uid/'),
        request('GET', '/api/pets/'),
      ]);
      final pets = values[1] as List;
      if (pets.isEmpty) throw ApiException(404, '등록된 반려견이 없습니다.');
      final nextPet = ActivePet.fromJson(
        Map<String, dynamic>.from(pets.first as Map),
      );
      if (generation != _generation) return;
      pet = nextPet;
      user = Map<String, dynamic>.from(values[0] as Map);
      await persistPetId(nextPet.id);
      if (generation != _generation) return;
      // Accessory/summary failures have independent UI states, not fake data.
      await Future.wait([reloadAccessories(), _loadSummary()]);
    } catch (e) {
      if (generation == _generation) {
        error = e is ApiException ? e.message : '반려견 정보를 불러오지 못했습니다.';
        errorStatus = e is ApiException ? e.statusCode : null;
      }
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> reloadAccessories() async {
    final id = pet?.id;
    if (id == null) return;
    final generation = _generation;
    try {
      final values = await Future.wait([
        request('GET', '/api/accessories/'),
        request('GET', '/api/pets/$id/accessories/'),
      ]);
      if (generation != _generation) return;
      accessories = mergeAccessories(values[0] as List, values[1] as List);
      accessoriesError = null;
      _accessoryMutationPending = false;
    } catch (_) {
      if (generation == _generation)
        accessoriesError = '장착 정보를 확인하지 못했습니다. 다시 조회해주세요.';
    }
    if (generation == _generation) notifyListeners();
  }

  Future<void> _loadSummary() async {
    final id = pet!.id;
    final generation = _generation;
    try {
      final values = await Future.wait([
        request('GET', '/api/pets/$id/growth/'),
        request('GET', '/api/pets/$id/badges/'),
      ]);
      if (generation != _generation) return;
      growth = Map<String, dynamic>.from(values[0] as Map);
      badges = values[1] as List;
      summaryError = null;
    } catch (_) {
      if (generation == _generation) {
        growth = null;
        badges = null;
        summaryError = '성장·뱃지 정보를 불러오지 못했습니다.';
      }
    }
  }

  Future<void> setAccessory(AccessoryItem item) async {
    if (!item.isOwned || equipping || loading) return;
    if (_accessoryMutationPending || accessoriesError != null) {
      await reloadAccessories();
      throw StateError('서버 장착 상태를 다시 조회했습니다. 확인 후 선택해주세요.');
    }
    final id = pet!.id;
    final generation = _generation;
    equipping = true;
    notifyListeners();
    try {
      await request(
        'POST',
        '/api/pets/$id/accessories/${item.accessoryId}/${item.isEquipped ? 'unequip' : 'equip'}/',
      );
      if (generation != _generation) return;
      _accessoryMutationPending = true;
      await reloadAccessories();
      if (accessoriesError != null)
        throw StateError('변경 요청은 성공했지만 장착 상태 재조회가 필요합니다.');
    } catch (e) {
      // A lost response may already have changed server state. Reconcile before
      // another mutation; never retry a POST merely because it timed out.
      if (generation == _generation &&
          (e is! ApiException || e.statusCode >= 500))
        _accessoryMutationPending = true;
      rethrow;
    } finally {
      if (generation == _generation) {
        equipping = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveProfile({
    required String nickname,
    required String name,
    required DateTime birthDate,
    required List<String> personalities,
  }) async {
    if (saving) return;
    final generation = _generation;
    final petId = pet!.id;
    final ownerId = user['id'];
    saving = true;
    notifyListeners();
    try {
      await request(
        'PATCH',
        '/api/users/$ownerId/',
        body: {'nickname': nickname},
      );
      if (generation != _generation) return;
      try {
        await request(
          'PATCH',
          '/api/pets/$petId/',
          body: {
            'name': name,
            'birth_date': apiDate(birthDate),
            'personalities': personalities,
          },
        );
      } catch (_) {
        if (generation != _generation) return;
        await refresh();
        throw StateError('반려인 이름은 저장됐지만 반려견 정보 저장에 실패했습니다. 다시 확인해주세요.');
      }
      if (generation != _generation) return;
      await refresh();
      if (error != null) throw StateError('저장은 완료됐지만 정보 재조회가 필요합니다.');
    } finally {
      if (generation == _generation) {
        saving = false;
        notifyListeners();
      }
    }
  }
}
