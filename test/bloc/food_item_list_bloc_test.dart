import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_list_grouping.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:food_savior/repositories/storage_location_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/hive_test_helper.dart';

/// Hive 的寫入是真的磁碟 I/O，一個 microtask 等不到；blocTest 要多等一下。
const Duration _hiveWrite = Duration(milliseconds: 300);

void main() {
  final env = HiveTestEnv();
  late Box<FoodItem> foodBox;
  late Box<UsedFoodItem> usedBox;
  late Box<StorageLocation> locationBox;
  late FoodItemRepository foodRepo;
  late UsedFoodItemRepository usedRepo;
  late StorageLocationRepository locationRepo;
  late PreferencesRepository preferencesRepo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    foodBox = await env.openBox<FoodItem>('foodItems');
    usedBox = await env.openBox<UsedFoodItem>('usedFoodItems');
    locationBox = await env.openBox<StorageLocation>('storageLocations');
    foodRepo = FoodItemRepository(foodItemBox: foodBox);
    usedRepo = UsedFoodItemRepository(usedFoodItemBox: usedBox);
    locationRepo = StorageLocationRepository(storageLocationBox: locationBox);
    preferencesRepo = PreferencesRepository(
      preferences: await SharedPreferences.getInstance(),
    );
  });

  tearDown(() async {
    await foodBox.deleteFromDisk();
    await usedBox.deleteFromDisk();
    await locationBox.deleteFromDisk();
  });

  FoodItemListBloc build() => FoodItemListBloc(
        foodItemRepository: foodRepo,
        usedFoodItemRepository: usedRepo,
        storageLocationRepository: locationRepo,
        preferencesRepository: preferencesRepo,
        now: () => testNow,
      );

  FoodItemListLoaded loadedOf(FoodItemListState state) =>
      state as FoodItemListLoaded;

  group('載入', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '沒有過期項目時載入清單並依期限排序',
      setUp: () async {
        await foodRepo.saveFoodItems([
          makeFood(id: 'later', daysToExpire: 9),
          makeFood(id: 'soon', daysToExpire: 1),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListStarted()),
      expect: () => [isA<FoodItemListLoading>(), isA<FoodItemListLoaded>()],
      verify: (bloc) {
        expect(ids(loadedOf(bloc.state).foodItems), ['soon', 'later']);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '有過期項目時進入過期處理流程',
      setUp: () async {
        await foodRepo.saveFoodItems([
          makeFood(id: 'expired', daysToExpire: -2),
          makeFood(id: 'fresh', daysToExpire: 9),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListStarted()),
      expect: () => [
        isA<FoodItemListLoading>(),
        isA<FoodItemListNeedProcessing>(),
      ],
      verify: (bloc) {
        final state = bloc.state as FoodItemListNeedProcessing;
        expect(ids(state.expiredFoodItems), ['expired']);
        expect(ids(state.remainFoodItems), ['fresh']);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '期限未知的項目不會被當成過期',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'x', daysToExpire: null));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListStarted()),
      verify: (bloc) {
        final state = loadedOf(bloc.state);
        expect(state.foodItems.single.status, FoodItemStatus.unknownExpiry);
      },
    );
  });

  group('快速新增', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '只有名稱也能建立，沒有依據時標為期限未知',
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListQuickAdd(name: '阿嬤給的東西')),
      verify: (bloc) {
        final item = loadedOf(bloc.state).foodItems.single;
        expect(item.name, '阿嬤給的東西');
        expect(item.needsExpiryCompletion, isTrue);
        expect(item.status, FoodItemStatus.unknownExpiry);
        expect(foodRepo.getAllFoodItems(), hasLength(1));
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '命中使用者歷史時帶入類型與期限',
      setUp: () async {
        await usedRepo.saveUsedFoodItem(makeUsed(
          id: 'old',
          name: '牛奶',
          type: FoodItemType.eggAndMilk,
        ));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListQuickAdd(name: '牛奶')),
      verify: (bloc) {
        final item = loadedOf(bloc.state).foodItems.single;
        expect(item.type, FoodItemType.eggAndMilk);
        expect(item.needsExpiryCompletion, isFalse);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '空白名稱不建立任何東西',
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListQuickAdd(name: '   ')),
      expect: () => const <FoodItemListState>[],
    );
  });

  group('新增、更新、刪除', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '新增後狀態依期限推導',
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListAdd(
        foodItem: makeFood(id: 'x', daysToExpire: 2),
      )),
      verify: (bloc) {
        expect(loadedOf(bloc.state).foodItems.single.status,
            FoodItemStatus.nearExpired);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '更新以 id 比對，不需要傳入清單中的同一個實例',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'x', name: '舊名字'));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListUpdate(
        foodItem: makeFood(id: 'x', name: '新名字', daysToExpire: 2),
      )),
      verify: (bloc) {
        final item = loadedOf(bloc.state).foodItems.single;
        expect(item.id, 'x');
        expect(item.name, '新名字');
        expect(item.status, FoodItemStatus.nearExpired);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '刪除後本機儲存也不再有該 id',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'x'));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListRemove(id: 'x')),
      verify: (bloc) {
        expect(loadedOf(bloc.state).foodItems, isEmpty);
        expect(foodRepo.getFoodItem('x'), isNull);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '補期限後保留原 id 與其他欄位並重新推導狀態',
      setUp: () async {
        await foodRepo.saveFoodItem(
            makeFood(id: 'x', name: '牛奶', amount: 2, daysToExpire: null));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListFillExpiry(
        id: 'x',
        expiry: ExpiryValue.exact(daysFromNow(5)),
      )),
      verify: (bloc) {
        final item = loadedOf(bloc.state).foodItems.single;
        expect(item.id, 'x');
        expect(item.name, '牛奶');
        expect(item.amount, 2);
        expect(item.status, FoodItemStatus.fresh);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '標記開封會縮短有效期限',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(
          id: 'milk',
          daysToExpire: 10,
          shelfLifeAfterOpenDays: 2,
        ));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListMarkOpened(id: 'milk')),
      verify: (bloc) {
        final item = loadedOf(bloc.state).foodItems.single;
        expect(item.openedDate, testNow);
        expect(item.effectiveExpiry, daysFromNow(2));
        expect(item.status, FoodItemStatus.nearExpired);
      },
    );
  });

  group('食用與丟棄', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '全部使用：從清單移除並寫入一筆食用紀錄',
      setUp: () async {
        await foodRepo.saveFoodItem(
            makeFood(id: 'egg', name: '雞蛋', amount: 3, daysToExpire: 10));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListUseAll(
        items: [foodRepo.getFoodItem('egg')!],
        disposalMethod: DisposalMethod.eaten,
      )),
      verify: (bloc) {
        expect(loadedOf(bloc.state).foodItems, isEmpty);
        final record = usedRepo.getAllUsedFoodItems().single;
        expect(record.name, '雞蛋');
        expect(record.amount, 3);
        expect(record.status, FoodItemStatus.consumed);
        expect(record.affectFoodPoint, 2);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '過期後才吃掉記成 eatenAtRisk 並得 +1',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'old', daysToExpire: -1));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListUseAll(
        items: [foodRepo.getFoodItem('old')!],
        disposalMethod: DisposalMethod.eaten,
      )),
      verify: (bloc) {
        final record = usedRepo.getAllUsedFoodItems().single;
        expect(record.disposalMethod, DisposalMethod.eatenAtRisk);
        expect(record.affectFoodPoint, 1);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '還沒過期就丟掉是 -3，且記下原因',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'x', daysToExpire: 5));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListUseAll(
        items: [foodRepo.getFoodItem('x')!],
        disposalMethod: DisposalMethod.discarded,
        wasteReason: WasteReason.forgotten,
      )),
      verify: (bloc) {
        final record = usedRepo.getAllUsedFoodItems().single;
        expect(record.isWaste, isTrue);
        expect(record.wasteReason, WasteReason.forgotten);
        expect(record.affectFoodPoint, -3);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '送人不算浪費',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'x', daysToExpire: 5));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListUseAll(
        items: [foodRepo.getFoodItem('x')!],
        disposalMethod: DisposalMethod.givenAway,
      )),
      verify: (bloc) {
        final record = usedRepo.getAllUsedFoodItems().single;
        expect(record.isWaste, isFalse);
        expect(record.affectFoodPoint, 2);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '合併卡片全部使用：每個批次各自一筆紀錄、各自算點數',
      setUp: () async {
        await foodRepo.saveFoodItems([
          makeFood(id: 'a', name: '雞蛋', amount: 10, daysToExpire: 1),
          makeFood(id: 'b', name: '雞蛋', amount: 8, daysToExpire: 10),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListUseAll(
        items: foodRepo.getAllFoodItems(),
        disposalMethod: DisposalMethod.eaten,
      )),
      verify: (bloc) {
        final records = usedRepo.getAllUsedFoodItems();
        expect(records, hasLength(2));
        expect(records.map((record) => record.affectFoodPoint).toSet(), {3, 2});
        expect(foodRepo.getAllFoodItems(), isEmpty);
      },
    );
  });

  group('部分處理', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '同時食用與丟棄會產生兩筆紀錄',
      setUp: () async {
        await foodRepo.saveFoodItem(
            makeFood(id: 'apple', name: '蘋果', amount: 5, daysToExpire: 10));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListPartialUse(
        items: [foodRepo.getFoodItem('apple')!],
        consumedAmount: 3,
        wastedAmount: 2,
        usedDate: testNow,
      )),
      verify: (bloc) {
        final records = usedRepo.getAllUsedFoodItems();
        expect(records, hasLength(2));
        expect(
          records.firstWhere((record) => !record.isWaste).amount,
          3,
        );
        expect(records.firstWhere((record) => record.isWaste).amount, 2);
        expect(foodRepo.getAllFoodItems(), isEmpty);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '只用掉一部分時項目留在清單且份量減少',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'apple', amount: 5));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListPartialUse(
        items: [foodRepo.getFoodItem('apple')!],
        consumedAmount: 2,
        wastedAmount: 0,
        usedDate: testNow,
      )),
      verify: (bloc) {
        expect(loadedOf(bloc.state).foodItems.single.amount, 3);
        expect(usedRepo.getAllUsedFoodItems(), hasLength(1));
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '金額依份量比例攤提',
      setUp: () async {
        await foodRepo
            .saveFoodItem(makeFood(id: 'x', amount: 10, priceTotal: 100));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListPartialUse(
        items: [foodRepo.getFoodItem('x')!],
        consumedAmount: 3,
        wastedAmount: 0,
        usedDate: testNow,
      )),
      verify: (bloc) {
        expect(usedRepo.getAllUsedFoodItems().single.priceTotal, 30);
        expect(loadedOf(bloc.state).foodItems.single.priceTotal, 70);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '跨批次依 FEFO 從最早到期的扣起',
      setUp: () async {
        await foodRepo.saveFoodItems([
          makeFood(id: 'soon', name: '雞蛋', amount: 4, daysToExpire: 1),
          makeFood(id: 'later', name: '雞蛋', amount: 6, daysToExpire: 10),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListPartialUse(
        items: foodRepo.getAllFoodItems(),
        consumedAmount: 6,
        wastedAmount: 0,
        usedDate: testNow,
      )),
      verify: (bloc) {
        expect(foodRepo.getFoodItem('soon'), isNull);
        expect(foodRepo.getFoodItem('later')!.amount, 4);

        final records = usedRepo.getAllUsedFoodItems();
        expect(records, hasLength(2));
        // 各自帶自己的期限，所以即期那批得 +3。
        expect(records.map((record) => record.affectFoodPoint).toList(),
            containsAll(<int>[3, 2]));
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '以剩餘比例記錄的項目改寫剩餘比例',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(
          id: 'sauce',
          amount: null,
          unit: null,
          remainingFraction: RemainingFraction.full,
        ));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListPartialUse(
        items: [foodRepo.getFoodItem('sauce')!],
        consumedAmount: 0,
        wastedAmount: 0,
        usedDate: testNow,
        remainingAfter: RemainingFraction.half,
      )),
      verify: (bloc) {
        expect(loadedOf(bloc.state).foodItems.single.remainingFraction,
            RemainingFraction.half);
        expect(usedRepo.getAllUsedFoodItems(), hasLength(1));
      },
    );
  });

  group('過期處理', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '勾選為已食用的得 +1，未勾選的記成丟棄 -2，且都離開清單',
      setUp: () async {
        await foodRepo.saveFoodItems([
          makeFood(id: 'a', daysToExpire: -1),
          makeFood(id: 'b', daysToExpire: -2),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) async {
        bloc.add(const FoodItemListStarted());
        await Future<void>.delayed(_hiveWrite);
        bloc.add(const FoodItemListProcessingUpdate(updateIndex: 0));
        await Future<void>.delayed(_hiveWrite);
        bloc.add(const FoodItemListProcessComplete());
      },
      verify: (bloc) {
        expect(foodRepo.getAllFoodItems(), isEmpty);
        final records = usedRepo.getAllUsedFoodItems();
        expect(records, hasLength(2));
        expect(
          records.map((record) => record.affectFoodPoint).toSet(),
          {1, -2},
        );
      },
    );
  });

  group('分群', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '切換分群方式會持久化',
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(
          const FoodItemListGroupingChanged(grouping: FoodListGrouping.type)),
      verify: (bloc) {
        expect(loadedOf(bloc.state).grouping, FoodListGrouping.type);
        expect(preferencesRepo.grouping, FoodListGrouping.type);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '狀態帶出分群區塊，空的分群不出現',
      setUp: () async {
        await foodRepo.saveFoodItems([
          makeFood(id: 'soon', daysToExpire: 1),
          makeFood(id: 'plenty', daysToExpire: 30),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const FoodItemListStarted()),
      verify: (bloc) {
        final sections = loadedOf(bloc.state).sections;
        expect(sections.map((section) => section.urgency).toList(),
            [UrgencyBucket.withinThreeDays, UrgencyBucket.plenty]);
      },
    );
  });

  group('還原', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '整批取代本機並重新推導狀態',
      setUp: () async {
        await foodRepo.saveFoodItem(makeFood(id: 'old'));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(FoodItemListLoad(foodItems: [
        makeFood(id: 'restored', daysToExpire: 2),
      ])),
      verify: (bloc) {
        expect(ids(loadedOf(bloc.state).foodItems), ['restored']);
        expect(foodRepo.getFoodItem('old'), isNull);
        expect(foodRepo.getFoodItem('restored')!.status,
            FoodItemStatus.nearExpired);
      },
    );
  });
}
