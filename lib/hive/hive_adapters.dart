import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:hive_ce/hive.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<FoodItemType>(),
  AdapterSpec<FoodItemStatus>(),
  AdapterSpec<Unit>(),
  AdapterSpec<RemainingFraction>(),
  AdapterSpec<ExpiryPrecision>(),
  AdapterSpec<WasteReason>(),
  AdapterSpec<DisposalMethod>(),
  AdapterSpec<LocationKind>(),
  AdapterSpec<FoodItem>(),
  AdapterSpec<UsedFoodItem>(),
  AdapterSpec<StorageLocation>(),
])
class HiveAdapters {}
