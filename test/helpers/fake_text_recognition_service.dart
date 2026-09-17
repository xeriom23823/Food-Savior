import 'package:food_savior/domain/receipt/ocr_result.dart';
import 'package:food_savior/services/ocr/receipt_image_picker.dart';
import 'package:food_savior/services/ocr/text_recognition_service.dart';

/// 測試替身：可以指定辨識結果，所以 bloc_test 不需要 ML Kit、不需要相機。
class FakeTextRecognitionService implements TextRecognitionService {
  FakeTextRecognitionService({
    RecognitionResult? result,
  }) : result = result ?? const RecognitionSuccess(OcrResult(elements: []));

  RecognitionResult result;

  final List<String> recognizedPaths = [];
  bool disposed = false;

  @override
  Future<RecognitionResult> recognize(String imagePath) async {
    recognizedPaths.add(imagePath);
    return result;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

/// 測試替身：可以指定「使用者選了照片／取消／被拒」。
class FakeReceiptImagePicker implements ReceiptImagePicker {
  FakeReceiptImagePicker({
    this.result = const ImagePicked('/tmp/receipt.jpg'),
  });

  ImagePickResult result;

  final List<ReceiptImageSource> requestedSources = [];

  @override
  Future<ImagePickResult> pick(ReceiptImageSource source) async {
    requestedSources.add(source);
    return result;
  }
}
