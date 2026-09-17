import 'package:flutter/services.dart' show PlatformException;
import 'package:food_savior/services/ocr/receipt_image_picker.dart';
import 'package:image_picker/image_picker.dart';

/// [ReceiptImagePicker] 的實作。**整個專案唯一 import `image_picker` 的檔案**。
///
/// 只需要一張靜態照片，`image_picker` 一個呼叫就給完（含系統相機 UI、
/// Android 13+ 的 Photo Picker）。`camera` 套件要自己管生命週期、預覽、對焦、
/// 旋轉——為了拍一張照片不值得（design D3）。
class ImagePickerReceiptImagePicker implements ReceiptImagePicker {
  ImagePickerReceiptImagePicker({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// 長邊上限。測試機只有 2.64 GiB RAM，原圖加辨識緩衝容易 OOM（design D3）。
  /// 2000px 對收據上的文字仍然綽綽有餘。
  static const double maxWidth = 2000;
  static const double maxHeight = 2000;
  static const int imageQuality = 85;

  @override
  Future<ImagePickResult> pick(ReceiptImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: switch (source) {
          ReceiptImageSource.camera => ImageSource.camera,
          ReceiptImageSource.gallery => ImageSource.gallery,
        },
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        // 不需要 EXIF 位置等中繼資料，少一次權限詢問。
        requestFullMetadata: false,
      );
      if (file == null) return const ImagePickCancelled();
      return ImagePicked(file.path);
    } on PlatformException catch (error) {
      // image_picker 以這兩個 code 表示權限被拒。
      if (error.code == 'camera_access_denied' ||
          error.code == 'photo_access_denied') {
        return const ImagePickDenied();
      }
      // 其他原生端錯誤（相機被別的 App 佔用之類）：回到來源選擇讓使用者再試。
      return const ImagePickCancelled();
    }
  }
}
