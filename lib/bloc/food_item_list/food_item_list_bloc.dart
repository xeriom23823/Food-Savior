import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_group.dart';
import 'package:food_savior/models/food_list_grouping.dart';
import 'package:food_savior/models/food_point_calculator.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/food_preset_repository.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:food_savior/repositories/storage_location_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:uuid/uuid.dart';

part 'food_item_list_event.dart';
part 'food_item_list_state.dart';

/// 現存食物清單。分群、合併、FEFO 扣減、點數計算全部在這裡，
/// 頁面只負責顯示與派發事件（design D8）。
class FoodItemListBloc extends Bloc<FoodItemListEvent, FoodItemListState> {
  FoodItemListBloc({
    required this.foodItemRepository,
    required this.usedFoodItemRepository,
    required this.storageLocationRepository,
    required this.preferencesRepository,
    this.presetRepository,
    DateTime Function()? now,
    Uuid? uuid,
    FoodPointCalculator pointCalculator = const FoodPointCalculator(),
  })  : _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid(),
        _pointCalculator = pointCalculator,
        super(const FoodItemListInitial()) {
    on<FoodItemListStarted>(_onStarted);
    on<FoodItemListQuickAdd>(_onQuickAdd);
    on<FoodItemListAdd>(_onAdd);
    on<FoodItemListUpdate>(_onUpdate);
    on<FoodItemListRemove>(_onRemove);
    on<FoodItemListFillExpiry>(_onFillExpiry);
    on<FoodItemListMarkOpened>(_onMarkOpened);
    on<FoodItemListUseAll>(_onUseAll);
    on<FoodItemListPartialUse>(_onPartialUse);
    on<FoodItemListGroupingChanged>(_onGroupingChanged);
    on<FoodItemListLocationsChanged>(_onLocationsChanged);
    on<FoodItemListLoad>(_onLoad);
    on<FoodItemListClear>(_onClear);
    on<FoodItemListProcessingUpdate>(_onProcessingUpdate);
    on<FoodItemListProcessComplete>(_onProcessComplete);
  }

  final FoodItemRepository foodItemRepository;
  final UsedFoodItemRepository usedFoodItemRepository;
  final StorageLocationRepository storageLocationRepository;
  final PreferencesRepository preferencesRepository;
  final FoodPresetRepository? presetRepository;

  final DateTime Function() _now;
  final Uuid _uuid;
  final FoodPointCalculator _pointCalculator;

  int _revision = 0;

  /// 建議來源。模板每次重新從歷史推導，所以使用者剛記過的東西馬上生效。
  FoodSuggestionEngine get suggestionEngine => FoodSuggestionEngine(
        templates: FoodSuggestionEngine.templatesFromHistory(
          foodItems: foodItemRepository.getAllFoodItems(),
          usedFoodItems: usedFoodItemRepository.getAllUsedFoodItems(),
        ),
        presets: presetRepository?.presets ?? const [],
      );

  Future<void> _onStarted(
    FoodItemListStarted event,
    Emitter<FoodItemListState> emit,
  ) async {
    emit(const FoodItemListLoading());
    try {
      final now = _now();
      await foodItemRepository.updateAllFoodItemsStatus(now);

      final expired = foodItemRepository.getExpiredFoodItems();
      if (expired.isNotEmpty) {
        emit(FoodItemListNeedProcessing(
          remainFoodItems: foodItemRepository.getNonExpiredFoodItems(),
          expiredFoodItems: FoodItemGroup.sortByExpiry(expired),
          isConsumed: List<bool>.filled(expired.length, false),
        ));
        return;
      }

      emit(_loaded());
    } catch (error) {
      emit(FoodItemListError(message: error.toString()));
    }
  }

