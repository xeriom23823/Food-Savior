import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/services.dart' show PlatformException;
import 'package:food_savior/domain/receipt/ocr_result.dart';
import 'package:food_savior/services/ocr/text_recognition_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// [TextRecognitionService] 的實作。**整個專案唯一 import ML Kit 文字辨識的檔案**
/// （design D2）。
///
/// 中文 script 的模型與條碼模型一樣走 Play Services 動態下載
/// （manifest 的 `com.google.mlkit.vision.DEPENDENCIES` 含 `ocr`），
/// 不打包進 APK。
class MlKitTextRecognitionService implements TextRecognitionService {
  MlKitTextRecognitionService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  final TextRecognizer _recognizer;

  /// Debug 建置時把辨識結果以這個前綴逐行印到 log，
  /// `adb logcat | grep` 就能倒成 fixture（design D6）。
  static const String fixtureLogTag = '[receipt-ocr-fixture]';

  @override
  Future<RecognitionResult> recognize(String imagePath) async {
    final RecognizedText recognized;
    try {
      recognized = await _recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
    } on PlatformException {
      // 模型還沒下載好、Play Services 不在、或其他原生端錯誤。
      // 一律當「暫時不可用」而不是「壞掉」：未知錯誤「可能是暫時的」比
      // 「你的裝置不行」更接近事實，也給了使用者一個可以做的動作（重試）——
      // 與 MobileScannerService 的 catch-all 是同一個判斷。
      return const RecognitionUnavailable();
    }

    // 只取 TextElement，不用 TextLine／TextBlock：分列分欄由版面解析器
    // 依座標自己做（design D1）。
    final result = OcrResult(elements: [
      for (final block in recognized.blocks)
        for (final line in block.lines)
          for (final element in line.elements)
            OcrTextElement(
              text: element.text,
              bounds: TextBounds(
                left: element.boundingBox.left,
                top: element.boundingBox.top,
                right: element.boundingBox.right,
                bottom: element.boundingBox.bottom,
              ),
              confidence: element.confidence,
            ),
    ]);

    _dumpFixture(result);
    return RecognitionSuccess(result);
  }

  /// 逐行印，而不是一整包 JSON：`debugPrint` 會把長字串折行，
  /// 折行後的 JSON 就 grep 不回來了。
  void _dumpFixture(OcrResult result) {
    if (!kDebugMode) return;
    debugPrint('$fixtureLogTag BEGIN ${result.elements.length}');
    for (final element in result.elements) {
      debugPrint('$fixtureLogTag ${jsonEncode(element.toJson())}');
    }
    debugPrint('$fixtureLogTag END');
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
