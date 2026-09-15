import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 語系選擇（app-settings 規格）：切換立即生效，並持久化在 SharedPreferences，
/// 重新啟動後還原；首次啟動預設 zh_TW。
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance(),
        super(defaultLocale) {
    _loadLocale();
  }

  /// 只儲存語言碼（zh / en），還原時對應回 [supportedLocales] 中的完整 Locale，
  /// 設定頁 Dropdown 的 value 才會與選項相等。
  static const String localeKey = 'localeLanguageCode';
  static const Locale defaultLocale = Locale('zh', 'TW');
  static const List<Locale> supportedLocales = [
    Locale('zh', 'TW'),
    Locale('en', 'US'),
  ];

  final Future<SharedPreferences> _preferences;
  bool _userHasChosen = false;

  Future<void> _loadLocale() async {
    final prefs = await _preferences;
    final saved = _supportedFor(prefs.getString(localeKey));
    // 使用者若在載入完成前已切換，以使用者的選擇為準
    if (saved != null && !_userHasChosen && saved != state) emit(saved);
  }

  Future<void> setLocale(Locale locale) async {
    final supported = _supportedFor(locale.languageCode);
    if (supported == null) return;
    _userHasChosen = true;
    if (supported != state) emit(supported);
    final prefs = await _preferences;
    await prefs.setString(localeKey, supported.languageCode);
  }

  bool isSupported(Locale locale) => _supportedFor(locale.languageCode) != null;

  static Locale? _supportedFor(String? languageCode) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) return locale;
    }
    return null;
  }
}
