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
  List<DateTime> selectedWeek = [];

  @override
  void initState() {
    super.initState();
    updateSelectedWeek();
  }

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
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child: Row(
                    children: [
                      for (final day in selectedWeek) ...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 7,
                          child: Column(
                            children: [
                              Text(
                                DateFormat('E').format(day),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                              GestureDetector(
                                onHorizontalDragEnd: (DragEndDetails details) {
                                  // 通過滑動速度的方向判斷滑動方向
                                  if (details.velocity.pixelsPerSecond.dx > 0) {
                                    // 向右滑動，減少日期
                                    setState(() {
                                      selectedDate = selectedDate
                                          .subtract(const Duration(days: 1));
                                      updateSelectedWeek();
                                    });
                                  } else if (details
                                          .velocity.pixelsPerSecond.dx <
                                      0) {
                                    // 向左滑動，增加日期
                                    setState(() {
                                      selectedDate = selectedDate
                                          .add(const Duration(days: 1));
                                      updateSelectedWeek();
                                    });
                                  }
                                },
                                onTap: () {
                                  setState(() {
                                    selectedDate = day;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 7,
                                  height: MediaQuery.of(context).size.width /
                                      7 *
                                      0.8,
                                  margin:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (DateTime.now().day == day.day &&
                                            DateTime.now().month == day.month &&
                                            DateTime.now().year == day.year)
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withAlpha(100)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: day == selectedDate
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat('dd').format(day),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: day == selectedDate
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        subtitle: Text(
                          '${usedFoodItem.affectFoodPoint >= 0 ? '+' : ''} ${usedFoodItem.affectFoodPoint} 食物點數',
                          style: TextStyle(color: usedFoodItem.status.color),
                        ),
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
          updateSelectedWeek();
        });
      }
    });
  }

  void updateSelectedWeek() {
    final dayOfWeek = selectedDate.weekday;
    final firstDayOfWeek = selectedDate.subtract(Duration(days: dayOfWeek - 1));
    selectedWeek =
        List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }
}
