import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/bloc/app_bloc.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/repositories/backup_repository.dart';
import 'package:food_savior/widgets/avatar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isRestoring = false;
  bool _isBackingUp = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).userPageTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('UserPage_logout_iconButton'),
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              context.read<AppBloc>().add(const AppLogoutRequested());
            },
          ),
        ],
      ),
      body: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(photo: user.photo),
            const SizedBox(height: 4),
            Text(user.email ?? '', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(user.name ?? '', style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('UserPage_backup_button'),
              onPressed: _isBackingUp || _isRestoring ? null : _backup,
              child: _isBackingUp
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(S.of(context).backup),
            ),
            ElevatedButton(
              key: const Key('UserPage_restore_button'),
              onPressed: _isBackingUp || _isRestoring ? null : _restore,
              child: _isRestoring
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(S.of(context).restore),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backup() async {
    final l10n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final userId = context.read<AppBloc>().state.user.id;
    final foodItems =
        context.read<FoodItemListBloc>().foodItemRepository.getAllFoodItems();
    final usedFoodItems = context
        .read<UsedFoodItemListBloc>()
        .usedFoodItemRepository
        .getAllUsedFoodItems();
    final backupRepository = context.read<BackupRepository>();

    setState(() => _isBackingUp = true);
    try {
      await backupRepository.backup(
        userId: userId,
        foodItems: foodItems,
        usedFoodItems: usedFoodItems,
      );
      _show(messenger, l10n.backupSuccess);
    } on BackupFailure catch (failure) {
      _show(messenger, '${l10n.backupFailure}：${_describe(failure, l10n)}');
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restore() async {
    final l10n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final userId = context.read<AppBloc>().state.user.id;
    final foodItemListBloc = context.read<FoodItemListBloc>();
    final usedFoodItemListBloc = context.read<UsedFoodItemListBloc>();
    final backupRepository = context.read<BackupRepository>();

    setState(() => _isRestoring = true);
    try {
      // 先把雲端資料抓回來，確定成功才覆蓋本機；失敗或沒有備份時本機資料不動
      final snapshot = await backupRepository.restore(userId: userId);
      if (snapshot == null) {
        _show(messenger, l10n.restoreNoBackup);
        return;
      }
      usedFoodItemListBloc.add(
        UsedFoodItemListLoad(usedFoodItems: snapshot.usedFoodItems),
      );
      foodItemListBloc.add(FoodItemListLoad(foodItems: snapshot.foodItems));
      _show(messenger, l10n.restoreSuccess);
    } on BackupFailure catch (failure) {
      _show(messenger, '${l10n.restoreFailure}：${_describe(failure, l10n)}');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  String _describe(BackupFailure failure, S l10n) {
    switch (failure.reason) {
      case BackupFailureReason.offline:
        return l10n.errorOffline;
      case BackupFailureReason.timeout:
        return l10n.errorTimeout;
      case BackupFailureReason.permissionDenied:
        return l10n.errorPermissionDenied;
      case BackupFailureReason.unknown:
        return failure.message ?? l10n.errorUnknown;
    }
  }

  void _show(ScaffoldMessengerState messenger, String message) {
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
