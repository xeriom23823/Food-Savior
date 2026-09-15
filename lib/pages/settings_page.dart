import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/cubits/locale_cubit.dart';
import 'package:food_savior/cubits/storage_location_cubit.dart';
import 'package:food_savior/cubits/theme_cubit.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/pages/storage_location_page.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/app_scaffold.dart';
import 'package:food_savior/widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return AppScaffold(
      title: strings.settingsPageTitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          SectionHeader(title: strings.settingsSection),
          _card([
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(strings.language),
              trailing: DropdownButton<Locale>(
                value: context.watch<LocaleCubit>().state,
                underline: const SizedBox.shrink(),
                // 語言名稱刻意用母語寫（endonym），不隨介面語系翻譯。
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
                  if (locale != null) {
                    context.read<LocaleCubit>().setLocale(locale);
                  }
                },
              ),
            ),
            const Divider(height: 1),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;
                return SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: Text(strings.darkMode),
                  value: isDark,
                  onChanged: (_) => context.read<ThemeCubit>().switchTheme(),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.shelves),
              title: Text(strings.storageLocations),
              trailing: const Icon(Icons.chevron_right),
              // 同上：推出去的路由拿不到這個子樹的 Provider，要手動帶過去。
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<StorageLocationCubit>(),
                    child: const StorageLocationPage(),
                  ),
                ),
              ),
            ),
          ]),
          SectionHeader(title: strings.aboutSection),
          _card([
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(strings.version),
              subtitle: const Text('1.0.0'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(strings.openSource),
              subtitle: Text(strings.viewOnGitHub),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      );
}
