import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/view/app.dart';
import 'package:food_savior/app/view/bootstrap_splash.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/cubits/storage_location_cubit.dart';
import 'package:food_savior/firebase_options.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/hive/hive_registrar.g.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/char_and_statistics_page.dart';
import 'package:food_savior/pages/food_item_list/food_item_list_page.dart';
import 'package:food_savior/pages/settings_page.dart';
import 'package:food_savior/pages/used_food_item_list_page.dart';
import 'package:food_savior/pages/user_page.dart';
import 'package:food_savior/repositories/backup_repository.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/food_preset_repository.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:food_savior/repositories/product_noise_terms_repository.dart';
import 'package:food_savior/repositories/receipt_noise_terms_repository.dart';
import 'package:food_savior/repositories/storage_location_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapSplash());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  final directory = await getApplicationDocumentsDirectory();
  Hive
    ..init(directory.path)
    ..registerAdapters();

  // Box 名稱是新的：舊版的 foodItem／usedFoodItem 永遠不再開啟（design D22），
  // 所以不需要任何遷移程式碼。
  final foodItemBox = await Hive.openBox<FoodItem>('foodItems');
  final usedFoodItemBox = await Hive.openBox<UsedFoodItem>('usedFoodItems');
  final storageLocationBox =
      await Hive.openBox<StorageLocation>('storageLocations');

  final preferences = await SharedPreferences.getInstance();
  final preferencesRepository = PreferencesRepository(preferences: preferences);
  final storageLocationRepository =
      StorageLocationRepository(storageLocationBox: storageLocationBox);

  if (!preferencesRepository.hasSeededLocations) {
    await seedDefaultStorageLocations(
      repository: storageLocationRepository,
      defaults: _defaultLocations(),
    );
    await preferencesRepository.markLocationsSeeded();
  }

  final presetRepository = FoodPresetRepository();
  await presetRepository.load();

  final noiseTermsRepository = ProductNoiseTermsRepository();
  await noiseTermsRepository.load();

  final receiptNoiseTermsRepository = ReceiptNoiseTermsRepository();
  await receiptNoiseTermsRepository.load();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => FoodItemRepository(foodItemBox: foodItemBox),
        ),
        RepositoryProvider(
          create: (context) =>
              UsedFoodItemRepository(usedFoodItemBox: usedFoodItemBox),
        ),
        RepositoryProvider.value(value: storageLocationRepository),
        RepositoryProvider.value(value: preferencesRepository),
        RepositoryProvider.value(value: presetRepository),
        RepositoryProvider.value(value: noiseTermsRepository),
        RepositoryProvider.value(value: receiptNoiseTermsRepository),
        RepositoryProvider(create: (context) => BackupRepository()),
      ],
      child: App(authenticationRepository: authenticationRepository),
    ),
  );
}

/// 預設位置的名稱依裝置語系決定一次，之後以字串保存，不隨語系變動。
List<({String name, LocationKind kind})> _defaultLocations() {
  final languageCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final isChinese = languageCode.startsWith('zh');
  // 這裡的字串是要「存進資料」的初始值，不是介面文案：
  // 種下去之後使用者可以改名，改名後不隨語系變動（design D14）。
  return [
    (name: isChinese ? '冷藏' : 'Fridge', kind: LocationKind.refrigerated),
    (name: isChinese ? '冷凍' : 'Freezer', kind: LocationKind.frozen),
    (name: isChinese ? '常溫' : 'Pantry', kind: LocationKind.ambient),
  ];
}

class FoodSavior extends StatefulWidget {
  const FoodSavior({super.key});

  static Page<void> page() => const MaterialPage<void>(child: FoodSavior());

  @override
  State<FoodSavior> createState() => _FoodSaviorState();
}

class _FoodSaviorState extends State<FoodSavior> {
  static const int _initialIndex = 2;

  final _pageController = PageController(initialPage: _initialIndex);
  int _index = _initialIndex;

  static const List<Widget> _pages = [
    UserPage(),
    ChartAndStatisticsPage(),
    FoodItemListPage(),
    UsedFoodItemListPage(),
    SettingsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FoodItemListBloc>(
          create: (context) => FoodItemListBloc(
            foodItemRepository: context.read<FoodItemRepository>(),
            usedFoodItemRepository: context.read<UsedFoodItemRepository>(),
            storageLocationRepository:
                context.read<StorageLocationRepository>(),
            preferencesRepository: context.read<PreferencesRepository>(),
            presetRepository: context.read<FoodPresetRepository>(),
          )..add(const FoodItemListStarted()),
        ),
        BlocProvider<UsedFoodItemListBloc>(
          create: (context) => UsedFoodItemListBloc(
            usedFoodItemRepository: context.read<UsedFoodItemRepository>(),
          )..add(const UsedFoodItemListStarted()),
        ),
        BlocProvider<StorageLocationCubit>(
          create: (context) => StorageLocationCubit(
            storageLocationRepository:
                context.read<StorageLocationRepository>(),
            foodItemRepository: context.read<FoodItemRepository>(),
          ),
        ),
      ],
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onTabTapped,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: S.of(context).userNavigationBarTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: S.of(context).chartAndStatisticsNavigationBarTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.kitchen_outlined),
              selectedIcon: const Icon(Icons.kitchen),
              label: S.of(context).foodItemListNavigationBarTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history),
              label: S.of(context).usedFoodItemListNavigationBarTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: S.of(context).settingsNavigationBarTitle,
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}
