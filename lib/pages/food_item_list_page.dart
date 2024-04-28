import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:intl/intl.dart';

class FoodItemListPage extends StatelessWidget {
  const FoodItemListPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodItemListBloc>().add(FoodItemListLoad());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('食物清單'),
      ),
      body: BlocBuilder<FoodItemListBloc, FoodItemListState>(
        builder: (BuildContext context, FoodItemListState state) {
          if (state is FoodItemListInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is FoodItemListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is FoodItemListLoaded) {
            return ListView.builder(
              itemCount: state.foodItems.length,
              itemBuilder: (BuildContext context, int index) {
                final FoodItem foodItem = state.foodItems[index];
                return GestureDetector(
                  onDoubleTap: () {
                    context.read<FoodItemListBloc>().add(
                          FoodItemListRemove(foodItem),
                        );
                  },
                  child: ListTile(
                    title: Text(foodItem.name),
                    leading:
                        Icon(foodItem.type.icon, color: foodItem.status.color),
                    subtitle: Text(foodItem.description),
                    trailing: Text(
                      '過期：${DateFormat('yyyy-MM-dd').format(foodItem.expirationDate)}',
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Column(
                children: [
                  const Text('讀取錯誤，請重新整理。'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FoodItemListBloc>().add(FoodItemListLoad());
                    },
                    child: const Text('重新整理'),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<FoodItemListBloc>().add(
                FoodItemListAdd(
                  FoodItem(
                    name: '草莓',
                    type: FoodItemType.fruit,
                    status: FoodItemStatus.fresh,
                    description: '一顆紅色草莓',
                    storageDate: DateTime.now(),
                    expirationDate: DateTime.now().add(const Duration(days: 3)),
                  ),
                ),
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
