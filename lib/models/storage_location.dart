import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// 存放方式。這是唯一參與程式判斷的欄位（保存期限建議依它決定）；
/// 使用者自訂的 [StorageLocation.name] 永遠不參與邏輯（design D14）。
enum LocationKind { refrigerated, frozen, ambient, other }

/// 使用者自訂的存放位置（「冰箱上層」「蔬果室」「儲藏櫃」）。
class StorageLocation extends HiveObject {
  StorageLocation({
    required this.id,
    required this.name,
    required this.kind,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final LocationKind kind;
  final int sortOrder;

  StorageLocation copyWith({
    String? id,
    String? name,
    LocationKind? kind,
    int? sortOrder,
  }) {
    return StorageLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'sortOrder': sortOrder,
      };

  factory StorageLocation.fromJson(Map<String, dynamic> data) {
    return StorageLocation(
      id: data['id'] as String,
      name: data['name'] as String,
      kind: LocationKind.values.firstWhere(
        (value) => value.name == data['kind'],
        orElse: () => LocationKind.other,
      ),
      sortOrder: (data['sortOrder'] as int?) ?? 0,
    );
  }

  String toJsonString() => json.encode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageLocation &&
        other.id == id &&
        other.name == name &&
        other.kind == kind &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(id, name, kind, sortOrder);
}
