/// 收據照片從哪來。
enum ReceiptImageSource { camera, gallery }

/// 取得照片的結果。
///
/// 刻意不用例外：使用者按取消、拒絕權限都是**預期中的正常情形**。
sealed class ImagePickResult {
  const ImagePickResult();
}

final class ImagePicked extends ImagePickResult {
  const ImagePicked(this.path);

  /// 照片的暫存路徑。辨識完就可以丟，**不會**被複製到 App 的資料區
  /// （receipt-ocr-import 規格：照片不落地）。
  final String path;
}

/// 使用者在相機或相簿介面按了取消。回到來源選擇，不是錯誤。
final class ImagePickCancelled extends ImagePickResult {
  const ImagePickCancelled();
}

/// 相機或相簿權限被拒。要給「前往設定」與「改為手動新增」兩個出口。
final class ImagePickDenied extends ImagePickResult {
  const ImagePickDenied();
}

/// 取得收據照片的介面。
///
/// 把 `image_picker` 隔離在一個實作檔裡，Bloc 與測試只看到這個介面。
abstract interface class ReceiptImagePicker {
  Future<ImagePickResult> pick(ReceiptImageSource source);
}
