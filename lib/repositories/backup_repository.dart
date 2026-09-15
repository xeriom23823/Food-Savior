import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_savior/models/food_item.dart';

/// 備份／還原失敗的原因，供 UI 對應 l10n 訊息（cloud-backup-restore 規格）。
enum BackupFailureReason { offline, timeout, permissionDenied, unknown }

class BackupFailure implements Exception {
  const BackupFailure(this.reason, [this.message]);

  factory BackupFailure.from(Object error) {
    if (error is BackupFailure) return error;
    if (error is TimeoutException) {
      return const BackupFailure(BackupFailureReason.timeout);
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return BackupFailure(BackupFailureReason.offline, error.message);
        case 'deadline-exceeded':
          return BackupFailure(BackupFailureReason.timeout, error.message);
        case 'permission-denied':
          return BackupFailure(
            BackupFailureReason.permissionDenied,
            error.message,
          );
        default:
          return BackupFailure(
            BackupFailureReason.unknown,
            '${error.code}: ${error.message}',
          );
      }
    }
    return BackupFailure(BackupFailureReason.unknown, error.toString());
  }

  final BackupFailureReason reason;
  final String? message;

  @override
  String toString() =>
      'BackupFailure(${reason.name}${message == null ? '' : ', $message'})';
}

/// 一份雲端備份的內容。
class BackupSnapshot {
  const BackupSnapshot({required this.foodItems, required this.usedFoodItems});

  final List<FoodItem> foodItems;
  final List<UsedFoodItem> usedFoodItems;
}

/// 唯一觸碰 Firestore `backups/{uid}` 的層。
/// 每個操作都有 [timeout]；失敗一律轉成 [BackupFailure]，UI 不會看到 Firestore 例外。
class BackupRepository {
  BackupRepository({
    FirebaseFirestore? firestore,
    this.timeout = const Duration(seconds: 15),
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String collectionPath = 'backups';

  final FirebaseFirestore _firestore;
  final Duration timeout;

  DocumentReference<Map<String, dynamic>> _document(String userId) =>
      _firestore.collection(collectionPath).doc(userId);

  /// 覆蓋該使用者的整份備份。
  Future<void> backup({
    required String userId,
    required List<FoodItem> foodItems,
    required List<UsedFoodItem> usedFoodItems,
  }) async {
    try {
      await _document(userId).set({
        'foodItems': foodItems.map((item) => item.toJsonString()).toList(),
        'usedFoodItems':
            usedFoodItems.map((item) => item.toJsonString()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(timeout);
    } catch (error) {
      throw BackupFailure.from(error);
    }
  }

  /// 讀取雲端備份；沒有備份回傳 null。一律向伺服器讀取，離線時失敗而不是回傳快取。
  Future<BackupSnapshot?> restore({required String userId}) async {
    try {
      final document = await _document(userId)
          .get(const GetOptions(source: Source.server))
          .timeout(timeout);
      final data = document.data();
      if (!document.exists || data == null) return null;
      return BackupSnapshot(
        foodItems: _decode(data['foodItems'], FoodItem.fromJsonString),
        usedFoodItems:
            _decode(data['usedFoodItems'], UsedFoodItem.fromJsonString),
      );
    } catch (error) {
      throw BackupFailure.from(error);
    }
  }

  static List<T> _decode<T>(Object? raw, T Function(String) fromJsonString) {
    if (raw is! List) return const [];
    return raw.whereType<String>().map(fromJsonString).toList();
  }
}