  Future<void> _onQuickAdd(
    FoodItemListQuickAdd event,
    Emitter<FoodItemListState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;

    final now = _now();
    final locations = storageLocationRepository.getAll();
    final defaultLocation = locations.isEmpty ? null : locations.first;
    final suggestion = suggestionEngine.suggest(
      name: name,
      now: now,
      locationKind: defaultLocation?.kind,
      defaultLocationId: defaultLocation?.id,
    );

    final item = FoodItem(
      id: _uuid.v4(),
      name: name,
      type: suggestion.type,
      status: FoodItemStatus.unknownExpiry,
      storageDate: now,
      amount: suggestion.amount,
      unit: suggestion.unit,
      expiryEarliest: suggestion.expiry.earliest,
      expiryLatest: suggestion.expiry.latest,
      expiryPrecision: suggestion.expiry.precision,
      shelfLifeAfterOpenDays: suggestion.shelfLifeAfterOpenDays,
      storageLocationId: suggestion.storageLocationId,
    ).withDerivedStatus(now);

    await foodItemRepository.saveFoodItem(item);
    emit(_loaded(
      feedback: _feedback(FoodItemFeedbackKind.added, itemName: item.name),
    ));
  }

  Future<void> _onAdd(
    FoodItemListAdd event,
    Emitter<FoodItemListState> emit,
  ) async {
    final item = event.foodItem.withDerivedStatus(_now());
    await foodItemRepository.saveFoodItem(item);
    emit(_loaded(
      feedback: _feedback(FoodItemFeedbackKind.added, itemName: item.name),
    ));
  }

  Future<void> _onUpdate(
    FoodItemListUpdate event,
    Emitter<FoodItemListState> emit,
  ) async {
    final item = event.foodItem.withDerivedStatus(_now());
    await foodItemRepository.saveFoodItem(item);
    emit(_loaded(
      feedback: _feedback(FoodItemFeedbackKind.updated, itemName: item.name),
    ));
  }

  Future<void> _onRemove(
    FoodItemListRemove event,
    Emitter<FoodItemListState> emit,
  ) async {
    final item = foodItemRepository.getFoodItem(event.id);
    await foodItemRepository.deleteFoodItem(event.id);
    emit(_loaded(
      feedback: _feedback(FoodItemFeedbackKind.removed, itemName: item?.name),
    ));
  }

  Future<void> _onFillExpiry(
    FoodItemListFillExpiry event,
    Emitter<FoodItemListState> emit,
  ) async {
    final item = foodItemRepository.getFoodItem(event.id);
    if (item == null) return;

    final updated = item
        .copyWith(
          clearExpiry: true,
          expiryEarliest: event.expiry.earliest,
          expiryLatest: event.expiry.latest,
          expiryPrecision: event.expiry.precision,
        )
        .withDerivedStatus(_now());
    await foodItemRepository.saveFoodItem(updated);
    emit(_loaded(
      feedback: _feedback(FoodItemFeedbackKind.updated, itemName: updated.name),
    ));
  }

  Future<void> _onMarkOpened(
    FoodItemListMarkOpened event,
    Emitter<FoodItemListState> emit,
  ) async {
    final item = foodItemRepository.getFoodItem(event.id);
    if (item == null) return;

    final now = _now();
    final updated = item
        .copyWith(
          openedDate: now,
          shelfLifeAfterOpenDays:
              event.shelfLifeAfterOpenDays ?? item.shelfLifeAfterOpenDays,
        )
        .withDerivedStatus(now);
    await foodItemRepository.saveFoodItem(updated);
    emit(_loaded(
      feedback: _feedback(FoodItemFeedbackKind.updated, itemName: updated.name),
    ));
  }

  Future<void> _onUseAll(
    FoodItemListUseAll event,
    Emitter<FoodItemListState> emit,
  ) async {
    if (event.items.isEmpty) return;
    final now = _now();
    final records = <UsedFoodItem>[];

    for (final item in FoodItemGroup.sortByExpiry(event.items)) {
      final method = _resolveMethod(event.disposalMethod, item, now);
      records.add(await _record(
        item: item,
        disposalMethod: method,
        usedDate: now,
        usedAmount: item.amount,
        usedFraction: item.remainingFraction,
        wasteReason: event.wasteReason,
        price: item.priceTotal,
      ));
      await foodItemRepository.deleteFoodItem(item.id);
    }

    emit(_loaded(feedback: _feedbackFor(records)));
  }

