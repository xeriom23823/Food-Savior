import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/bloc/used_food_item_list_bloc.dart';
import 'package:food_savior/pages/food_item_list_page.dart';
import 'package:food_savior/pages/used_food_item_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kDebugMode) {
  //   SharedPreferences.getInstance().then((prefs) {
  //     prefs.clear();
  //   });
  // }

  runApp(const FoodSavior());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const FoodSavior());
  });
}

class FoodSavior extends StatefulWidget {
  const FoodSavior({super.key});

  @override
  State<FoodSavior> createState() => _FoodSaviorState();
}

class _FoodSaviorState extends State<FoodSavior> {
  final _pageController = PageController();
  int _pageIndex = 1;

  final List<Widget> _pages = const [
    FoodItemListPage(),
    FoodItemListPage(),
    UsedFoodItemListPage(),
    FoodItemListPage()
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale:
            const Locale('zh', 'TW'), // Set the locale to Traditional Chinese
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'TW'), // Traditional Chinese
          Locale('en', 'US'), // English
        ],
        title: '食物救世主',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              secondary: Colors.orange,
              primary: Colors.green),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: null,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: Colors.lightGreen,
            index: _pageIndex,
            animationDuration: const Duration(milliseconds: 500),
            onTap: _onTabTapped,
            items: const [
              CurvedNavigationBarItem(
                child: Icon(Icons.person),
                label: '用戶',
              ),
              CurvedNavigationBarItem(
                child: Icon(Icons.food_bank),
                label: '食物',
              ),
              CurvedNavigationBarItem(
                child: Icon(Icons.history),
                label: '紀錄',
              ),
              CurvedNavigationBarItem(
                child: Icon(Icons.settings),
                label: '設定',
              ),
            ],
          ),
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
