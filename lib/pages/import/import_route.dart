import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/import/import_bloc.dart';
import 'package:food_savior/domain/import/invoice_draft_mapper.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/import/scan_invoice_page.dart';
import 'package:food_savior/repositories/food_preset_repository.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:food_savior/repositories/product_noise_terms_repository.dart';
import 'package:food_savior/services/scanner/mobile_scanner_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 把掃描頁需要的東西接起來的唯一地方。
///
/// 真正的 `MobileScanner` widget 只在這裡出現——[ScanInvoicePage] 收的是一個
/// builder，所以 widget test 可以塞一個佔位 widget 進去（design D9）。
abstract final class ImportRoute {
  /// 掃描入口只在有相機的行動平台出現（design D10）。
  ///
  /// 用 `Theme.of(context).platform` 而不是 `dart:io` 的 `Platform`：後者在 Web
  /// 上會編譯失敗，而專案必須維持所有平台可編譯。
  static bool isSupportedOn(BuildContext context) =>
      switch (Theme.of(context).platform) {
        TargetPlatform.android || TargetPlatform.iOS => true,
        _ => false,
      };

  /// 開啟掃描流程。回傳成功匯入的筆數；使用者中途離開則為 null。
  static Future<int?> open(
    BuildContext context, {
    LocationKind? locationKind,
    String? defaultLocationId,
    List<StorageLocation> locations = const [],
  }) {
    final foodItemListBloc = context.read<FoodItemListBloc>();
    final presets = context.read<FoodPresetRepository>().presets;
    final noiseTerms = context.read<ProductNoiseTermsRepository>().terms;
    final preferences = context.read<PreferencesRepository>();

    return Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) {
            final service = MobileScannerService();
            return ImportBloc(
              scannerService: service,
              mapper: InvoiceDraftMapper(
                suggestionEngine: FoodSuggestionEngine(presets: presets),
                cleaner: ProductNameCleaner(noiseTerms: noiseTerms),
              ),
              preferencesRepository: preferences,
              // 逐筆派發既有事件，`FoodItemListBloc` 完全不必為匯入改動（design D7）。
              onItemReady: (item) =>
                  foodItemListBloc.add(FoodItemListAdd(foodItem: item)),
              locationKind: locationKind,
              defaultLocationId: defaultLocationId,
              locations: locations,
            )..add(const ImportStarted());
          },
          child: Builder(
            builder: (context) => ScanInvoicePage(
              previewBuilder: (_) => MobileScanner(
                controller: (context.read<ImportBloc>().scannerService
                        as MobileScannerService)
                    .controller,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