  Future<void> _onPartialUse(
    FoodItemListPartialUse event,
    Emitter<FoodItemListState> emit,
  ) async {
    if (event.items.isEmpty) return;
    final batches = FoodItemGroup.sortByExpiry(event.items);
    final records = <UsedFoodItem>[];

    // 以剩餘比例記錄的項目沒有數字可以扣，改用「用掉後還剩多少」。
    if (batches.first.amount == null) {
      final item = batches.first;
      final method = event.wastedAmount > 0
          ? DisposalMethod.discarded
          : _resolveMethod(DisposalMethod.eaten, item, event.usedDate);
      records.add(await _record(
        item: item,
        disposalMethod: method,
        usedDate: event.usedDate,
        usedFraction: item.remainingFraction,
        wasteReason: event.wasteReason,
        price: item.priceTotal,
      ));
      if (event.remainingAfter == null) {
        await foodItemRepository.deleteFoodItem(item.id);
      } else {
        await foodItemRepository.saveFoodItem(
          item.copyWith(remainingFraction: event.remainingAfter),
        );
      }
      emit(_loaded(feedback: _feedbackFor(records)));
      return;
    }

    // FEFO：從最早到期的批次開始扣，食用先於丟棄。
    var consumedLeft = event.consumedAmount;
    var wastedLeft = event.wastedAmount;

    for (final item in batches) {
      if (consumedLeft <= 0 && wastedLeft <= 0) break;
      var available = item.amount ?? 0;
      if (available <= 0) continue;

      final consumedHere = consumedLeft <= 0
          ? 0.0
          : (consumedLeft < available ? consumedLeft : available);
      available -= consumedHere;
      consumedLeft -= consumedHere;

      final wastedHere = wastedLeft <= 0 || available <= 0
          ? 0.0
          : (wastedLeft < available ? wastedLeft : available);
      available -= wastedHere;
      wastedLeft -= wastedHere;

      if (consumedHere > 0) {
        records.add(await _record(
          item: item,
          disposalMethod:
              _resolveMethod(DisposalMethod.eaten, item, event.usedDate),
          usedDate: event.usedDate,
          usedAmount: consumedHere,
          price: item.priceForPortion(consumedHere),
        ));
      }
      if (wastedHere > 0) {
        records.add(await _record(
          item: item,
          disposalMethod: DisposalMethod.discarded,
          usedDate: event.usedDate,
          usedAmount: wastedHere,
          wasteReason: event.wasteReason,
          price: item.priceForPortion(wastedHere),
        ));
      }

      if (available <= 0) {
        await foodItemRepository.deleteFoodItem(item.id);
      } else {
        await foodItemRepository.saveFoodItem(item.copyWith(
          amount: available,
          priceTotal: item.priceForPortion(available),
        ));
      }
    }

    emit(_loaded(feedback: _feedbackFor(records)));
  }

  Future<void> _onGroupingChanged(
    FoodItemListGroupingChanged event,
    Emitter<FoodItemListState> emit,
  ) async {
    await preferencesRepository.setGrouping(event.grouping);
    emit(_loaded());
  }

  Future<void> _onLocationsChanged(
    FoodItemListLocationsChanged event,
    Emitter<FoodItemListState> emit,
  ) async {
    emit(_loaded());
  }

  Future<void> _onLoad(
    FoodItemListLoad event,
    Emitter<FoodItemListState> emit,
  ) async {
    emit(const FoodItemListLoading());
    final now = _now();

    // 還原：整批取代本機，先清空再寫入，避免兩個事件競態。
    await foodItemRepository.clearAll();
    await foodItemRepository.saveFoodItems(
      event.foodItems.map((item) => item.withDerivedStatus(now)).toList(),
    );

    final expired = foodItemRepository.getExpiredFoodItems();
    if (expired.isNotEmpty) {
      emit(FoodItemListNeedProcessing(
        remainFoodItems: foodItemRepository.getNonExpiredFoodItems(),
        expiredFoodItems: FoodItemGroup.sortByExpiry(expired),
        isConsumed: List<bool>.filled(expired.length, false),
      ));
      return;
    }
    emit(_loaded());
  }

  Future<void> _onClear(
    FoodItemListClear event,
    Emitter<FoodItemListState> emit,
  ) async {
    emit(const FoodItemListLoading());
    await foodItemRepository.clearAll();
    emit(_loaded());
  }

