import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FoodItemListPage extends StatefulWidget {
  const FoodItemListPage({super.key});

  @override
  State<FoodItemListPage> createState() => _FoodItemListPageState();
}

class _FoodItemListPageState extends State<FoodItemListPage> {
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<FoodItemListBloc>().add(FoodItemListLoad());
  }

  @override
  Widget build(BuildContext context) {
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
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: Row(
                    children: [
                      SizedBox(
                        width: expandedIndex == index
                            ? MediaQuery.of(context).size.width - 120
                            : MediaQuery.of(context).size.width,
                        height: 60,
                        child: GestureDetector(
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
                          onHorizontalDragUpdate: (details) {
                            if (details.delta.dx < 0) {
                              setState(() {
                                expandedIndex = index;
                              });
                            } else if (details.delta.dx > 0) {
                              setState(() {
                                expandedIndex = -1;
                              });
                            }
                          },
                          child: ListTile(
                            title: Text(foodItem.name),
                            leading: Icon(foodItem.type.icon,
                                color: foodItem.status.color),
                            subtitle: Text(foodItem.description),
                            trailing: Text(
                              '過期：${DateFormat('yyyy-MM-dd').format(foodItem.expirationDate)}',
                            ),
                          ),
                        ),
                      ),
                      if (expandedIndex == index) ...[
                        Container(
                          width: 60,
                          height: 60,
                          color: Colors.green,
                          child: IconButton(
                            onPressed: () {
                              context
                                  .read<FoodItemListBloc>()
                                  .add(FoodItemListRemove(foodItem: foodItem));
                              setState(() {
                                expandedIndex = -1;
                              });
                            },
                            icon: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          color: Colors.red,
                          child: IconButton(
                            onPressed: () {
                              context
                                  .read<FoodItemListBloc>()
                                  .add(FoodItemListRemove(foodItem: foodItem));
                              setState(() {
                                expandedIndex = -1;
                              });
                            },
                            icon: Icon(
                              MdiIcons.deleteEmpty,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
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

    final formKey = GlobalKey<FormState>();

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
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController storageDateController = TextEditingController();
    final TextEditingController expirationDateController =
        TextEditingController();
    FoodItemType selectedType = FoodItemType.others;

    final formKey = GlobalKey<FormState>();

    // Set default date as originalFoodItem
    nameController.text = originalFoodItem.name;
    selectedType = originalFoodItem.type;
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
