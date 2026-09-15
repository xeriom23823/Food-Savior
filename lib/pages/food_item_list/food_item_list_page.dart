import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/cubits/storage_location_cubit.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/pages/import/import_route.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';
import 'package:food_savior/models/food_list_grouping.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/food_item_list/expired_processing_view.dart';
import 'package:food_savior/pages/food_item_list/food_item_detail_sheet.dart';
import 'package:food_savior/pages/food_item_list/food_item_form_page.dart';
import 'package:food_savior/pages/food_item_list/use_sheet.dart';
import 'package:food_savior/pages/food_item_list/waste_sheet.dart';
import 'package:food_savior/pages/storage_location_page.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/theme/food_item_visuals.dart';
import 'package:food_savior/theme/food_status_colors.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/app_snack_bar.dart';
import 'package:food_savior/widgets/confirm_sheet.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:food_savior/widgets/expiry_sheet.dart';
import 'package:food_savior/widgets/food_item_group_card.dart';
import 'package:food_savior/widgets/section_header.dart';

/// 現存食物清單：分群、合併卡片、滑動操作，底部一行快速新增。
class FoodItemListPage extends StatefulWidget {
  const FoodItemListPage({super.key});

  @override
  State<FoodItemListPage> createState() => _FoodItemListPageState();
}

class _FoodItemListPageState extends State<FoodItemListPage> {
  final _quickAddController = TextEditingController();
  final _quickAddFocus = FocusNode();

  @override
  void dispose() {
    _quickAddController.dispose();
    _quickAddFocus.dispose();
    super.dispose();
  }

