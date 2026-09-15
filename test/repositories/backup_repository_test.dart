import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/backup_repository.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BackupRepository repo;
  const uid = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = BackupRepository(firestore: firestore);
  });

  FoodItem food(String id) => makeFood(
        id: id,
        name: '牛奶 $id',
        storageDate: DateTime(2026, 9, 1),
        expirationDate: DateTime(2026, 9, 10),
      );
  UsedFoodItem used(String id) => makeUsed(
        id: id,
        usedDate: DateTime(2026, 9, 5, 12),
        affectFoodPoint: 1,
      );

  group('BackupRepository（cloud-backup-restore）', () {
    test('backup 寫入 backups/{uid}，內容為 JSON 字串陣列並帶 updatedAt', () async {
      await repo.backup(
        userId: uid,
        foodItems: [food('a'), food('b')],
        usedFoodItems: [used('u')],
      );

      final doc = await firestore
          .collection(BackupRepository.collectionPath)
          .doc(uid)
          .get();
      expect(doc.exists, isTrue);
      expect((doc.data()!['foodItems'] as List).length, 2);
      expect((doc.data()!['usedFoodItems'] as List).length, 1);
      expect(doc.data()!['foodItems'].first, isA<String>());
      expect(doc.data()!.containsKey('updatedAt'), isTrue);
    });

    test('backup → restore 往返，內容相等', () async {
      final foods = [food('a'), food('b')];
      final useds = [used('u')];
      await repo.backup(userId: uid, foodItems: foods, usedFoodItems: useds);

      final snapshot = await repo.restore(userId: uid);

      expect(snapshot, isNotNull);
      expect(snapshot!.foodItems, foods);
      expect(snapshot.usedFoodItems, useds);
    });

    test('再次 backup 完全取代舊備份', () async {
      await repo.backup(
          userId: uid,
          foodItems: [food('a'), food('b')],
          usedFoodItems: const []);
      await repo
          .backup(userId: uid, foodItems: [food('c')], usedFoodItems: const []);

      final snapshot = await repo.restore(userId: uid);
      expect(ids(snapshot!.foodItems), ['c']);
    });

    test('沒有備份 → null（呼叫端不得清空本機）', () async {
      expect(await repo.restore(userId: 'nobody'), isNull);
    });

    test('不同使用者互不可見', () async {
      await repo
          .backup(userId: 'A', foodItems: [food('a')], usedFoodItems: const []);
      expect(await repo.restore(userId: 'B'), isNull);
    });

    test('備份中缺 affectFoodPoint → 0；非字串項目被忽略', () async {
      final raw = used('u').toJson()..remove('affectFoodPoint');
      await firestore.collection(BackupRepository.collectionPath).doc(uid).set({
        'foodItems': [food('a').toJsonString(), 42],
        'usedFoodItems': [
          UsedFoodItem.fromJson(raw)
              .toJsonString()
              .replaceFirst(',"affectFoodPoint":0', ''),
        ],
      });

      final snapshot = await repo.restore(userId: uid);
      expect(ids(snapshot!.foodItems), ['a']);
      expect(snapshot.usedFoodItems.single.affectFoodPoint, 0);
    });
  });

  group('BackupFailure.from（錯誤對應）', () {
    test('TimeoutException → timeout', () {
      expect(BackupFailure.from(TimeoutException('t')).reason,
          BackupFailureReason.timeout);
    });

    test('Firestore unavailable → offline', () {
      final failure = BackupFailure.from(
        FirebaseException(
            plugin: 'cloud_firestore', code: 'unavailable', message: 'offline'),
      );
      expect(failure.reason, BackupFailureReason.offline);
      expect(failure.message, 'offline');
    });

    test('permission-denied → permissionDenied；其他 code → unknown 並保留 code', () {
      expect(
        BackupFailure.from(FirebaseException(
                plugin: 'cloud_firestore', code: 'permission-denied'))
            .reason,
        BackupFailureReason.permissionDenied,
      );
      final other = BackupFailure.from(
        FirebaseException(
            plugin: 'cloud_firestore', code: 'internal', message: 'boom'),
      );
      expect(other.reason, BackupFailureReason.unknown);
      expect(other.message, 'internal: boom');
    });

    test('已是 BackupFailure 則原樣回傳', () {
      const f = BackupFailure(BackupFailureReason.offline);
      expect(identical(BackupFailure.from(f), f), isTrue);
    });
  });
}
