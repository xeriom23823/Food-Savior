import 'package:food_savior/models/food_item.dart';
import 'package:hive_ce/hive.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<FoodItemType>(),
  AdapterSpec<FoodItemStatus>(),
  AdapterSpec<Unit>(),
  AdapterSpec<FoodItem>(),
  AdapterSpec<UsedFoodItem>(),
])
class HiveAdapters {}
