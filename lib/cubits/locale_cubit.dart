import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('zh', 'TW'));

  void setLocale(Locale locale) {
    if (!isSupported(locale)) return;

    emit(locale);
  }

  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);
}
