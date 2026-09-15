import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/hive_test_helper.dart';

/// Hive 的寫入是真的磁碟 I/O，一個 microtask 等不到；blocTest 要多等一下。
const Duration _hiveWrite = Duration(milliseconds: 300);

void main() {
  final env = HiveTestEnv();
  late Box<UsedFoodItem> box;
  late UsedFoodItemRepository repo;

  setUpAll(env.setUpAll);
  tearDownAll(env.tearDownAll);
  setUp(() async {
    box = await env.openBox<UsedFoodItem>('usedFoodItems');
    repo = UsedFoodItemRepository(usedFoodItemBox: box);
  });
  tearDown(() => box.deleteFromDisk());

  UsedFoodItemListBloc build() => UsedFoodItemListBloc(
        usedFoodItemRepository: repo,
        now: () => testNow,
      );

  UsedFoodItemListLoaded loadedOf(UsedFoodItemListState state) =>
      state as UsedFoodItemListLoaded;

  group('依日期瀏覽', () {
    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '預設顯示今天的紀錄',
      setUp: () async {
        await repo.saveUsedFoodItems([
          makeUsed(id: 'today', usedDate: testNow),
          makeUsed(id: 'yesterday', usedDate: daysFromNow(-1)),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const UsedFoodItemListStarted()),
      verify: (bloc) {
        expect(ids(loadedOf(bloc.state).usedFoodItems), ['today']);
      },
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '切換到昨天只顯示昨天的紀錄',
      setUp: () async {
        await repo.saveUsedFoodItems([
          makeUsed(id: 'today', usedDate: testNow),
          makeUsed(id: 'yesterday', usedDate: daysFromNow(-1)),
        ]);
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) =>
          bloc.add(UsedFoodItemListLoadByDate(date: daysFromNow(-1))),
      verify: (bloc) {
        expect(ids(loadedOf(bloc.state).usedFoodItems), ['yesterday']);
      },
    );
  });

  group('篩選', () {
    Future<void> seed() async {
      await repo.saveUsedFoodItems([
        makeUsed(id: 'eaten', disposalMethod: DisposalMethod.eaten),
        makeUsed(id: 'given', disposalMethod: DisposalMethod.givenAway),
        makeUsed(id: 'discarded', disposalMethod: DisposalMethod.discarded),
      ]);
    }

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '只看浪費時送人不計入',
      setUp: seed,
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(
        const UsedFoodItemListFilterChanged(filter: UsedFoodFilter.wasted),
      ),
      verify: (bloc) {
        expect(ids(loadedOf(bloc.state).usedFoodItems), ['discarded']);
      },
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '切換日期時保持篩選',
      setUp: seed,
      build: build,
      wait: _hiveWrite,
      act: (bloc) async {
        bloc.add(
          const UsedFoodItemListFilterChanged(filter: UsedFoodFilter.wasted),
        );
        await Future<void>.delayed(_hiveWrite);
        bloc.add(UsedFoodItemListLoadByDate(date: daysFromNow(-1)));
      },
      verify: (bloc) {
        expect(loadedOf(bloc.state).filter, UsedFoodFilter.wasted);
      },
    );
  });

  group('刪除與補記', () {
    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '刪除後本機儲存也不再有該筆',
      setUp: () async {
        await repo.saveUsedFoodItem(makeUsed(id: 'x'));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const UsedFoodItemListRemove(id: 'x')),
      verify: (bloc) {
        expect(loadedOf(bloc.state).usedFoodItems, isEmpty);
        expect(repo.getUsedFoodItem('x'), isNull);
      },
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '補記浪費原因不改變點數',
      setUp: () async {
        await repo.saveUsedFoodItem(makeUsed(
          id: 'x',
          disposalMethod: DisposalMethod.discarded,
          affectFoodPoint: -2,
        ));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const UsedFoodItemListSetWasteReason(
        id: 'x',
        wasteReason: WasteReason.boughtTooMuch,
      )),
      verify: (bloc) {
        final item = repo.getUsedFoodItem('x')!;
        expect(item.wasteReason, WasteReason.boughtTooMuch);
        expect(item.affectFoodPoint, -2);
      },
    );
  });

  group('還原', () {
    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '保留備份中的點數，不重新計算',
      setUp: () async {
        await repo.saveUsedFoodItem(makeUsed(id: 'old'));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(UsedFoodItemListLoad(usedFoodItems: [
        makeUsed(id: 'restored', affectFoodPoint: 5),
      ])),
      verify: (bloc) {
        expect(repo.getUsedFoodItem('old'), isNull);
        expect(repo.getUsedFoodItem('restored')!.affectFoodPoint, 5);
      },
    );

    blocTest<UsedFoodItemListBloc, UsedFoodItemListState>(
      '清空',
      setUp: () async {
        await repo.saveUsedFoodItem(makeUsed(id: 'x'));
      },
      build: build,
      wait: _hiveWrite,
      act: (bloc) => bloc.add(const UsedFoodItemListClear()),
      verify: (bloc) {
        expect(repo.getAllUsedFoodItems(), isEmpty);
      },
    );
  });
}
