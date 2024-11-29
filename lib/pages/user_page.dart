import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_savior/app/bloc/app_bloc.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/food_item.dart';
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
            // 新增兩個按鈕：備份與還原
            ElevatedButton(
              onPressed: _isBackingUp
                  ? null
                  : () {
                      final foodItemList = context
                          .read<FoodItemListBloc>()
                          .foodItemRepository
                          .getAllFoodItems();
                      final usedFoodItemList = context
                          .read<UsedFoodItemListBloc>()
                          .usedFoodItemRepository
                          .getAllUsedFoodItems();

                      backupData(user.id, foodItemList, usedFoodItemList);
                    },
              child: _isBackingUp
                  ? const CircularProgressIndicator()
                  : const Text('備份'),
            ),
            ElevatedButton(
              onPressed: _isRestoring
                  ? null
                  : () async {
                      try {
                        final foodItemListBloc =
                            BlocProvider.of<FoodItemListBloc>(context);
                        final usedFoodItemListBloc =
                            BlocProvider.of<UsedFoodItemListBloc>(context);
                        setState(() => _isRestoring = true);

                        // 清除在地資料
                        foodItemListBloc.add(FoodItemListClear());
                        usedFoodItemListBloc.add(UsedFoodItemListClear());

                        // 從伺服器取得資料
                        final Map<String, dynamic> data =
                            await restoreData(user.id);

                        if (data.isNotEmpty) {
                          // 還原已使用食物資料
                          final List<UsedFoodItem> usedFoodItems =
                              data['usedFoodItems'];

                          usedFoodItemListBloc.add(UsedFoodItemListLoad(
                              usedFoodItems: usedFoodItems));

                          // 還原食物資料
                          final List<FoodItem> foodItems = data['foodItems'];
                          foodItemListBloc
                              .add(FoodItemListLoad(foodItems: foodItems));

                          setState(() => _isRestoring = false);

                          // 顯示成功訊息
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('資料還原成功')),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          _isRestoring = false;
                        });

                        // 顯示錯誤訊息
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('資料還原失敗: $e')),
                        );
                      }
                    },
              child: _isRestoring
                  ? const CircularProgressIndicator()
                  : const Text('還原'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> backupData(String userId, List<FoodItem> foodItemList,
      List<UsedFoodItem> usedFoodItemList) async {
    setState(() {
      _isBackingUp = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 將 foodItemList 轉換為 JSON 格式
    final List<String> foodItemsJson =
        foodItemList.map((foodItem) => foodItem.toJsonString()).toList();

    // 將 usedFoodItemList 轉換為 JSON 格式
    final List<String> usedFoodItemsJson = usedFoodItemList
        .map((usedFoodItem) => usedFoodItem.toJsonString())
        .toList();

    // 確認 Firestore 中是否已有該用戶的備份資料
    final DocumentSnapshot backupDoc =
        await firestore.collection('backups').doc(userId).get();
    if (backupDoc.exists) {
      // 若已有該用戶的備份資料，則先刪除
      await firestore.collection('backups').doc(userId).delete();
    }

    // 將 foodItemList 與 usedFoodItemList 存入 Firestore
    await firestore.collection('backups').doc(userId).set({
      'foodItems': foodItemsJson,
      'usedFoodItems': usedFoodItemsJson,
    });

    setState(() => _isBackingUp = false);

    // 顯示成功訊息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('資料備份成功')),
    );
  }

  Future<Map<String, dynamic>> restoreData(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 從 Firestore 中獲取備份數據
    final DocumentSnapshot<Map<String, dynamic>> backupDoc =
        await firestore.collection('backups').doc(userId).get();

    if (backupDoc.exists) {
      // 將 JSON 格式的數據轉換回 FoodItem 對象
      List<FoodItem> foodItems = (backupDoc['foodItems'] as List)
          .map((foodItemJson) => FoodItem.fromJsonString(foodItemJson))
          .toList();

      // 將 JSON 格式的數據轉換回 UsedFoodItem 對象
      List<UsedFoodItem> usedFoodItems = (backupDoc['usedFoodItems'] as List)
          .map((usedFoodItemJson) =>
              UsedFoodItem.fromJsonString(usedFoodItemJson))
          .toList();

      // 返回 foodItems 和 usedFoodItems
      return {
        'foodItems': foodItems,
        'usedFoodItems': usedFoodItems,
      };
    }

    // 如果沒有找到備份數據，則返回空的 Map
    return {};
  }
}
