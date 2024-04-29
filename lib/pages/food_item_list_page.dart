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
          _showAddFoodItemDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFoodItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController storageDateController = TextEditingController();
    final TextEditingController expirationDateController =
        TextEditingController();
    FoodItemType selectedType = FoodItemType.others;

    // Set default storage date as DateTime.now()
    storageDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Set default expiration date as 7 days from now
    final DateTime expirationDate = DateTime.now().add(const Duration(days: 7));
    expirationDateController.text =
        DateFormat('yyyy-MM-dd').format(expirationDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增食物'),
          content: SizedBox(
            height: 300, // Set the maximum height here
            child: Column(
              children: [
                DropdownButtonFormField<FoodItemType>(
                  value: selectedType,
                  onChanged: (value) {
                    selectedType = value!;
                  },
                  items: FoodItemType.values.map((type) {
                    return DropdownMenuItem<FoodItemType>(
                      value: type,
                      child: Row(
                        children: [
                          Icon(type.icon),
                          const SizedBox(width: 10),
                          Text(type.name),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '名稱'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: '描述'),
                ),
                GestureDetector(
                  onTap: () {
                    _selectStorageDate(context, storageDateController);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: storageDateController,
                      decoration: const InputDecoration(labelText: '存放日期'),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _selectExpirationDate(
                        context,
                        DateTime.parse(storageDateController.text),
                        expirationDateController);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: expirationDateController,
                      decoration: const InputDecoration(labelText: '過期日期'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final FoodItem foodItem = FoodItem(
                  name: nameController.text,
                  type: selectedType,
                  status: FoodItemStatus.fresh,
                  description: descriptionController.text,
                  storageDate: DateTime.parse(storageDateController.text),
                  expirationDate: DateTime.parse(expirationDateController.text),
                );
                context.read<FoodItemListBloc>().add(FoodItemListAdd(foodItem));
                Navigator.of(context).pop();
              },
              child: const Text('新增'),
            ),
          ],
        );
      },
    );
  }

  void _selectStorageDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isEmpty
          ? DateTime.now()
          : DateTime.parse(controller.text),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _selectExpirationDate(BuildContext context, DateTime storageDate,
      TextEditingController expirationDateTextController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expirationDateTextController.text.isEmpty
          ? DateTime.now()
          : DateTime.parse(expirationDateTextController.text),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      expirationDateTextController.text =
          DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}