  Future<void> _onProcessingUpdate(
    FoodItemListProcessingUpdate event,
    Emitter<FoodItemListState> emit,
  ) async {
    final current = state;
    if (current is! FoodItemListNeedProcessing) return;

    final isConsumed = List<bool>.of(current.isConsumed);
    isConsumed[event.updateIndex] = !isConsumed[event.updateIndex];
    emit(FoodItemListNeedProcessing(
      remainFoodItems: current.remainFoodItems,
      expiredFoodItems: current.expiredFoodItems,
      isConsumed: isConsumed,
    ));
  }

  Future<void> _onProcessComplete(
    FoodItemListProcessComplete event,
    Emitter<FoodItemListState> emit,
  ) async {
    final current = state;
    if (current is! FoodItemListNeedProcessing) return;

    emit(const FoodItemListLoading());
    final now = _now();
    final records = <UsedFoodItem>[];

    for (var index = 0; index < current.expiredFoodItems.length; index++) {
      final item = current.expiredFoodItems[index];
      final consumed = current.isConsumed[index];
      records.add(await _record(
        item: item,
        disposalMethod:
            consumed ? DisposalMethod.eatenAtRisk : DisposalMethod.discarded,
        usedDate: now,
        usedAmount: item.amount,
        usedFraction: item.remainingFraction,
        wasteReason: consumed ? null : event.wasteReason,
        price: item.priceTotal,
      ));
      // 已處理的項目必須離開本機儲存，否則下次啟動會再問一次。
      await foodItemRepository.deleteFoodItem(item.id);
    }

    emit(_loaded(feedback: _feedbackFor(records)));
  }

  /// 過期後才吃掉要記成 `eatenAtRisk`，點數才反映得出「來不及了」。
  DisposalMethod _resolveMethod(
    DisposalMethod requested,
    FoodItem item,
    DateTime usedDate,
  ) {
    if (requested != DisposalMethod.eaten) return requested;
    final expiry = item.effectiveExpiry;
    if (expiry != null && isExpiredOn(expiry, usedDate)) {
      return DisposalMethod.eatenAtRisk;
    }
    return requested;
  }

  /// 建立一筆使用紀錄並套用點數規則。逐筆寫入，前一筆計入後一筆的當日總和。
  Future<UsedFoodItem> _record({
    required FoodItem item,
    required DisposalMethod disposalMethod,
    required DateTime usedDate,
    double? usedAmount,
    RemainingFraction? usedFraction,
    WasteReason? wasteReason,
    int? price,
  }) async {
    final draft = item.toUsedFoodItem(
      id: _uuid.v4(),
      disposalMethod: disposalMethod,
      usedDate: usedDate,
      usedAmount: usedAmount,
      usedFraction: usedFraction,
      wasteReason: wasteReason,
      priceTotal: price,
    );
    final scored = draft.copyWith(
      affectFoodPoint: _pointCalculator.pointFor(
        draft,
        usedFoodItemRepository.getAllUsedFoodItems(),
      ),
    );
    await usedFoodItemRepository.saveUsedFoodItem(scored);
    return scored;
  }

  FoodItemFeedback _feedback(
    FoodItemFeedbackKind kind, {
    String? itemName,
    List<UsedFoodItem> records = const [],
  }) {
    _revision++;
    return FoodItemFeedback(
      kind: kind,
      revision: _revision,
      itemName: itemName,
      records: records,
    );
  }

  FoodItemFeedback? _feedbackFor(List<UsedFoodItem> records) {
    if (records.isEmpty) return null;
    final hasWaste = records.any((record) => record.isWaste);
    final hasConsumed = records.any((record) => !record.isWaste);
    final kind = hasWaste && hasConsumed
        ? FoodItemFeedbackKind.mixed
        : hasWaste
            ? FoodItemFeedbackKind.wasted
            : FoodItemFeedbackKind.consumed;
    return _feedback(kind, itemName: records.first.name, records: records);
  }

  FoodItemListLoaded _loaded({FoodItemFeedback? feedback}) {
    final now = _now();
    final items = foodItemRepository.getNonExpiredFoodItems();
    final locations = storageLocationRepository.getAll();
    final grouping = preferencesRepository.grouping;

    return FoodItemListLoaded(
      foodItems: items,
      grouping: grouping,
      locations: locations,
      sections: buildSections(
        items: items,
        grouping: grouping,
        now: now,
        locationOrder: locations.map((location) => location.id).toList(),
      ),
      feedback: feedback,
    );
  }
}
