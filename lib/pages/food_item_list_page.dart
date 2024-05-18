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
import 'package:uuid/uuid.dart';

class FoodItemListPage extends StatefulWidget {
  const FoodItemListPage({super.key});

  @override
  State<FoodItemListPage> createState() => _FoodItemListPageState();
}

class _FoodItemListPageState extends State<FoodItemListPage>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;
  int expandedIndex = -1;

  // 隨機不重複 ID 生成器
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodItemListBloc, FoodItemListState>(
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
        } else if (state is FoodItemListNeedProcessing) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '過期食物清單',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Column(
              children: [
                // 標題欄位
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '食物資訊',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '是否過期',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.tempFoodItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      FoodItem foodItem = state.tempFoodItems[index];
                      bool isConsumed = state.isConsumed[index];
                      return ListTile(
                        title: Text(
                            '${foodItem.name} (${foodItem.quantityWithUnit(context)})'),
                        leading: Icon(foodItem.type.icon,
                            color: foodItem.status.color),
                        subtitle: Text(foodItem.description),
                        trailing: IconButton(
                          onPressed: () {
                            context.read<FoodItemListBloc>().add(
                                  FoodItemListProcessingUpdate(
                                    updateIndex: index,
                                  ),
                                );
                          },
                          icon: Icon(
                            isConsumed
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isConsumed
                                ? FoodItemStatus.consumed.color
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 處理完成按鈕
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton(
                    onPressed: () {
                      List<FoodItem> tempFoodItems = state.tempFoodItems;
                      List<bool> isConsumed = state.isConsumed;
                      List<UsedFoodItem> usedFoodItems = [];
                      for (int i = 0; i < tempFoodItems.length; i++) {
                        FoodItem foodItem = tempFoodItems[i];
                        UsedFoodItem usedFoodItem = foodItem.toUsedFoodItem(
                          id: _uuid.v4(),
                          usedStatus: isConsumed[i]
                              ? FoodItemStatus.consumed
                              : FoodItemStatus.wasted,
                          usedDate: DateTime.now(),
                          usedQuantity: foodItem.quantity,
                        );
                        usedFoodItems.add(usedFoodItem);
                      }

                      context.read<UsedFoodItemListBloc>().add(
                            UsedFoodItemListAddMultiple(
                              usedFoodItems: usedFoodItems,
                            ),
                          );

                      context.read<FoodItemListBloc>().add(
                            FoodItemListProcessComplete(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // 按鈕的最小尺寸
                    ),
                    child: const Text('處理完成'),
                  ),
                ),
              ],
            ),
          );
        } else if (state is FoodItemListLoaded) {
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
            body: ListView.builder(
              itemCount: state.foodItems.length,
              itemBuilder: (BuildContext context, int index) {
                final FoodItem foodItem = state.foodItems[index];
                return Slidable(
                  key: ValueKey(index),

                  // 左邊的動作面板
                  startActionPane: ActionPane(
                    extentRatio: 0.2,
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          _showEditFoodItemDialog(context, foodItem);
                          _slidableController.close();
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
                    extentRatio: 0.75,
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          // 建立新的用過的 FoodItem
                          context
                              .read<FoodItemListBloc>()
                              .add(FoodItemListRemove(foodItem: foodItem));
                          UsedFoodItem newUsedFoodItem =
                              foodItem.toUsedFoodItem(
                                  id: _uuid.v4(),
                                  usedStatus: FoodItemStatus.wasted,
                                  usedDate: DateTime.now(),
                                  usedQuantity: foodItem.quantity);

                          // 加入用過的 FoodItem 清單
                          context.read<UsedFoodItemListBloc>().add(
                              UsedFoodItemListAdd(
                                  usedFoodItem: newUsedFoodItem));

                          _slidableController.close();

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
                          _slidableController.close();
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

                          // 建立新的用過的 FoodItem
                          foodItemListBloc
                              .add(FoodItemListRemove(foodItem: foodItem));

                          UsedFoodItem newUsedFoodItem =
                              foodItem.toUsedFoodItem(
                                  id: _uuid.v4(),
                                  usedStatus: FoodItemStatus.consumed,
                                  usedDate: DateTime.now(),
                                  usedQuantity: foodItem.quantity);

                          // 加入用過的 FoodItem 清單
                          usedFoodItemListBloc.add(UsedFoodItemListAdd(
                              usedFoodItem: newUsedFoodItem));

                          _slidableController.close();

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
                      _showFoodItemInformationDialog(context, foodItem);
                    },
                    title: Text(
                        '${foodItem.name} (${foodItem.quantityWithUnit(context)})'),
                    leading:
                        Icon(foodItem.type.icon, color: foodItem.status.color),
                    subtitle: Text(foodItem.description),
                    trailing: Text(
                      foodItem.expirationDate
                                  .difference(DateTime.now())
                                  .inDays ==
                              0
                          ? AppLocalizations.of(context).expireToday
                          : foodItem.expirationDate
                                      .difference(DateTime.now())
                                      .inDays <
                                  0
                              ? AppLocalizations.of(context).expired
                              : '${AppLocalizations.of(context).expire} : ${foodItem.expirationDate.difference(DateTime.now()).inDays} ${AppLocalizations.of(context).days}',
                    ),
                  ),
                );
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
    );
  }

  void _showFoodItemInformationDialog(
      BuildContext pageContext, FoodItem foodItem) {
    final FoodItemListBloc foodItemListBloc =
        BlocProvider.of<FoodItemListBloc>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(foodItem.name)),
              IconButton(
                onPressed: () {
                  foodItemListBloc.add(FoodItemListRemove(foodItem: foodItem));
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditFoodItemDialog(pageContext, foodItem);
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Icon(foodItem.type.icon,
                    color: foodItem.status.color, size: 50),
                Text(
                  foodItem.type.name(pageContext),
                  style: TextStyle(color: foodItem.status.color),
                ),
                Text(foodItem.description),
                Text(
                    '${AppLocalizations.of(context).quantity} : ${foodItem.quantity} ${foodItem.unit.name(context)}'),
                Text(
                    '${AppLocalizations.of(context).storageDate} : ${DateFormat('yyyy-MM-dd').format(foodItem.storageDate)}'),
                Text(
                    '${AppLocalizations.of(context).expirationDate} : ${DateFormat('yyyy-MM-dd').format(foodItem.expirationDate)}'),
              ],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: foodItem.status.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showUseFoodItemDialog(pageContext, foodItem);
                },
                icon:
                    const Icon(Icons.restaurant_outlined, color: Colors.white),
              ),
            ),
          ],
        );
      },
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
                  id: _uuid.v4(),
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
                  id: originalFoodItem.id,
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
    final formKey = GlobalKey<FormState>();

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
            child: Form(
              key: formKey, // Set the maximum height here
              child: Column(
                children: [
                  Text(
                      '${AppLocalizations.of(context).use} ${usingFoodItem.name}'),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).quantity,
                      suffixText: usingFoodItem.unit.name(context),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      int enteredQuantity = int.tryParse(value) ?? 0;
                      if (enteredQuantity > usingFoodItem.quantity) {
                        quantityController.text =
                            usingFoodItem.quantity.toString();
                      }
                      formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)
                            .quantityCannotBeEmpty;
                      }

                      int enteredQuantity = int.tryParse(value) ?? 0;
                      if (enteredQuantity <= 0) {
                        return AppLocalizations.of(context)
                            .quantityMustBePositive;
                      }

                      if (enteredQuantity > usingFoodItem.quantity) {
                        return AppLocalizations.of(context)
                            .quantityExceedsAvailable;
                      }

                      return null;
                    },
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
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final int usedQuantity = int.parse(quantityController.text);
                final FoodItem remainFoodItem = usingFoodItem.copyWith(
                  id: usingFoodItem.id,
                  quantity: usingFoodItem.quantity - usedQuantity,
                );

                if (remainFoodItem.quantity > 0) {
                  foodItemListBloc.add(FoodItemListUpdate(
                      originalFoodItem: usingFoodItem,
                      updatedFoodItem: remainFoodItem));
                } else {
                  foodItemListBloc
                      .add(FoodItemListRemove(foodItem: usingFoodItem));
                }

                final UsedFoodItem usedFoodItem = usingFoodItem.toUsedFoodItem(
                    id: _uuid.v4(),
                    usedStatus: FoodItemStatus.consumed,
                    usedDate: DateTime.parse(usedDateController.text),
                    usedQuantity: usedQuantity);

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
