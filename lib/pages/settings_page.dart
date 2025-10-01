import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/cubits/locale_cubit.dart';
import 'package:food_savior/cubits/theme_cubit.dart';
import 'package:food_savior/generated/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '設定',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(S.of(context).language),
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
                    const Divider(),
                    BlocBuilder<ThemeCubit, ThemeData>(
                      builder: (context, state) {
                        return ListTile(
                          leading: Icon(
                            state.brightness == Brightness.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          title: Text(S.of(context).darkMode),
                          trailing: Switch(
                            value: state.brightness == Brightness.dark,
                            onChanged: (bool value) {
                              context.read<ThemeCubit>().switchTheme();
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(S.of(context).showNotification),
                      trailing: Switch(
                        value: false,
                        onChanged: (bool value) {
                          // TODO: 實現通知功能
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '關於',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('版本'),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('開源專案'),
                      subtitle: const Text('在 GitHub 上查看'),
                      onTap: () {
                        // TODO: 打開 GitHub 連結
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
