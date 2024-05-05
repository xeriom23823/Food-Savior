import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list_bloc.dart';
import 'package:food_savior/languages/app_localizations.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        title: Text(
          AppLocalizations.of(context).foodItemListNavigationBarTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<FoodItemListBloc, FoodItemListState>(
        listener: (BuildContext context, FoodItemListState state) {
          if (state is FoodItemListError) {
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
                  height: 70,
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
                          label: AppLocalizations.of(context).edit,
                        ),
                      ],
                    ),

                    // 右邊的動作面板
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            // 取得會使用的 bloc
                            final FoodItemListBloc foodItemListBloc =
                                context.read<FoodItemListBloc>();
                            final UsedFoodItemListBloc usedFoodItemListBloc =
                                context.read<UsedFoodItemListBloc>();

                            // 確認今日的食物點數是否已經達到上限
                            DateTime now = DateTime.now();
                            int todayFoodPoint = await SharedPreferences
                                    .getInstance()
                                .then((prefs) =>
                                    prefs.getInt(
                                        'FoodPoint/${now.year}/${now.month}/${now.day}') ??
                                    0);

                            // 建立新的用過的 FoodItem
                            foodItemListBloc
                                .add(FoodItemListRemove(foodItem: foodItem));
                            UsedFoodItem newUsedFoodItem =
                                foodItem.toUsedFoodItem(
                                    usedStatus: FoodItemStatus.wasted,
                                    usedDate: now,
                                    usedQuantity: foodItem.quantity,
                                    affectFoodPoint:
                                        todayFoodPoint <= -10 ? 0 : -1);

                            // 加入用過的 FoodItem 清單
                            usedFoodItemListBloc.add(UsedFoodItemListAdd(
                                usedFoodItem: newUsedFoodItem));

                            controller.close();

                            // 提示使用者已刪除
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          '${newUsedFoodItem.name} ${AppLocalizations.of(context).wasted}',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                      Lottie.asset(
                                        'assets/animations/dumping.json',
                                        width: 50,
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            });
                          },
                          backgroundColor: FoodItemStatus.wasted.color,
                          foregroundColor: Colors.white,
                          icon: MdiIcons.deleteEmpty,
                          label: AppLocalizations.of(context).expire,
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            _showUseFoodItemDialog(context, foodItem);
                            controller.close();
                          },
                          backgroundColor: FoodItemStatus.consumed.color,
                          foregroundColor: Colors.white,
                          icon: Icons.restaurant,
                          label: AppLocalizations.of(context).batchUse,
                        ),
                        SlidableAction(
                          onPressed: (_) async {
                            // 取得會使用的 bloc
                            final FoodItemListBloc foodItemListBloc =
                                context.read<FoodItemListBloc>();
                            final UsedFoodItemListBloc usedFoodItemListBloc =
                                context.read<UsedFoodItemListBloc>();

                            // 確認今日的食物點數是否已經達到上限
                            DateTime now = DateTime.now();
                            int todayFoodPoint = await SharedPreferences
                                    .getInstance()
                                .then((prefs) =>
                                    prefs.getInt(
                                        'FoodPoint/${now.year}/${now.month}/${now.day}') ??
                                    0);

                            // 建立新的用過的 FoodItem
                            foodItemListBloc
                                .add(FoodItemListRemove(foodItem: foodItem));

                            UsedFoodItem newUsedFoodItem =
                                foodItem.toUsedFoodItem(
                                    usedStatus: FoodItemStatus.consumed,
                                    usedDate: now,
                                    usedQuantity: foodItem.quantity,
                                    affectFoodPoint:
                                        todayFoodPoint >= 10 ? 0 : 1);

                            // 加入用過的 FoodItem 清單
                            usedFoodItemListBloc.add(UsedFoodItemListAdd(
                                usedFoodItem: newUsedFoodItem));

                            controller.close();

                            // 提示使用者已食用
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          '${newUsedFoodItem.name} ${newUsedFoodItem.quantityWithUnit(context)} ${AppLocalizations.of(context).consumed}',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                      Lottie.asset(
                                        'assets/animations/eating.json',
                                        width: 50,
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            });
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.restaurant,
                          label: AppLocalizations.of(context).useAll,
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
                          '${foodItem.name} (${foodItem.quantityWithUnit(context)})'),
                      leading: Icon(foodItem.type.icon,
                          color: foodItem.status.color),
                      subtitle: Text(foodItem.description),
                      trailing: Text(
                        '${AppLocalizations.of(context).expire} : ${DateFormat('yyyy-MM-dd').format(foodItem.expirationDate)}',
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
                  Text(AppLocalizations.of(context).foodItemListError),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<FoodItemListBloc>()
                          .add(FoodItemListLoadFromDevice());
                    },
                    child: Text(AppLocalizations.of(context).refresh),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

    // get blocs
    final FoodItemListBloc foodItemListBloc =
        BlocProvider.of<FoodItemListBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).addFoodItem),
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
                            Text(type.name(context)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).name),
                    onChanged: (value) {
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).nameCannotBeEmpty;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).quantity),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantityController.text = value;
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)
                            .quantityCannotBeEmpty;
                      }

                      if (int.tryParse(value) == null) {
                        return AppLocalizations.of(context)
                            .quanityMustBeANumber;
                      }

                      if (int.parse(value) <= 0) {
                        return AppLocalizations.of(context)
                            .quantityMustBePositive;
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
                        child: Text(unit.name(context)),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).unit),
                    validator: (value) {
                      if (value == null) {
                        return AppLocalizations.of(context).unitCannotBeEmpty;
                      }
                      return null;
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).description),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, storageDateController);
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: storageDateController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context).storageDate),
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
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context).expirationDate),
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
              child: Text(AppLocalizations.of(context).cancel),
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
                foodItemListBloc.add(FoodItemListAdd(foodItem: newFoodItem));
                Navigator.of(context).pop();

                // 提示使用者已更新
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white,
                    content: Text(
                      '${newFoodItem.name} ${AppLocalizations.of(context).added}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context).add),
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

    // get blocs
    final FoodItemListBloc foodItemListBloc =
        BlocProvider.of<FoodItemListBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).editFoodItem),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  foodItemListBloc
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
                            Text(type.name(context)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).name),
                    onChanged: (value) {
                      nameController.text = value;
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).nameCannotBeEmpty;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).quantity),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantityController.text = value;
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)
                            .quantityCannotBeEmpty;
                      }

                      if (int.tryParse(value) == null) {
                        return AppLocalizations.of(context)
                            .quanityMustBeANumber;
                      }

                      if (int.parse(value) <= 0) {
                        return AppLocalizations.of(context)
                            .quantityMustBePositive;
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
                        child: Text(unit.name(context)),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).unit),
                    validator: (value) {
                      if (value == null) {
                        return AppLocalizations.of(context).unitCannotBeEmpty;
                      }
                      return null;
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).description),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, storageDateController);
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: storageDateController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context).storageDate),
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
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context).expirationDate),
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
              child: Text(AppLocalizations.of(context).cancel),
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

                foodItemListBloc.add(FoodItemListUpdate(
                    originalFoodItem: originalFoodItem,
                    updatedFoodItem: updatedFoodItem));
                Navigator.of(context).pop();

                // 提示使用者已更新
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white,
                    content: Text(
                        '${updatedFoodItem.name} ${AppLocalizations.of(context).updated}',
                        style: const TextStyle(color: Colors.black)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context).save),
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

    // get blocs
    final FoodItemListBloc foodItemListBloc =
        BlocProvider.of<FoodItemListBloc>(context);
    final UsedFoodItemListBloc usedFoodItemListBloc =
        BlocProvider.of<UsedFoodItemListBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).useFoodItem),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                    '${AppLocalizations.of(context).use} ${usingFoodItem.name}'),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).quantity),
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
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).usedDate),
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
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () async {
                final int usedQuantity = int.parse(quantityController.text);
                final FoodItem remainFoodItem = usingFoodItem.copyWith(
                  quantity: usingFoodItem.quantity - usedQuantity,
                );

                if (remainFoodItem.quantity > 0) {
                  foodItemListBloc.add(FoodItemListUpdate(
                      originalFoodItem: usingFoodItem,
                      updatedFoodItem: remainFoodItem));
                }

                // 確認當日的食物點數是否已經達到上限
                DateTime consumedDate = DateTime.parse(usedDateController.text);
                int consumedDateFoodPoint =
                    await SharedPreferences.getInstance().then((prefs) =>
                        prefs.getInt(
                            'FoodPoint/${consumedDate.year}/${consumedDate.month}/${consumedDate.day}') ??
                        0);

                final UsedFoodItem usedFoodItem = usingFoodItem.toUsedFoodItem(
                    usedStatus: FoodItemStatus.consumed,
                    usedDate: DateTime.parse(usedDateController.text),
                    usedQuantity: usedQuantity,
                    affectFoodPoint: consumedDateFoodPoint >= 10 ? 0 : 1);

                if (usedQuantity > 0) {
                  usedFoodItemListBloc
                      .add(UsedFoodItemListAdd(usedFoodItem: usedFoodItem));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop();

                  // 提示使用者已食用
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${usedFoodItem.name} ${usedFoodItem.quantityWithUnit(context)} ${AppLocalizations.of(context).consumed}',
                              style: const TextStyle(color: Colors.black)),
                          Lottie.asset('assets/animations/eating.json',
                              width: 50, height: 50),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                });
              },
              child: Text(AppLocalizations.of(context).use),
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
