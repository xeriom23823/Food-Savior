import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/cubits/storage_location_cubit.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/app_line_icon.dart';
import 'package:food_savior/widgets/app_scaffold.dart';
import 'package:food_savior/widgets/confirm_sheet.dart';
import 'package:food_savior/widgets/empty_state.dart';

AppLineIconKind _locationIconKind(LocationKind kind) => switch (kind) {
      LocationKind.refrigerated => AppLineIconKind.refrigerated,
      LocationKind.frozen => AppLineIconKind.frozen,
      LocationKind.ambient => AppLineIconKind.ambient,
      LocationKind.other => AppLineIconKind.otherStorage,
    };

/// 存放位置管理（storage-locations 規格）。
class StorageLocationPage extends StatelessWidget {
  const StorageLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocBuilder<StorageLocationCubit, StorageLocationState>(
      builder: (context, state) {
        return AppScaffold(
          title: strings.storageLocations,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(context, null),
            icon: const Icon(Icons.add),
            label: Text(strings.addLocation),
          ),
          body: state.locations.isEmpty
              ? EmptyState(
                  icon: Icons.shelves,
                  illustrationAsset: AppAssets.emptyStorageLocations,
                  title: strings.emptyLocationsTitle,
                  description: strings.emptyLocationsDescription,
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl * 2,
                  ),
                  itemCount: state.locations.length,
                  onReorderItem: (oldIndex, newIndex) => context
                      .read<StorageLocationCubit>()
                      .reorder(oldIndex, newIndex),
                  itemBuilder: (context, index) {
                    final location = state.locations[index];
                    return Card(
                      key: ValueKey(location.id),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: AppLineIcon(
                          kind: _locationIconKind(location.kind),
                        ),
                        title: Text(location.name),
                        subtitle: Text(location.kind.localizedName(context)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(context, location),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                          ],
                        ),
                        onTap: () => _edit(context, location),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, StorageLocation location) async {
    final cubit = context.read<StorageLocationCubit>();
    final strings = S.of(context);
    final count = cubit.itemCountOf(location);

    final confirmed = await ConfirmSheet.show(
      context,
      title: '${strings.deleteLocation} · ${location.name}',
      message: strings.deleteLocationMessage(count),
      confirmLabel: strings.delete,
    );
    if (confirmed) await cubit.delete(location);
  }

  Future<void> _edit(BuildContext context, StorageLocation? location) async {
    final cubit = context.read<StorageLocationCubit>();
    final result = await showModalBottomSheet<_LocationDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LocationEditor(location: location),
    );
    if (result == null) return;

    if (location == null) {
      await cubit.add(name: result.name, kind: result.kind);
    } else {
      await cubit.rename(location, result.name);
      await cubit.changeKind(location, result.kind);
    }
  }
}

class _LocationDraft {
  const _LocationDraft({required this.name, required this.kind});

  final String name;
  final LocationKind kind;
}

class _LocationEditor extends StatefulWidget {
  const _LocationEditor({this.location});

  final StorageLocation? location;

  @override
  State<_LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<_LocationEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.location?.name ?? '');
  late LocationKind _kind = widget.location?.kind ?? LocationKind.refrigerated;
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.location == null
                    ? strings.addLocation
                    : strings.editLocation,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: strings.name,
                  errorText:
                      _showError ? strings.locationNameCannotBeEmpty : null,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: LocationKind.values
                    .map((kind) => ChoiceChip(
                          avatar: AppLineIcon(
                            kind: _locationIconKind(kind),
                            size: 16,
                          ),
                          label: Text(kind.localizedName(context)),
                          selected: _kind == kind,
                          onSelected: (_) => setState(() => _kind = kind),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () {
                  final name = _controller.text.trim();
                  if (name.isEmpty) {
                    setState(() => _showError = true);
                    return;
                  }
                  Navigator.of(context)
                      .pop(_LocationDraft(name: name, kind: _kind));
                },
                child: Text(strings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
