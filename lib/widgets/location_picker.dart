import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/widgets/app_line_icon.dart';

/// 存放位置選擇器。位置是選填，所以「未指定」永遠是第一個選項。
class LocationPicker extends StatelessWidget {
  const LocationPicker({
    super.key,
    required this.locations,
    required this.selectedId,
    required this.onChanged,
  });

  final List<StorageLocation> locations;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final knownIds = locations.map((location) => location.id).toSet();
    final value = knownIds.contains(selectedId) ? selectedId : null;

    return DropdownButtonFormField<String?>(
      initialValue: value,
      // 沒有 isExpanded 時，選單項目會在無限寬度下佈局，
      // 裡面的 Flexible 會 assert 失敗並讓整頁空白。
      isExpanded: true,
      decoration: InputDecoration(labelText: S.of(context).storageLocation),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(S.of(context).noLocation),
        ),
        ...locations.map(
          (location) => DropdownMenuItem<String?>(
            value: location.id,
            child: Row(
              children: [
                AppLineIcon(
                  kind: locationIconKind(location.kind),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(location.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  AppLineIconKind locationIconKind(LocationKind kind) => switch (kind) {
        LocationKind.refrigerated => AppLineIconKind.refrigerated,
        LocationKind.frozen => AppLineIconKind.frozen,
        LocationKind.ambient => AppLineIconKind.ambient,
        LocationKind.other => AppLineIconKind.otherStorage,
      };
}
