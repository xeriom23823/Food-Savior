import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';

class FoodItemListPage extends StatelessWidget {
  const FoodItemListPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodItemListBloc>().add(FoodItemListLoad());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Items'),
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
                return ListTile(
                  title: Text(foodItem.name),
                  subtitle: Text(foodItem.description),
                  trailing: Text(foodItem.expirationDate.toString()),
                );
              },
            );
          } else {
            return const Center(
              child: Text('An error occurred'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<FoodItemListBloc>().add(
                FoodItemListAdd(
                  FoodItem(
                    name: 'Strawberry',
                    type: FoodItemType.fruit,
                    status: FoodItemStatus.fresh,
                    description: 'A red strawberry',
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
