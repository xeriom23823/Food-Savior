import 'package:food_savior/domain/receipt/ocr_result.dart';

/// 文字辨識的結果（design D2）。
///
/// 刻意不用例外：模型還沒下載好是**預期中的正常情形**（動態下載，見
/// `unbundled-scanner-model`），不是程式錯誤。呼叫端必須處理每一種。
sealed class RecognitionResult {
  const RecognitionResult();
}

final class RecognitionSuccess extends RecognitionResult {
  const RecognitionSuccess(this.result);

  final OcrResult result;
}

/// 辨識元件暫時不可用：模型還在由 Play Services 下載、或裝置缺少 Play Services。
///
/// 使用者稍後重試通常就會成功，所以對應的畫面**一定要給重試**。
final class RecognitionUnavailable extends RecognitionResult {
  const RecognitionUnavailable();
}

/// 文字辨識服務介面。
///
/// 存在的唯一理由是把 `google_mlkit_text_recognition` 隔離在一個檔案裡：
/// 版面解析器、Bloc、測試都只看到這個介面與自家的 [OcrResult]，
/// 所以 bloc_test 完全不需要 ML Kit、不需要相機、不需要 widget binding。
///
/// **沒有 `ensureAvailable()`**：ML Kit 沒有「模型是否已就緒」的查詢 API，
/// 只能在 `processImage` 時才知道。design D2 原本畫了這個方法，實作時拿掉。
abstract interface class TextRecognitionService {
  Future<RecognitionResult> recognize(String imagePath);

  Future<void> dispose();
}
