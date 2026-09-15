/// 掃描能不能用，以及不能用的原因。
///
/// 名稱上叫 permission，實際涵蓋的是「掃描為什麼不能用」的所有原因
/// （unbundled-scanner-model D2）。改名要動到 Bloc 狀態與既有測試，
/// 收益只是名稱好看一點，所以留著並在這裡說清楚。
///
/// **每一個值對應一個不同的畫面與不同的出口**，因為使用者能做的事不同。
enum ScannerPermission {
  granted,

  /// 使用者拒絕。要給「前往設定」與「改為手動新增」兩個出口。
  denied,

  /// 裝置沒有可用的相機（模擬器、部分平板）。**不提供重試**——真的沒有相機。
  noCamera,

  /// 條碼解碼元件尚未就緒：模型還在由系統服務下載，或裝置缺少 Play Services。
  ///
  /// 相機是好的，稍後重試通常就會成功，所以**一定要提供重試**。
  /// 把這種情形講成「沒有相機」會讓使用者以為無解而放棄。
  scannerUnavailable,
}

/// 掃描服務介面。
///
/// 存在的唯一理由是把 `mobile_scanner` 隔離在一個檔案裡：Bloc 與測試都只看到
/// 這個介面，所以 bloc_test 完全不需要相機、不需要 widget binding（design D9）。
abstract interface class ScannerService {
  /// 掃到的原始字串。同一個碼可能連續掃到多次，去重是呼叫端的責任。
  Stream<String> get codes;

  Future<ScannerPermission> ensurePermission();

  Future<void> dispose();
}
