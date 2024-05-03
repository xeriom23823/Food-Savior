import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FoodItemListPage extends StatefulWidget {
  const FoodItemListPage({super.key});

  @override
  State<FoodItemListPage> createState() => _FoodItemListPageState();
}

class _FoodItemListPageState extends State<FoodItemListPage>
    with SingleTickerProviderStateMixin {
  late final controller = SlidableController(this);
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食物清單',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<FoodItemListBloc, FoodItemListState>(
        listener: (BuildContext context, FoodItemListState state) {
          if (state is FoodItemListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
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
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: Slidable(
                    key: ValueKey(index),

                    // 左邊的動作面板
                    startActionPane: ActionPane(
                      extentRatio: 0.15,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            _showEditFoodItemDialog(context, foodItem);

                            controller.close();
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: '編輯',
                        ),
                      ],
                    ),

                    // 右邊的動作面板
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            context
                                .read<FoodItemListBloc>()
                                .add(FoodItemListRemove(foodItem: foodItem));

                            // 建立新的用過的 FoodItem
                            UsedFoodItem newUsedFoodItem =
                                foodItem.toUsedFoodItem(
                                    usedStatus: FoodItemStatus.wasted,
                                    usedDate: DateTime.now(),
                                    usedQuantity: foodItem.quantity);

                            // 加入用過的 FoodItem 清單
                            context.read<UsedFoodItemListBloc>().add(
                                UsedFoodItemListAdd(
                                    usedFoodItem: newUsedFoodItem));

                            controller.close();
                          },
                          backgroundColor: FoodItemStatus.wasted.color,
                          foregroundColor: Colors.white,
                          icon: MdiIcons.deleteEmpty,
                          label: '過期',
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            _showUseFoodItemDialog(context, foodItem);
                            controller.close();
                          },
                          backgroundColor: FoodItemStatus.consumed.color,
                          foregroundColor: Colors.white,
                          icon: Icons.restaurant,
                          label: '批量使用',
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            context
                                .read<FoodItemListBloc>()
                                .add(FoodItemListRemove(foodItem: foodItem));

                            // 建立新的用過的 FoodItem
                            UsedFoodItem newUsedFoodItem =
                                foodItem.toUsedFoodItem(
                                    usedStatus: FoodItemStatus.consumed,
                                    usedDate: DateTime.now(),
                                    usedQuantity: foodItem.quantity);

                            // 加入用過的 FoodItem 清單
                            context.read<UsedFoodItemListBloc>().add(
                                UsedFoodItemListAdd(
                                    usedFoodItem: newUsedFoodItem));

                            controller.close();
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.restaurant,
                          label: '全部使用',
                        ),
                      ],
                    ),

                    child: ListTile(
                      onLongPress: () {
                        setState(() {
                          expandedIndex = -1;
                        });
                        _showEditFoodItemDialog(context, foodItem);
                      },
                      onTap: () {
                        setState(() {
                          expandedIndex = -1;
                        });
                      },
                      title: Text(
                          '${foodItem.name} (${foodItem.quantityWithUnit})'),
                      leading: Icon(foodItem.type.icon,
                          color: foodItem.status.color),
                      subtitle: Text(foodItem.description),
                      trailing: Text(
                        '過期：${DateFormat('yyyy-MM-dd').format(foodItem.expirationDate)}',
                      ),
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
                      context
                          .read<FoodItemListBloc>()
                          .add(FoodItemListLoadFromDevice());
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
    final TextEditingController quantityController = TextEditingController();
    Unit selectedUnit = Unit.piece;
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController storageDateController = TextEditingController();
    final TextEditingController expirationDateController =
        TextEditingController();
    FoodItemType selectedType = FoodItemType.others;

    final formKey = GlobalKey<FormState>();

    // Set default quantity as 1
    quantityController.text = '1';

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
          content: SingleChildScrollView(
            child: Form(
              key: formKey, // Set the maximum height here
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
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '名稱'),
                    onChanged: (value) {
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '文字不能為空';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: '數量'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantityController.text = value;
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '數字不能為空';
                      }
                      if (int.tryParse(value) == null) {
                        return '請輸入有效的數字';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<Unit>(
                    value: selectedUnit,
                    onChanged: (value) {
                      selectedUnit = value!;
                    },
                    items: Unit.values.map((unit) {
                      return DropdownMenuItem<Unit>(
                        value: unit,
                        child: Text(unit.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: '單位'),
                    validator: (value) {
                      if (value == null) {
                        return '請選擇單位';
                      }
                      return null;
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '描述'),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, storageDateController);
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
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final FoodItem newFoodItem = FoodItem(
                  name: nameController.text,
                  type: selectedType,
                  status: FoodItemStatus.fresh,
                  quantity: int.parse(quantityController.text),
                  unit: selectedUnit,
                  description: descriptionController.text,
                  storageDate: DateTime.parse(storageDateController.text),
                  expirationDate: DateTime.parse(expirationDateController.text),
                );
                context
                    .read<FoodItemListBloc>()
                    .add(FoodItemListAdd(foodItem: newFoodItem));
                Navigator.of(context).pop();

                // 提示使用者已更新
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newFoodItem.name} 已新增'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('新增'),
            ),
          ],
        );
      },
    );
  }

  void _showEditFoodItemDialog(
      BuildContext context, FoodItem originalFoodItem) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    Unit selectedUnit = originalFoodItem.unit;
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController storageDateController = TextEditingController();
    final TextEditingController expirationDateController =
        TextEditingController();
    FoodItemType selectedType = FoodItemType.others;

    final formKey = GlobalKey<FormState>();

    // Set default date as originalFoodItem
    nameController.text = originalFoodItem.name;
    selectedType = originalFoodItem.type;
    quantityController.text = originalFoodItem.quantity.toString();
    descriptionController.text = originalFoodItem.description;
    storageDateController.text =
        DateFormat('yyyy-MM-dd').format(originalFoodItem.storageDate);

    expirationDateController.text =
        DateFormat('yyyy-MM-dd').format(originalFoodItem.expirationDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('編輯食物'),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  context
                      .read<FoodItemListBloc>()
                      .add(FoodItemListRemove(foodItem: originalFoodItem));
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '名稱'),
                    onChanged: (value) {
                      nameController.text = value;
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '文字不能為空';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: '數量'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantityController.text = value;
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '數字不能為空';
                      }
                      if (int.tryParse(value) == null) {
                        return '請輸入有效的數字';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<Unit>(
                    value: selectedUnit,
                    onChanged: (value) {
                      selectedUnit = value!;
                    },
                    items: Unit.values.map((unit) {
                      return DropdownMenuItem<Unit>(
                        value: unit,
                        child: Text(unit.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: '單位'),
                    validator: (value) {
                      if (value == null) {
                        return '請選擇單位';
                      }
                      return null;
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '描述'),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, storageDateController);
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
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final FoodItem updatedFoodItem = FoodItem(
                  name: nameController.text,
                  type: selectedType,
                  status: FoodItemStatus.fresh,
                  quantity: int.parse(quantityController.text),
                  unit: selectedUnit,
                  description: descriptionController.text,
                  storageDate: DateTime.parse(storageDateController.text),
                  expirationDate: DateTime.parse(expirationDateController.text),
                );

                context.read<FoodItemListBloc>().add(FoodItemListUpdate(
                    originalFoodItem: originalFoodItem,
                    updatedFoodItem: updatedFoodItem));
                Navigator.of(context).pop();

                // 提示使用者已更新
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${updatedFoodItem.name} 已更新'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('儲存'),
            ),
          ],
        );
      },
    );
  }

  void _showUseFoodItemDialog(BuildContext context, FoodItem usingFoodItem) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController usedDateController = TextEditingController();

    // set default quantity as 1
    quantityController.text = '1';

    // set default used date as DateTime.now()
    usedDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('使用食物'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('使用 ${usingFoodItem.name}'),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: '數量'),
                  keyboardType: TextInputType.number,
                ),
                // Add a date picker for the used date
                GestureDetector(
                  onTap: () {
                    _selectDate(context, usedDateController);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: usedDateController,
                      decoration: const InputDecoration(labelText: '使用日期'),
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
                final int usedQuantity = int.parse(quantityController.text);

                final FoodItem remainFoodItem = usingFoodItem.copyWith(
                  quantity: usingFoodItem.quantity - usedQuantity,
                );

                if (remainFoodItem.quantity > 0) {
                  context.read<FoodItemListBloc>().add(FoodItemListUpdate(
                      originalFoodItem: usingFoodItem,
                      updatedFoodItem: remainFoodItem));
                }

                final UsedFoodItem usedFoodItem = usingFoodItem.toUsedFoodItem(
                    usedStatus: FoodItemStatus.consumed,
                    usedDate: DateTime.parse(usedDateController.text),
                    usedQuantity: usedQuantity);

                if (usedQuantity > 0) {
                  context
                      .read<UsedFoodItemListBloc>()
                      .add(UsedFoodItemListAdd(usedFoodItem: usedFoodItem));
                }

                Navigator.of(context).pop();

                // 提示使用者已更新
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${remainFoodItem.name} 已更新'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('使用'),
            ),
          ],
        );
      },
    );
  }

  void _selectDate(
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
