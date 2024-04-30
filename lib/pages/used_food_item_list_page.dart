import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list_bloc.dart';
import 'package:intl/intl.dart';

class UsedFoodItemListPage extends StatefulWidget {
  const UsedFoodItemListPage({super.key});

  @override
  State<UsedFoodItemListPage> createState() => _UsedFoodItemListPageState();
}

class _UsedFoodItemListPageState extends State<UsedFoodItemListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消耗食物歷史紀錄'),
      ),
      body: BlocConsumer<UsedFoodItemListBloc, UsedFoodItemListState>(
        listener: (context, state) {
          if (state is UsedFoodItemListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UsedFoodItemListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UsedFoodItemListLoaded) {
            return ListView.builder(
              itemCount: state.usedFoodItems.length,
              itemBuilder: (context, index) {
                final usedFoodItem = state.usedFoodItems[index];
                return ListTile(
                  title: Text(usedFoodItem.name),
                  subtitle: Text(usedFoodItem.description),
                  trailing: Text(
                    '使用日期：${DateFormat('yyyy-MM-dd').format(usedFoodItem.usedDate)}',
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No data'),
            );
          }
        },
      ),
    );
  }
}
