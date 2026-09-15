import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

/// Bloc 建構子會自動 add(LoadFoodItemListFromDevice)，先等它載完再操作，
/// 否則 Add / Update 等 handler 會因為 state 不是 Loaded 而被忽略。
Future<void> untilLoaded(FoodItemListBloc bloc) async {
  bool done(FoodItemListState s) =>
      s is FoodItemListLoaded || s is FoodItemListNeedProcessing;
  if (done(bloc.state)) return;
  await bloc.stream.firstWhere(done);
}

/// 派發事件後等到 Bloc 真正回到穩定狀態（Loaded / NeedProcessing），
/// 否則 bloc_test 會在 Hive 寫入完成前 close()，遺失最後的 emit。
extension on FoodItemListBloc {
  Future<void> settle(void Function() action) {
    final done = stream.firstWhere(
        (s) => s is FoodItemListLoaded || s is FoodItemListNeedProcessing);
    action();
    return done;
  }
}

void main() {
  final env = HiveTestEnv();
  late Box<FoodItem> box;
  late FoodItemRepository repo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<FoodItem>('foodItem');
    repo = FoodItemRepository(foodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  FoodItemListBloc build() => FoodItemListBloc(foodItemRepository: repo);

  group('載入（food-inventory / expired-food-processing）', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '空 Box → Loading → Loaded([])',
      build: build,
      act: untilLoaded,
      expect: () => const [
        FoodItemListLoading(),
        FoodItemListLoaded(foodItems: []),
      ],
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '到期日 2 天內的項目載入後標記為 nearExpired 並寫回 Box；清單依到期日排序',
      setUp: () async {
        // 故意先放到期較遠的，驗證載入後不是插入順序而是到期日順序
        await box.put('far', makeFood(id: 'far', daysToExpire: 10));
        await box.put('soon', makeFood(id: 'soon', daysToExpire: 2));
      },
      build: build,
      act: untilLoaded,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>()
            .having((s) => ids(s.foodItems), 'order', ['soon', 'far'])
            .having(
              (s) => s.foodItems.firstWhere((f) => f.id == 'soon').status,
              'soon.status',
              FoodItemStatus.nearExpired,
            )
            .having(
              (s) => s.foodItems.firstWhere((f) => f.id == 'far').status,
              'far.status',
              FoodItemStatus.fresh,
            ),
      ],
      verify: (_) {
        expect(box.get('soon')!.status, FoodItemStatus.nearExpired);
        expect(box.get('far')!.status, FoodItemStatus.fresh);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '有過期項目 → NeedProcessing，過期在 temp、其餘在 remain、預設皆未食用',
      setUp: () async {
        await box.put('old', makeFood(id: 'old', daysToExpire: -1));
        await box.put('ok', makeFood(id: 'ok', daysToExpire: 10));
      },
      build: build,
      act: untilLoaded,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListNeedProcessing>()
            .having((s) => ids(s.tempFoodItems), 'temp', ['old']).having(
                (s) => ids(s.remainFoodItems),
                'remain',
                ['ok']).having((s) => s.isConsumed, 'isConsumed', [false]),
      ],
      verify: (_) => expect(box.get('old')!.status, FoodItemStatus.expired),
    );
  });

  group('新增（food-inventory）', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '到期 2 天內 → nearExpired；依到期日排序；寫入 Box',
      setUp: () => box.put('far', makeFood(id: 'far', daysToExpire: 10)),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(
            FoodItemListAdd(foodItem: makeFood(id: 'soon', daysToExpire: 2))));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>()
            .having((s) => ids(s.foodItems), 'order', ['soon', 'far']).having(
                (s) => s.foodItems.first.status,
                'status',
                FoodItemStatus.nearExpired),
      ],
      verify: (_) {
        expect(box.get('soon'), isNotNull);
        expect(box.get('soon')!.status, FoodItemStatus.nearExpired);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '到期 10 天 → 維持 fresh',
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(
            FoodItemListAdd(foodItem: makeFood(id: 'b', daysToExpire: 10))));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>().having(
            (s) => s.foodItems.single.status, 'status', FoodItemStatus.fresh),
      ],
    );
  });

  group('編輯 / 移除 / 清空（food-inventory）', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '修改到期日 → 保留 id、重新排序、寫入 Box',
      setUp: () async {
        await box.put('a', makeFood(id: 'a', daysToExpire: 5));
        await box.put('b', makeFood(id: 'b', daysToExpire: 10));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        final original = (bloc.state as FoodItemListLoaded)
            .foodItems
            .firstWhere((f) => f.id == 'b');
        await bloc.settle(() => bloc.add(FoodItemListUpdate(
              originalFoodItem: original,
              updatedFoodItem:
                  original.copyWith(expirationDate: daysFromNow(1)),
            )));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>()
            .having((s) => ids(s.foodItems), 'order', ['b', 'a']),
      ],
      verify: (_) {
        expect(box.get('b')!.expirationDate.isBefore(daysFromNow(2)), isTrue);
        expect(box.length, 2);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '移除 → 清單與 Box 都不再有該 id',
      setUp: () async {
        await box.put('a', makeFood(id: 'a'));
        await box.put('b', makeFood(id: 'b'));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        final a = (bloc.state as FoodItemListLoaded)
            .foodItems
            .firstWhere((f) => f.id == 'a');
        await bloc.settle(() => bloc.add(FoodItemListRemove(foodItem: a)));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>().having((s) => ids(s.foodItems), 'ids', ['b']),
      ],
      verify: (_) => expect(box.containsKey('a'), isFalse),
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '清空 → Loaded([]) 且 Box 為空',
      setUp: () => box.put('a', makeFood(id: 'a')),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(FoodItemListClear()));
      },
      skip: 2,
      expect: () => const [
        FoodItemListLoading(),
        FoodItemListLoaded(foodItems: []),
      ],
      verify: (_) => expect(box.isEmpty, isTrue),
    );
  });

  group('過期處理（expired-food-processing）', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '切換第 2 筆是否食用只影響該筆',
      setUp: () async {
        await box.put('x', makeFood(id: 'x', daysToExpire: -2));
        await box.put('y', makeFood(id: 'y', daysToExpire: -1));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(
            () => bloc.add(FoodItemListProcessingUpdate(updateIndex: 1)));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListNeedProcessing>()
            .having((s) => s.isConsumed, 'isConsumed', [false, true]),
      ],
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '處理完成 → 只剩未過期項目，且已處理項目從 Box 移除（重啟不再要求處理）',
      setUp: () async {
        await box.put('old', makeFood(id: 'old', daysToExpire: -1));
        await box.put('ok', makeFood(id: 'ok', daysToExpire: 10));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(FoodItemListProcessComplete()));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>()
            .having((s) => ids(s.foodItems), 'ids', ['ok']),
      ],
      verify: (_) {
        expect(box.containsKey('old'), isFalse, reason: '已處理的過期項目必須離開本機儲存');
        expect(box.containsKey('ok'), isTrue);
      },
    );
  });

  group('還原載入（cloud-backup-restore → FoodItemListLoad）', () {
    blocTest<FoodItemListBloc, FoodItemListState>(
      '含過期 → NeedProcessing；未過期寫入 Box 且保留各自 id；2 天內標記 nearExpired',
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(FoodItemListLoad(foodItems: [
              makeFood(id: 'old', daysToExpire: -1),
              makeFood(id: 'soon', daysToExpire: 2),
              makeFood(id: 'far', daysToExpire: 10),
            ])));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListNeedProcessing>()
            .having((s) => ids(s.tempFoodItems), 'temp', ['old']).having(
                (s) => ids(s.remainFoodItems),
                'remain',
                ['soon', 'far']).having(
          (s) => s.remainFoodItems.first.status,
          'soon.status',
          FoodItemStatus.nearExpired,
        ),
      ],
      verify: (_) {
        expect(box.keys.toSet(), {'soon', 'far'},
            reason: 'copyWith 不得把 id 改成空字串而讓項目互相覆蓋');
        expect(box.get('soon')!.status, FoodItemStatus.nearExpired);
      },
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '還原整批取代既有本機資料（先清空再寫入）',
      setUp: () => box.put('old', makeFood(id: 'old', daysToExpire: 30)),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(FoodItemListLoad(foodItems: [
              makeFood(id: 'fromCloud', daysToExpire: 8),
            ])));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>()
            .having((s) => ids(s.foodItems), 'ids', ['fromCloud']),
      ],
      verify: (_) => expect(box.keys.toSet(), {'fromCloud'}),
    );

    blocTest<FoodItemListBloc, FoodItemListState>(
      '全部未過期 → Loaded 且全部寫入 Box',
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(FoodItemListLoad(foodItems: [
              makeFood(id: 'a', daysToExpire: 8),
              makeFood(id: 'b', daysToExpire: 9),
            ])));
      },
      skip: 2,
      expect: () => [
        const FoodItemListLoading(),
        isA<FoodItemListLoaded>()
            .having((s) => ids(s.foodItems).toSet(), 'ids', {'a', 'b'}),
      ],
      verify: (_) => expect(box.keys.toSet(), {'a', 'b'}),
    );
  });
}
