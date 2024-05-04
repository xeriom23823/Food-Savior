import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '設定',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('語言'),
            trailing: DropdownButton<String>(
              items: ['中文', 'English'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, state) {
              return ListTile(
                title: const Text('暗黑模式'),
                trailing: Switch(
                  value: state.brightness == Brightness.dark,
                  onChanged: (bool value) {
                    context.read<ThemeCubit>().switchTheme();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('顯示通知'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
        ],
      ),
    );
  }
}
