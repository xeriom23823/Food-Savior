import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        children: <Widget>[
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            trailing: DropdownButton<String>(
              items: [
                const Locale('zh', 'TW'),
                const Locale('en', 'US'),
                // Add other locales here...
              ].map((Locale locale) {
                return DropdownMenuItem<String>(
                  value: locale.languageCode,
                  child: Text(locale.languageCode),
                );
              }).toList(),
              value: Localizations.localeOf(context).languageCode,
              onChanged: (String? languageCode) {
                AppLocalizations.load(Locale(languageCode!));
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