  DateTime get _now => DateTime.now();

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocConsumer<FoodItemListBloc, FoodItemListState>(
      listenWhen: (previous, current) =>
          current is FoodItemListLoaded && current.feedback != null,
      listener: (context, state) {
        final feedback = (state as FoodItemListLoaded).feedback!;
        final hasRescueFeedback = feedback.records.any(
          (record) => !record.isWaste && record.affectFoodPoint >= 3,
        );
        final hasDailyCapFeedback = feedback.records.any(
          (record) => !record.isWaste && record.affectFoodPoint == 0,
        );
        // 紀錄頁是另一個 Bloc，寫入後要它重讀當天資料。
        if (feedback.records.isNotEmpty) {
          context
              .read<UsedFoodItemListBloc>()
              .add(const UsedFoodItemListRefresh());
        }
        AppSnackBar.show(
          context,
          message: hasDailyCapFeedback && !hasRescueFeedback
              ? strings.dailyFoodPointsCapReached
              : _feedbackMessage(context, feedback),
          kind: feedback.kind == FoodItemFeedbackKind.wasted
              ? AppSnackBarKind.warning
              : AppSnackBarKind.success,
          lottieAsset: hasRescueFeedback || hasDailyCapFeedback
              ? null
              : switch (feedback.kind) {
                  FoodItemFeedbackKind.consumed ||
                  FoodItemFeedbackKind.mixed =>
                    AppAssets.feedbackEating,
                  FoodItemFeedbackKind.wasted => AppAssets.feedbackDumping,
                  _ => null,
                },
          illustrationAsset: hasRescueFeedback
              ? AppAssets.feedbackRescue
              : hasDailyCapFeedback
                  ? AppAssets.feedbackDailyCap
                  : null,
        );
      },
      builder: (context, state) {
        if (state is FoodItemListNeedProcessing) {
          return ExpiredProcessingView(state: state);
        }
        if (state is FoodItemListError) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.foodItemListViewTitle)),
            body: EmptyState(
              icon: Icons.cloud_off,
              title: strings.foodItemListError,
              action: FilledButton(
                onPressed: () => context
                    .read<FoodItemListBloc>()
                    .add(const FoodItemListStarted()),
                child: Text(strings.refresh),
              ),
            ),
          );
        }
        if (state is! FoodItemListLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.foodItemListViewTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.foodItemListViewTitle),
            actions: [
              PopupMenuButton<FoodListGrouping>(
                icon: const Icon(Icons.segment),
                tooltip: strings.grouping,
                initialValue: state.grouping,
                onSelected: (grouping) => context
                    .read<FoodItemListBloc>()
                    .add(FoodItemListGroupingChanged(grouping: grouping)),
                itemBuilder: (context) => FoodListGrouping.values
                    .map((grouping) => PopupMenuItem(
                          value: grouping,
                          child: Text(grouping.localizedName(context)),
                        ))
                    .toList(),
              ),
              if (ImportRoute.isSupportedOn(context))
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: strings.einvoiceScanEntry,
                  onPressed: () => _scanInvoice(state),
                ),
              IconButton(
                icon: const Icon(Icons.shelves),
                tooltip: strings.storageLocations,
                onPressed: _openLocations,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: state.foodItems.isEmpty
                      ? EmptyState(
                          icon: Icons.kitchen_outlined,
                          illustrationAsset: AppAssets.emptyFoodInventory,
                          title: strings.emptyFoodListTitle,
                          description: strings.emptyFoodListDescription,
                          action: FilledButton.icon(
                            onPressed: () => _openForm(state.locations),
                            icon: const Icon(Icons.add),
                            label: Text(strings.addFoodItem),
                          ),
                        )
                      : _buildSections(context, state),
                ),
                _QuickAddBar(
                  controller: _quickAddController,
                  focusNode: _quickAddFocus,
                  onSubmit: _quickAdd,
                  onOpenForm: () => _openForm(state.locations),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSections(BuildContext context, FoodItemListLoaded state) {
    final children = <Widget>[];

    for (final section in state.sections) {
      children.add(_sectionHeader(context, section, state));
      for (final group in section.groups) {
        children.add(_buildGroup(context, group, state));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: children,
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    FoodListSection section,
    FoodItemListLoaded state,
  ) {
    final strings = S.of(context);
    if (section.urgency != null) {
      final status = _statusForBucket(section.urgency!);
      return SectionHeader(
        title: section.urgency!.localizedName(context),
        count: strings.itemCount(section.itemCount),
        color: context.foodStatusColors.of(status),
        icon: FoodItemVisuals.statusIconOf(status),
      );
    }
    if (section.type != null) {
      return SectionHeader(
        title: section.type!.localizedName(context),
        count: strings.itemCount(section.itemCount),
        icon: FoodItemVisuals.iconOf(section.type!),
      );
    }
    final location = state.locationOf(section.locationId);
    return SectionHeader(
      title: location?.name ?? strings.noLocation,
      count: strings.itemCount(section.itemCount),
      icon: location == null
          ? Icons.help_outline
          : FoodItemVisuals.locationIconOf(location.kind),
    );
  }

  FoodItemStatus _statusForBucket(UrgencyBucket bucket) => switch (bucket) {
        UrgencyBucket.expired => FoodItemStatus.expired,
        UrgencyBucket.today => FoodItemStatus.nearExpired,
        UrgencyBucket.withinThreeDays => FoodItemStatus.nearExpired,
        UrgencyBucket.withinWeek => FoodItemStatus.fresh,
        UrgencyBucket.plenty => FoodItemStatus.fresh,
        UrgencyBucket.unknownExpiry => FoodItemStatus.unknownExpiry,
      };

  Widget _buildGroup(
    BuildContext context,
    FoodItemGroup group,
    FoodItemListLoaded state,
  ) {
    final strings = S.of(context);
    final location = state.locationOf(group.storageLocationId);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Slidable(
          key: ValueKey(group.first.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => _editItem(group.first, state.locations),
                icon: Icons.edit_outlined,
                label: strings.edit,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.65,
            children: [
              SlidableAction(
                onPressed: (_) => _waste(group),
                icon: Icons.delete_outline,
                label: strings.waste,
                backgroundColor: context.foodStatusColors.wastedContainer,
                foregroundColor: context.foodStatusColors.wasted,
              ),
              SlidableAction(
                onPressed: (_) => _partialUse(group),
                icon: Icons.pie_chart_outline,
                label: strings.batchUse,
                backgroundColor: context.foodStatusColors.nearExpiredContainer,
                foregroundColor: context.foodStatusColors.nearExpired,
              ),
              SlidableAction(
                onPressed: (_) => _useAll(group),
                icon: Icons.restaurant,
                label: strings.useAll,
                backgroundColor: context.foodStatusColors.freshContainer,
                foregroundColor: context.foodStatusColors.fresh,
              ),
            ],
          ),
          child: FoodItemGroupCard(
            group: group,
            now: _now,
            locationName: location?.name,
            onTapItem: (item) => _showDetail(item, state),
            onFillExpiry: _fillExpiry,
          ),
        ),
      ),
    );
  }

  String _feedbackMessage(BuildContext context, FoodItemFeedback feedback) {
    final strings = S.of(context);
    final name = feedback.itemName ?? '';
    return switch (feedback.kind) {
      FoodItemFeedbackKind.added => '$name ${strings.added}',
      FoodItemFeedbackKind.updated => '$name ${strings.updated}',
      FoodItemFeedbackKind.removed => '$name ${strings.deleted}',
      FoodItemFeedbackKind.consumed =>
        '$name ${strings.consumed} · ${strings.pointsLabel(_points(feedback))}',
      FoodItemFeedbackKind.wasted =>
        '$name ${strings.wasted} · ${strings.pointsLabel(_points(feedback))}',
      FoodItemFeedbackKind.mixed =>
        '$name · ${strings.pointsLabel(_points(feedback))}',
    };
  }

  int _points(FoodItemFeedback feedback) => feedback.records
      .fold<int>(0, (sum, record) => sum + record.affectFoodPoint);

  void _quickAdd() {
    final name = _quickAddController.text.trim();
    if (name.isEmpty) return;
    context.read<FoodItemListBloc>().add(FoodItemListQuickAdd(name: name));
    _quickAddController.clear();
    // 鍵盤不收起，才能連續記下剛買回來的一整袋。
    _quickAddFocus.requestFocus();
  }

  Future<void> _openForm(List<StorageLocation> locations) async {
    final bloc = context.read<FoodItemListBloc>();
    final item = await Navigator.of(context).push<FoodItem>(
      MaterialPageRoute(
        builder: (_) => FoodItemFormPage(locations: locations, now: _now),
      ),
    );
    if (item != null) bloc.add(FoodItemListAdd(foodItem: item));
  }

  Future<void> _editItem(
    FoodItem original,
    List<StorageLocation> locations,
  ) async {
    final bloc = context.read<FoodItemListBloc>();
    final item = await Navigator.of(context).push<FoodItem>(
      MaterialPageRoute(
        builder: (_) => FoodItemFormPage(
          original: original,
          locations: locations,
          now: _now,
        ),
      ),
    );
    if (item != null) bloc.add(FoodItemListUpdate(foodItem: item));
  }

  Future<void> _showDetail(FoodItem item, FoodItemListLoaded state) async {
    final bloc = context.read<FoodItemListBloc>();
    final strings = S.of(context);
    final action = await FoodItemDetailSheet.show(
      context,
      item: item,
      now: _now,
      location: state.locationOf(item.storageLocationId),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case FoodItemDetailAction.edit:
        await _editItem(item, state.locations);
      case FoodItemDetailAction.markOpened:
        bloc.add(FoodItemListMarkOpened(id: item.id));
      case FoodItemDetailAction.fillExpiry:
        await _fillExpiry(item);
      case FoodItemDetailAction.delete:
        final confirmed = await ConfirmSheet.show(
          context,
          title: strings.delete,
          message: item.name,
          confirmLabel: strings.delete,
        );
        if (confirmed) bloc.add(FoodItemListRemove(id: item.id));
    }
  }

  Future<void> _fillExpiry(FoodItem item) async {
    final bloc = context.read<FoodItemListBloc>();
    final expiry = await ExpirySheet.show(
      context,
      initial: ExpiryValue.of(item),
      now: _now,
    );
    if (expiry != null) {
      bloc.add(FoodItemListFillExpiry(id: item.id, expiry: expiry));
    }
  }

  void _useAll(FoodItemGroup group) {
    context.read<FoodItemListBloc>().add(FoodItemListUseAll(
          items: group.items,
          disposalMethod: DisposalMethod.eaten,
        ));
  }

  Future<void> _waste(FoodItemGroup group) async {
    final bloc = context.read<FoodItemListBloc>();
    final choice = await WasteSheet.show(context);
    if (choice == null) return;
    bloc.add(FoodItemListUseAll(
      items: group.items,
      disposalMethod: choice.disposalMethod,
      wasteReason: choice.wasteReason,
    ));
  }

  Future<void> _partialUse(FoodItemGroup group) async {
    final bloc = context.read<FoodItemListBloc>();
    final result = await UseSheet.show(
      context,
      available: group.totalAmount,
      unit: group.unit,
      byFraction: group.first.amount == null,
      now: _now,
    );
    if (result == null) return;
    bloc.add(FoodItemListPartialUse(
      items: group.items,
      consumedAmount: result.consumedAmount,
      wastedAmount: result.wastedAmount,
      usedDate: result.usedDate,
      wasteReason: result.wasteReason,
      remainingAfter: result.remainingAfter,
    ));
  }

  /// 掃描發票匯入。預設把匯入的東西放進第一個冷藏位置——大部分生鮮都進冰箱，
  /// 猜錯了使用者在草稿頁改一下就好，總比每一列都要自己選位置好。
  Future<void> _scanInvoice(FoodItemListLoaded state) async {
    final defaultLocation = state.locations
        .where((location) => location.kind == LocationKind.refrigerated)
        .firstOrNull;

    final imported = await ImportRoute.open(
      context,
      locationKind: defaultLocation?.kind,
      defaultLocationId: defaultLocation?.id,
      locations: state.locations,
    );
    if (!mounted || imported == null || imported == 0) return;
    AppSnackBar.show(
      context,
      message: S.of(context).einvoiceImported(imported),
    );
  }

  Future<void> _openLocations() async {
    final bloc = context.read<FoodItemListBloc>();
    // 推出去的路由是 Navigator 的子樹，不是這個頁面的子樹，
    // 所以要把 Cubit 一起帶過去，否則 StorageLocationPage 找不到 Provider。
    final locationCubit = context.read<StorageLocationCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: locationCubit,
          child: const StorageLocationPage(),
        ),
      ),
    );
    bloc.add(const FoodItemListLocationsChanged());
  }
}

/// 一行快速新增：只打名稱就能存（food-inventory 規格）。
class _QuickAddBar extends StatelessWidget {
  const _QuickAddBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onOpenForm,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onOpenForm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: S.of(context).quickAddHint,
                isDense: true,
                prefixIcon: const Icon(Icons.add),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton.filledTonal(
            onPressed: onOpenForm,
            tooltip: S.of(context).addFoodItem,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}
