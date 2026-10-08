import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk_guide_frontend/models/active_pet_model.dart';
import 'package:walk_guide_frontend/services/active_pet_store.dart';
import 'package:walk_guide_frontend/services/api_service.dart';

class Server {
  final calls = <String>[];
  final user = <String, dynamic>{'id': 10, 'nickname': '반려인'};
  final pet = <String, dynamic>{
    'id': 30,
    'name': '두부',
    'breed': '비숑',
    'birth_date': '2020-08-25',
    'personalities': ['timid'],
    'level': 1,
  };
  final catalog = [
    {'id': 1, 'name': '헤어1', 'category': 'HAIR', 'image': 'invalid-url'},
    {'id': 2, 'name': '헤어2', 'category': 'HAIR'},
    {'id': 14, 'name': '케이프1', 'category': 'CAPE'},
  ];
  final owned = <Map<String, dynamic>>[
    {
      'id': 901,
      'accessory': {'id': 1},
      'is_equipped': false,
    },
    {
      'id': 902,
      'accessory': {'id': 14},
      'is_equipped': true,
    },
  ];
  bool failRead = false, failPetPatch = false;
  ActivePetStore store() => ActivePetStore(
    request: request,
    userId: () async => '10',
    persistPetId: (_) async {},
  );
  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    calls.add('$method $path');
    if (method == 'PATCH') {
      if (path.contains('/users/')) {
        user.addAll(body!);
        return null;
      }
      if (failPetPatch) throw ApiException(400, 'Invalid pet');
      pet.addAll(body!);
      return null;
    }
    if (method == 'POST') {
      final id = int.parse(path.split('/')[5]);
      owned.firstWhere(
        (r) => (r['accessory'] as Map)['id'] == id,
      )['is_equipped'] = path.endsWith(
        '/equip/',
      );
      return owned.first;
    }
    if (path == '/api/users/10/') return Map.of(user);
    if (path == '/api/pets/') return [Map.of(pet)];
    if (path == '/api/accessories/') return catalog;
    if (path.endsWith('/accessories/')) {
      if (failRead) throw ApiException(503, 'Read failed');
      return owned;
    }
    if (path.endsWith('/growth/'))
      return {'experience': '15', 'required_experience': '100'};
    if (path.endsWith('/badges/')) return [];
    throw StateError('Unexpected path $path');
  }
}

void main() {
  test('birthdate validates exceptions and birthday boundary', () {
    expect(parseBirthDate(null), isNull);
    expect(parseBirthDate('2020-02-31'), isNull);
    expect(parseBirthDate('2999-01-01'), isNull);
    expect(petAge(DateTime(2020, 8, 25), today: DateTime(2026, 8, 24)), 5);
    expect(petAge(DateTime(2020, 8, 25), today: DateTime(2026, 8, 25)), 6);
  });
  test(
    'catalog uses accessory ID rather than ownership ID or server image',
    () async {
      final server = Server();
      final store = server.store();
      await store.refresh();
      expect(store.error, isNull);
      expect(store.accessories.length, 3);
      expect(store.accessories.first.ownershipId, 901);
      expect(store.accessories.first.image, startsWith('assets/'));
      expect(store.accessories[1].isOwned, false);
      expect(store.equipped.cape?.accessoryId, 14);
      expect(store.pet!.personalities, ['timid']);
    },
  );
  test(
    'unowned item never sends POST; owned mutation re-reads server',
    () async {
      final server = Server();
      final store = server.store();
      await store.refresh();
      server.calls.clear();
      await store.setAccessory(store.accessories[1]);
      expect(server.calls, isEmpty);
      await store.setAccessory(store.accessories.first);
      expect(server.calls.first, 'POST /api/pets/30/accessories/1/equip/');
      expect(server.calls, contains('GET /api/pets/30/accessories/'));
      expect(store.equipped.hair?.accessoryId, 1);
      expect(store.equipped.cape?.accessoryId, 14);
      await store.setAccessory(store.accessories.first);
      expect(store.equipped.hair, isNull);
    },
  );
  test(
    'successful POST but failed GET requires reconciliation, no POST replay',
    () async {
      final server = Server();
      final store = server.store();
      await store.refresh();
      server.calls.clear();
      server.failRead = true;
      await expectLater(
        store.setAccessory(store.accessories.first),
        throwsStateError,
      );
      expect(store.accessoriesError, isNotNull);
      server.failRead = false;
      await expectLater(
        store.setAccessory(store.accessories.first),
        throwsStateError,
      );
      expect(server.calls.where((c) => c.startsWith('POST')).length, 1);
      expect(store.equipped.hair?.accessoryId, 1);
    },
  );
  test(
    '204 PATCH refreshes shared nickname, name, date and personalities',
    () async {
      final server = Server();
      final store = server.store();
      await store.refresh();
      await store.saveProfile(
        nickname: '새이름',
        name: '콩이',
        birthDate: DateTime(2021, 1, 2),
        personalities: ['social', 'curious'],
      );
      expect(store.user['nickname'], '새이름');
      expect(store.pet!.name, '콩이');
      expect(apiDate(store.pet!.birthDate!), '2021-01-02');
      expect(store.pet!.personalities, ['social', 'curious']);
      expect(store.saving, false);
    },
  );
  test(
    'partial save reloads actual server state and reports failure',
    () async {
      final server = Server();
      final store = server.store();
      await store.refresh();
      server.failPetPatch = true;
      await expectLater(
        store.saveProfile(
          nickname: '새이름',
          name: '콩이',
          birthDate: DateTime(2021),
          personalities: [],
        ),
        throwsStateError,
      );
      expect(store.user['nickname'], '새이름');
      expect(store.pet!.name, '두부');
    },
  );
  test(
    'missing session retains unauthorized status for the login action',
    () async {
      final store = ActivePetStore(
        userId: () async => null,
        persistPetId: (_) async {},
        request: (m, p, {body}) async => throw StateError('Must not send'),
      );
      await store.refresh();
      expect(store.errorStatus, 401);
      expect(store.pet, isNull);
      expect(store.loading, false);
    },
  );
  test('reset discards previous account response', () async {
    final gate = Completer<dynamic>();
    final store = ActivePetStore(
      userId: () async => '10',
      persistPetId: (_) async {},
      request: (m, p, {body}) => p.contains('/users/')
          ? gate.future
          : Future.value([
              {'id': 30, 'name': '두부', 'breed': '비숑'},
            ]),
    );
    final load = store.refresh();
    await Future<void>.delayed(Duration.zero);
    store.reset();
    gate.complete({'id': 10});
    await load;
    expect(store.pet, isNull);
    expect(store.user, isEmpty);
  });
}
