import 'package:authentication_repository/authentication_repository.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/view/app.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list/used_food_item_list_bloc.dart';
import 'package:food_savior/firebase_options.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/hive/hive_registrar.g.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/pages/char_and_statistics_page.dart';
import 'package:food_savior/pages/food_item_list_page.dart';
import 'package:food_savior/pages/settings_page.dart';
import 'package:food_savior/pages/used_food_item_list_page.dart';
import 'package:food_savior/pages/user_page.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase & AuthenticationRepository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  // 初始化 Hive & Boxes
  final directory = await getApplicationDocumentsDirectory();
  Hive
    ..init(directory.path)
    ..registerAdapters();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(App(
      authenticationRepository: authenticationRepository,
    ));
  });
}

class FoodSavior extends StatefulWidget {
  const FoodSavior({super.key});
  static Page<void> page() => const MaterialPage<void>(child: FoodSavior());

  @override
  State<FoodSavior> createState() => _FoodSaviorState();
}

class _FoodSaviorState extends State<FoodSavior> {
  final _pageController = PageController(initialPage: 2);
  late final Box<FoodItem> _foodItemBox;
  late final Box<UsedFoodItem> _usedFoodItemBox;

  final List<Widget> _pages = const [
    UserPage(),
    ChartAndStatisticsPage(),
    FoodItemListPage(),
    UsedFoodItemListPage(),
    SettingsPage()
  ];

  Future<void> _openBoxes() async {
    _foodItemBox = await Hive.openBox('foodItem');
    _usedFoodItemBox = await Hive.openBox('usedFoodItem');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _openBoxes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                create: (context) =>
                    FoodItemRepository(foodItemBox: _foodItemBox),
              ),
              RepositoryProvider(
                create: (context) =>
                    UsedFoodItemRepository(usedFoodItemBox: _usedFoodItemBox),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<FoodItemListBloc>(
                  create: (context) => FoodItemListBloc(
                    foodItemRepository: context.read<FoodItemRepository>(),
                  ),
                ),
                BlocProvider<UsedFoodItemListBloc>(
                  create: (context) => UsedFoodItemListBloc(
                    usedFoodItemRepository:
                        context.read<UsedFoodItemRepository>(),
                  ),
                ),
              ],
              child: Scaffold(
                body: PageView(
                  controller: _pageController,
                  onPageChanged: null,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _pages,
                ),
                bottomNavigationBar: CurvedNavigationBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).colorScheme.onPrimary,
                  buttonBackgroundColor:
                      Theme.of(context).colorScheme.onPrimary,
                  animationDuration: const Duration(milliseconds: 500),
                  index: 2,
                  onTap: _onTabTapped,
                  items: [
                    CurvedNavigationBarItem(
                      child: const Icon(Icons.person),
                      label: S.of(context).userNavigationBarTitle,
                    ),
                    CurvedNavigationBarItem(
                      child: const Icon(Icons.bar_chart),
                      label: S.of(context).chartAndStatisticsNavigationBarTitle,
                    ),
                    CurvedNavigationBarItem(
                      child: const Icon(Icons.food_bank),
                      label: S.of(context).foodItemListNavigationBarTitle,
                    ),
                    CurvedNavigationBarItem(
                      child: const Icon(Icons.history),
                      label: S.of(context).usedFoodItemListNavigationBarTitle,
                    ),
                    CurvedNavigationBarItem(
                      child: const Icon(Icons.settings),
                      label: S.of(context).settingsNavigationBarTitle,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
