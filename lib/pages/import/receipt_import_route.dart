import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';
import 'package:food_savior/bloc/receipt_import/receipt_import_bloc.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/domain/receipt/receipt_draft_mapper.dart';
import 'package:food_savior/domain/receipt/receipt_layout_parser.dart';
import 'package:food_savior/models/food_suggestion.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/import/scan_receipt_page.dart';
import 'package:food_savior/repositories/food_preset_repository.dart';
import 'package:food_savior/repositories/product_noise_terms_repository.dart';
import 'package:food_savior/repositories/receipt_noise_terms_repository.dart';
import 'package:food_savior/services/ocr/image_picker_receipt_image_picker.dart';
import 'package:food_savior/services/ocr/mlkit_text_recognition_service.dart';

/// 把收據匯入需要的東西接起來的唯一地方。
///
/// ML Kit 與 `image_picker` 的實作類別只在這裡被 new 出來——
/// [ScanReceiptPage] 與 [ReceiptImportBloc] 都只看到介面。
abstract final class ReceiptImportRoute {
  /// 開啟收據匯入流程。回傳成功匯入的筆數；使用者中途離開則為 null。
  static Future<int?> open(
    BuildContext context, {
    LocationKind? locationKind,
    String? defaultLocationId,
    List<StorageLocation> locations = const [],
  }) {
    final foodItemListBloc = context.read<FoodItemListBloc>();
    final presets = context.read<FoodPresetRepository>().presets;
    final productNoise = context.read<ProductNoiseTermsRepository>().terms;
    final receiptNoise = context.read<ReceiptNoiseTermsRepository>().terms;

    return Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReceiptImportBloc(
            imagePicker: ImagePickerReceiptImagePicker(),
            recognizer: MlKitTextRecognitionService(),
            parser: ReceiptLayoutParser(noiseTerms: receiptNoise),
            mapper: ReceiptDraftMapper(
              suggestionEngine: FoodSuggestionEngine(presets: presets),
              cleaner: ProductNameCleaner(noiseTerms: productNoise),
            ),
            // 逐筆派發既有事件，`FoodItemListBloc` 完全不必為匯入改動（design D7）。
            onItemReady: (item) =>
                foodItemListBloc.add(FoodItemListAdd(foodItem: item)),
            locationKind: locationKind,
            defaultLocationId: defaultLocationId,
            locations: locations,
          )..add(const ReceiptImportStarted()),
          child: const ScanReceiptPage(),
        ),
      ),
    );
  }
}
