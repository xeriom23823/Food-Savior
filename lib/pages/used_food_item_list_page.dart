import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:intl/intl.dart';

class UsedFoodItemListPage extends StatefulWidget {
  const UsedFoodItemListPage({super.key});

  @override
  State<UsedFoodItemListPage> createState() => _UsedFoodItemListPageState();
}

class _UsedFoodItemListPageState extends State<UsedFoodItemListPage> {
  FoodItemStatus dropdownValue = FoodItemStatus.consumed;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Center(
                child: Row(
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        _showSelectDateDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            DropdownButton<FoodItemStatus>(
              dropdownColor: Theme.of(context).primaryColor,
              value: dropdownValue,
              onChanged: (FoodItemStatus? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <FoodItemStatus>[
                FoodItemStatus.consumed,
                FoodItemStatus.wasted
              ].map<DropdownMenuItem<FoodItemStatus>>((FoodItemStatus value) {
                return DropdownMenuItem<FoodItemStatus>(
                  value: value,
                  child: Text(
                    value.name(context),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: BlocConsumer<UsedFoodItemListBloc, UsedFoodItemListState>(
        listener: (context, state) {
          if (state is UsedFoodItemListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.black),
                ),
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime.now();
                          });
                        },
                        child: const Text('返回今天'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.add(const Duration(days: 1));
                          });
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.usedFoodItems.length,
                    itemBuilder: (context, index) {
                      final usedFoodItem = state.usedFoodItems[index];
                      if (usedFoodItem.status != dropdownValue ||
                          usedFoodItem.usedDate.year != selectedDate.year ||
                          usedFoodItem.usedDate.month != selectedDate.month ||
                          usedFoodItem.usedDate.day != selectedDate.day) {
                        return const SizedBox.shrink();
                      }
                      return ListTile(
                        onTap: () {
                          _showUsedFoodItemInformationDialog(
                              context, usedFoodItem);
                        },
                        title: Text(
                            '${usedFoodItem.name} (${usedFoodItem.quantity} ${usedFoodItem.unit.name(context)})'),
                        leading: Icon(usedFoodItem.type.icon,
                            color: usedFoodItem.status.color),
                        subtitle: usedFoodItem.description.isNotEmpty
                            ? Text(usedFoodItem.description)
                            : Text(
                                '${usedFoodItem.affectFoodPoint >= 0 ? '+' : ''} ${usedFoodItem.affectFoodPoint} 食物點數',
                                style: TextStyle(
                                    color: usedFoodItem.status.color)),
                        trailing: Text(
                          '使用日期：${DateFormat('yyyy-MM-dd').format(usedFoodItem.usedDate)}',
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  void _showUsedFoodItemInformationDialog(
      BuildContext pageContext, UsedFoodItem usedFoodItem) {
    showDialog(
      context: pageContext,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(usedFoodItem.name),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  BlocProvider.of<UsedFoodItemListBloc>(pageContext).add(
                    UsedFoodItemListRemove(usedFoodItem: usedFoodItem),
                  );
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Icon(usedFoodItem.type.icon,
                    color: usedFoodItem.status.color, size: 50),
                Text(usedFoodItem.description),
                Text(
                  usedFoodItem.type.name(pageContext),
                  style: TextStyle(color: usedFoodItem.status.color),
                ),
                Text(
                    '數量：${usedFoodItem.quantity} ${usedFoodItem.unit.name(context)}'),
                Text('食物點數：${usedFoodItem.affectFoodPoint}'),
                Text(
                    '使用日期：${DateFormat('yyyy-MM-dd').format(usedFoodItem.usedDate)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectDateDialog(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedDate = value;
        });
      }
    });
  }
}
