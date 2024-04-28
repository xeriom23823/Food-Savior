import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list_bloc.dart';
import 'package:food_savior/pages/food_item_list_page.dart';

void main() {
  runApp(const FoodSavior());
}

class FoodSavior extends StatelessWidget {
  const FoodSavior({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FoodItemListBloc>(
          create: (BuildContext context) => FoodItemListBloc(),
        ),
      ],
      child: MaterialApp(
        title: '食物救世主',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              secondary: Colors.orange,
              primary: Colors.green),
          useMaterial3: true,
        ),
        home: const FoodItemListPage(),
      ),
    );
  }
}
