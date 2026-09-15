import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/bloc/app_bloc.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/cubits/food_points_cubit.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_points_summary.dart';
import 'package:food_savior/pages/user/edit_name_sheet.dart';
import 'package:food_savior/pages/user/score_section.dart';
import 'package:food_savior/repositories/backup_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/app_scaffold.dart';
import 'package:food_savior/widgets/app_snack_bar.dart';
import 'package:food_savior/widgets/avatar.dart';
import 'package:food_savior/widgets/confirm_sheet.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:food_savior/widgets/section_header.dart';

/// 用戶分頁：上半是「我的成績」，下半是帳號與資料管理（user-profile 規格）。
class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodPointsCubit(
        usedFoodItemRepository: context.read<UsedFoodItemRepository>(),
      ),
      child: const _UserView(),
    );
  }
}

class _UserView extends StatefulWidget {
  const _UserView();

  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isDeleting = false;

  bool get _busy => _isBackingUp || _isRestoring || _isDeleting;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocListener<UsedFoodItemListBloc, UsedFoodItemListState>(
      // 別的分頁寫了紀錄，成績要跟著更新。
      listener: (context, state) => context.read<FoodPointsCubit>().refresh(),
      child: AppScaffold(
        title: strings.userPageTitle,
        body: BlocBuilder<FoodPointsCubit, FoodPointsSummary>(
          builder: (context, summary) {
            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                SectionHeader(title: strings.myScore),
                if (!summary.hasRecords)
                  _padded(EmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: strings.emptyScoreTitle,
                    description: strings.emptyScoreDescription,
                  ))
                else ...[
                  _padded(LevelCard(summary: summary)),
                  const SizedBox(height: AppSpacing.lg),
                  _padded(PointsStatRow(summary: summary)),
                  SectionHeader(title: strings.milestones),
                  _padded(MilestoneList(summary: summary)),
                ],
                SectionHeader(title: strings.accountSection),
                _padded(_AccountCard(
                  busy: _busy,
                  isBackingUp: _isBackingUp,
                  isRestoring: _isRestoring,
                  isDeleting: _isDeleting,
                  onEditName: _editName,
                  onBackup: _backup,
                  onRestore: _restore,
                  onResetPassword: _resetPassword,
                  onLogOut: _logOut,
                  onDeleteAccount: _deleteAccount,
                )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _padded(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: child,
      );

  Future<void> _editName() async {
    final user = context.read<AppBloc>().state.user;
    final repository = context.read<AuthenticationRepository>();
    final strings = S.of(context);

    final name = await EditNameSheet.show(context, initialName: user.name);
    if (name == null) return;

    try {
      await repository.updateDisplayName(name);
      _show(strings.nameUpdated);
    } on UpdateDisplayNameFailure {
      _show(strings.nameUpdateFailure, isError: true);
    }
  }

  Future<void> _resetPassword() async {
    final user = context.read<AppBloc>().state.user;
    final repository = context.read<AuthenticationRepository>();
    final strings = S.of(context);
    final email = user.email;
    if (email == null || email.isEmpty) {
      _show(strings.invalidEmail, isError: true);
      return;
    }

    try {
      await repository.sendPasswordResetEmail(email);
      _show(strings.resetPasswordSent);
    } on ResetPasswordFailure {
      _show(strings.resetPasswordFailure, isError: true);
    }
  }

  void _logOut() => context.read<AppBloc>().add(const AppLogoutRequested());

  Future<void> _deleteAccount() async {
    final repository = context.read<AuthenticationRepository>();
    final strings = S.of(context);

    final confirmed = await ConfirmSheet.show(
      context,
      title: strings.deleteAccount,
      message: strings.deleteAccountMessage,
      confirmLabel: strings.deleteAccount,
    );
    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await repository.deleteAccount();
    } on DeleteAccountFailure catch (failure) {
      _show(
        failure.reason == DeleteAccountFailureReason.requiresRecentLogin
            ? strings.deleteAccountRequiresRecentLogin
            : strings.deleteAccountFailure,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _backup() async {
    final strings = S.of(context);
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
      _show(strings.backupSuccess);
    } on BackupFailure catch (failure) {
      _show('${strings.backupFailure}：${_describe(failure, strings)}',
          isError: true);
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restore() async {
    final strings = S.of(context);
    final userId = context.read<AppBloc>().state.user.id;
    final foodItemListBloc = context.read<FoodItemListBloc>();
    final usedFoodItemListBloc = context.read<UsedFoodItemListBloc>();
    final pointsCubit = context.read<FoodPointsCubit>();
    final backupRepository = context.read<BackupRepository>();

    setState(() => _isRestoring = true);
    try {
      // 先把雲端資料抓回來，確定成功才覆蓋本機；失敗或沒有備份時本機資料不動
      final snapshot = await backupRepository.restore(userId: userId);
      if (snapshot == null) {
        _show(strings.restoreNoBackup, isError: true);
        return;
      }
      usedFoodItemListBloc.add(
        UsedFoodItemListLoad(usedFoodItems: snapshot.usedFoodItems),
      );
      foodItemListBloc.add(FoodItemListLoad(foodItems: snapshot.foodItems));
      pointsCubit.refresh();
      _show(strings.restoreSuccess);
    } on BackupFailure catch (failure) {
      _show('${strings.restoreFailure}：${_describe(failure, strings)}',
          isError: true);
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  String _describe(BackupFailure failure, S strings) {
    switch (failure.reason) {
      case BackupFailureReason.offline:
        return strings.errorOffline;
      case BackupFailureReason.timeout:
        return strings.errorTimeout;
      case BackupFailureReason.permissionDenied:
        return strings.errorPermissionDenied;
      case BackupFailureReason.unknown:
        return failure.message ?? strings.errorUnknown;
    }
  }

  void _show(String message, {bool isError = false}) {
    if (!mounted) return;
    AppSnackBar.show(
      context,
      message: message,
      kind: isError ? AppSnackBarKind.error : AppSnackBarKind.success,
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.busy,
    required this.isBackingUp,
    required this.isRestoring,
    required this.isDeleting,
    required this.onEditName,
    required this.onBackup,
    required this.onRestore,
    required this.onResetPassword,
    required this.onLogOut,
    required this.onDeleteAccount,
  });

  final bool busy;
  final bool isBackingUp;
  final bool isRestoring;
  final bool isDeleting;
  final VoidCallback onEditName;
  final VoidCallback onBackup;
  final VoidCallback onRestore;
  final VoidCallback onResetPassword;
  final VoidCallback onLogOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final hasName = (user.name ?? '').trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Avatar(photo: user.photo),
            title: Text(
              hasName ? user.name! : strings.setName,
              style: hasName
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleSmall
                      ?.copyWith(color: theme.colorScheme.primary),
            ),
            subtitle: Text(user.email ?? ''),
            trailing: const Icon(Icons.edit_outlined),
            onTap: busy ? null : onEditName,
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('UserPage_backup_button'),
            leading: isBackingUp
                ? const _TileSpinner()
                : const Icon(Icons.cloud_upload_outlined),
            title: Text(strings.backup),
            onTap: busy ? null : onBackup,
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('UserPage_restore_button'),
            leading: isRestoring
                ? const _TileSpinner()
                : const Icon(Icons.cloud_download_outlined),
            title: Text(strings.restore),
            onTap: busy ? null : onRestore,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: Text(strings.resetPassword),
            onTap: busy ? null : onResetPassword,
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('UserPage_logout_button'),
            leading: const Icon(Icons.exit_to_app),
            title: Text(strings.logOut),
            onTap: busy ? null : onLogOut,
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('UserPage_delete_account_button'),
            leading: isDeleting
                ? const _TileSpinner()
                : Icon(Icons.person_remove_outlined,
                    color: theme.colorScheme.error),
            title: Text(
              strings.deleteAccount,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            onTap: busy ? null : onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _TileSpinner extends StatelessWidget {
  const _TileSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}
