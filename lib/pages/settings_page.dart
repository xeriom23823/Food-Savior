import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/locale_cubit.dart';
import 'package:food_savior/bloc/theme_cubit.dart';
import 'package:food_savior/languages/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settingsPageTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            trailing: DropdownButton<Locale>(
              value: context.watch<LocaleCubit>().state,
              items: const [
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('zh', 'TW'),
                  child: Text('中文'),
                ),
              ],
              onChanged: (locale) {
                context.read<LocaleCubit>().setLocale(locale!);
              },
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, state) {
              return ListTile(
                title: Text(AppLocalizations.of(context).darkMode),
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
            title: Text(AppLocalizations.of(context).showNotification),
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
