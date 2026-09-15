import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

Future<void> untilLoaded(UsedFoodItemListBloc bloc) async {
  if (bloc.state is UsedFoodItemListLoaded) return;
  await bloc.stream.firstWhere((s) => s is UsedFoodItemListLoaded);
}

/// 派發事件後等到 Bloc 真正回到穩定狀態（Loaded / NeedProcessing），
/// 否則 bloc_test 會在 Hive 寫入完成前 close()，遺失最後的 emit。
extension on UsedFoodItemListBloc {
  Future<void> settle(void Function() action) {
    final done = stream.firstWhere((s) => s is UsedFoodItemListLoaded);
    action();
    return done;
  }
}

void main() {
  final env = HiveTestEnv();
  late Box<UsedFoodItem> box;
  late UsedFoodItemRepository repo;
  final today = DateTime.now();

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<UsedFoodItem>('usedFoodItem');
    repo = UsedFoodItemRepository(usedFoodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  UsedFoodItemListBloc build() =>
      UsedFoodItemListBloc(usedFoodItemRepository: repo);

  Future<void> seedConsumedToday(int count) async {
    for (var i = 0; i < count; i++) {
      await box.put('seed$i',
          makeUsed(id: 'seed$i', usedDate: today, affectFoodPoint: 1));
    }
  }

  List<int> pointsOf(UsedFoodItemListState s, Iterable<String> idList) {
    final items = (s as UsedFoodItemListLoaded).usedFoodItems;
    return idList
        .map((id) => items.firstWhere((u) => u.id == id).affectFoodPoint)
        .toList();
  }

  group('載入（usage-history）', () {
    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '空 Box → Loading → Loaded([])',
      build: build,
      act: untilLoaded,
      expect: () => const [
        UsedFoodItemListLoading(),
        UsedFoodItemListLoaded(usedFoodItems: []),
      ],
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      'LoadByDate 只回傳該日（忽略時間）',
      setUp: () async {
        await box.put(
            't1',
            makeUsed(
                id: 't1',
                usedDate: DateTime(today.year, today.month, today.day, 8)));
        await box.put(
            't2',
            makeUsed(
                id: 't2',
                usedDate: DateTime(today.year, today.month, today.day, 22)));
        await box.put('y', makeUsed(id: 'y', usedDate: daysFromNow(-1)));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc
            .settle(() => bloc.add(UsedFoodItemListLoadByDate(date: today)));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => ids(s.usedFoodItems).toSet(), 'ids', {'t1', 't2'}),
      ],
    );
  });

  group('食物點數（food-points）', () {
    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '食用 → +1',
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListAdd(
            usedFoodItem: makeUsed(id: 'c', status: FoodItemStatus.consumed))));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => s.usedFoodItems.single.affectFoodPoint, 'point', 1),
      ],
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '浪費 → -1',
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListAdd(
            usedFoodItem: makeUsed(id: 'w', status: FoodItemStatus.wasted))));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => s.usedFoodItems.single.affectFoodPoint, 'point', -1),
      ],
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '當日已達 10 點 → 新食用紀錄為 0',
      setUp: () => seedConsumedToday(10),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListAdd(
            usedFoodItem: makeUsed(id: 'c', usedDate: today))));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => pointsOf(s, ['c']), 'point', [0]),
      ],
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '當日 9 點 → 新食用紀錄為 +1',
      setUp: () => seedConsumedToday(9),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListAdd(
            usedFoodItem: makeUsed(id: 'c', usedDate: today))));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => pointsOf(s, ['c']), 'point', [1]),
      ],
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '上限不影響浪費：當日 12 點仍為 -1',
      setUp: () => seedConsumedToday(12),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListAdd(
            usedFoodItem: makeUsed(
                id: 'w', status: FoodItemStatus.wasted, usedDate: today))));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => pointsOf(s, ['w']), 'point', [-1]),
      ],
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '批次新增（過期處理）依序套用上限：9 點 + 3 筆食用 → +1, 0, 0；浪費仍 -1',
      setUp: () => seedConsumedToday(9),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListAddAll(usedFoodItems: [
              makeUsed(id: 'c1', usedDate: today),
              makeUsed(id: 'c2', usedDate: today),
              makeUsed(id: 'c3', usedDate: today),
              makeUsed(
                  id: 'w1', status: FoodItemStatus.wasted, usedDate: today),
            ])));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => s.usedFoodItems.length, 'count', 13)
            .having((s) => pointsOf(s, ['c1', 'c2', 'c3', 'w1']), 'points',
                [1, 0, 0, -1]),
      ],
      verify: (_) => expect(box.get('c2')!.affectFoodPoint, 0),
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '還原載入保留備份中的點數，不重算',
      setUp: () => seedConsumedToday(10),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListLoad(usedFoodItems: [
              makeUsed(id: 'r', usedDate: today, affectFoodPoint: 5),
            ])));
      },
      skip: 2,
      expect: () => [
        isA<UsedFoodItemListLoaded>()
            .having((s) => pointsOf(s, ['r']), 'point', [5]),
      ],
      verify: (_) => expect(box.get('r')!.affectFoodPoint, 5),
    );
  });

  group('移除 / 更新 / 清空（usage-history）', () {
    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '移除 → 清單與 Box 都不再有該 id',
      setUp: () async {
        await box.put('a', makeUsed(id: 'a'));
        await box.put('b', makeUsed(id: 'b'));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() =>
            bloc.add(UsedFoodItemListRemove(usedFoodItem: box.get('a')!)));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => ids(s.usedFoodItems), 'ids', ['b']),
      ],
      verify: (_) => expect(box.containsKey('a'), isFalse),
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '更新 → 寫入 Box 並依使用日期排序',
      setUp: () async {
        await box.put('a', makeUsed(id: 'a', usedDate: daysFromNow(-1)));
        await box.put('b', makeUsed(id: 'b', usedDate: daysFromNow(-3)));
      },
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        final a = box.get('a')!;
        await bloc.settle(() => bloc.add(UsedFoodItemListUpdate(
              originalUsedFoodItem: a,
              updatedUsedFoodItem: a.copyWith(quantity: 9),
            )));
      },
      skip: 2,
      expect: () => [
        const UsedFoodItemListLoading(),
        isA<UsedFoodItemListLoaded>()
            .having((s) => ids(s.usedFoodItems), 'order', ['b', 'a']).having(
                (s) => s.usedFoodItems.last.quantity, 'quantity', 9),
      ],
      verify: (_) => expect(box.get('a')!.quantity, 9),
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '清空 → Loaded([]) 且 Box 為空',
      setUp: () => box.put('a', makeUsed(id: 'a')),
      build: build,
      act: (bloc) async {
        await untilLoaded(bloc);
        await bloc.settle(() => bloc.add(UsedFoodItemListClear()));
      },
      skip: 2,
      expect: () => const [
        UsedFoodItemListLoading(),
        UsedFoodItemListLoaded(usedFoodItems: []),
      ],
      verify: (_) => expect(box.isEmpty, isTrue),
    );
  });
}
