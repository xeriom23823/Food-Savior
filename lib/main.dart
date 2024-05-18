import 'package:authentication_repository/authentication_repository.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/view/app.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list_bloc.dart';
import 'package:food_savior/firebase_options.dart';
import 'package:food_savior/languages/app_localizations.dart';
import 'package:food_savior/pages/char_and_statistics_page.dart';
import 'package:food_savior/pages/food_item_list_page.dart';
import 'package:food_savior/pages/settings_page.dart';
import 'package:food_savior/pages/used_food_item_list_page.dart';
import 'package:food_savior/pages/user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

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

  final List<Widget> _pages = const [
    UserPage(),
    ChartAndStatisticsPage(),
    FoodItemListPage(),
    UsedFoodItemListPage(),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FoodItemListBloc>(
          create: (BuildContext context) => FoodItemListBloc(),
        ),
        BlocProvider<UsedFoodItemListBloc>(
          create: (BuildContext context) => UsedFoodItemListBloc(),
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
          buttonBackgroundColor: Theme.of(context).colorScheme.onPrimary,
          animationDuration: const Duration(milliseconds: 500),
          index: 2,
          onTap: _onTabTapped,
          items: [
            CurvedNavigationBarItem(
              child: const Icon(Icons.person),
              label: AppLocalizations.of(context).userNavigationBarTitle,
            ),
            CurvedNavigationBarItem(
              child: const Icon(Icons.bar_chart),
              label: AppLocalizations.of(context)
                  .chartAndStatisticsNavigationBarTitle,
            ),
            CurvedNavigationBarItem(
              child: const Icon(Icons.food_bank),
              label:
                  AppLocalizations.of(context).foodItemListNavigationBarTitle,
            ),
            CurvedNavigationBarItem(
              child: const Icon(Icons.history),
              label: AppLocalizations.of(context)
                  .usedFoodItemListNavigationBarTitle,
            ),
            CurvedNavigationBarItem(
              child: const Icon(Icons.settings),
              label: AppLocalizations.of(context).settingsNavigationBarTitle,
            ),
          ],
        ),
      ),
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
