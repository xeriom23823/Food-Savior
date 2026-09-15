// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(days) => "開封後 ${days} 天";

  static String m1(count) => "${count} 批";

  static String m2(percent) => "涵蓋率 ${percent}%";

  static String m3(days) => "${days} 天";

  static String m4(count) => "有 ${count} 項食物放在這個位置，刪除後它們會歸為「未指定位置」，食物本身不會被刪除。";

  static String m5(count) => "全部加入（${count}）";

  static String m6(count) => "已匯入 ${count} 項食物";

  static String m7(name) => "發票品名：${name}";

  static String m8(days) => "約 ${days} 天後到期";

  static String m9(days) => "${days} 天後到期";

  static String m10(days) => "已過期 ${days} 天";

  static String m11(count) => "${count} 項";

  static String m12(achieved, total) => "已達成 ${achieved} / ${total}";

  static String m13(points) => "${points} 點";

  static String m14(points) => "距下一級還差 ${points} 點";

  static String m15(amount) => "${amount} 元";

  static String m16(points) => "${points} 點";

  static String m17(count) => "浪費 ${count} 次";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutSection": MessageLookupByLibrary.simpleMessage("關於"),
        "accountSection": MessageLookupByLibrary.simpleMessage("帳號"),
        "add": MessageLookupByLibrary.simpleMessage("新增"),
        "addFoodItem": MessageLookupByLibrary.simpleMessage("新增食物"),
        "addLocation": MessageLookupByLibrary.simpleMessage("新增位置"),
        "addPriceHint": MessageLookupByLibrary.simpleMessage("填寫金額後就能看到這裡的統計"),
        "added": MessageLookupByLibrary.simpleMessage("已新增"),
        "afterOpenDaysLabel": m0,
        "amount": MessageLookupByLibrary.simpleMessage("份量"),
        "amountCannotBeEmpty":
            MessageLookupByLibrary.simpleMessage("請填份量或選剩餘比例"),
        "amountExceedsAvailable":
            MessageLookupByLibrary.simpleMessage("超過現有份量"),
        "amountMustBeANumber": MessageLookupByLibrary.simpleMessage("份量必須是數字"),
        "amountMustBePositive":
            MessageLookupByLibrary.simpleMessage("份量必須大於 0"),
        "backup": MessageLookupByLibrary.simpleMessage("備份"),
        "backupFailure": MessageLookupByLibrary.simpleMessage("備份失敗"),
        "backupSuccess": MessageLookupByLibrary.simpleMessage("資料備份成功"),
        "batchCount": m1,
        "batchUse": MessageLookupByLibrary.simpleMessage("部分處理"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chartAndStatisticsNavigationBarTitle":
            MessageLookupByLibrary.simpleMessage("圖表"),
        "chartAndStatisticsPageTitle": MessageLookupByLibrary.simpleMessage(
          "圖表與統計",
        ),
        "close": MessageLookupByLibrary.simpleMessage("關閉"),
        "confirm": MessageLookupByLibrary.simpleMessage("確認"),
        "confirmPassword": MessageLookupByLibrary.simpleMessage("確認密碼"),
        "consumed": MessageLookupByLibrary.simpleMessage("使用"),
        "consumedAmount": MessageLookupByLibrary.simpleMessage("食用份量"),
        "consumedFoodByType": MessageLookupByLibrary.simpleMessage("食用筆數分布"),
        "coverageLabel": m2,
        "createAccount": MessageLookupByLibrary.simpleMessage("建立帳號"),
        "dailyFoodPointsCapReached": MessageLookupByLibrary.simpleMessage(
          "今天的加分已達上限，休息一下也很好",
        ),
        "darkMode": MessageLookupByLibrary.simpleMessage("黑夜模式"),
        "days": MessageLookupByLibrary.simpleMessage("天"),
        "daysCount": m3,
        "daysSinceLastWaste": MessageLookupByLibrary.simpleMessage("距上次浪費"),
        "defaultLocationAmbient": MessageLookupByLibrary.simpleMessage("常溫"),
        "defaultLocationFrozen": MessageLookupByLibrary.simpleMessage("冷凍"),
        "defaultLocationRefrigerated":
            MessageLookupByLibrary.simpleMessage("冷藏"),
        "delete": MessageLookupByLibrary.simpleMessage("刪除"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("刪除帳號"),
        "deleteAccountFailure": MessageLookupByLibrary.simpleMessage("刪除帳號失敗"),
        "deleteAccountMessage": MessageLookupByLibrary.simpleMessage(
          "帳號與雲端備份會被永久刪除，且無法復原。這台裝置上的食物清單與使用紀錄不會被刪除。",
        ),
        "deleteAccountRequiresRecentLogin":
            MessageLookupByLibrary.simpleMessage(
          "為了安全，請重新登入後再試一次",
        ),
        "deleteLocation": MessageLookupByLibrary.simpleMessage("刪除位置"),
        "deleteLocationMessage": m4,
        "deleted": MessageLookupByLibrary.simpleMessage("已刪除"),
        "description": MessageLookupByLibrary.simpleMessage("描述"),
        "details": MessageLookupByLibrary.simpleMessage("詳細資料"),
        "disposalComposted": MessageLookupByLibrary.simpleMessage("堆肥"),
        "disposalDiscarded": MessageLookupByLibrary.simpleMessage("丟棄"),
        "disposalEaten": MessageLookupByLibrary.simpleMessage("吃掉"),
        "disposalEatenAtRisk": MessageLookupByLibrary.simpleMessage("過期後吃掉"),
        "disposalGivenAway": MessageLookupByLibrary.simpleMessage("送人"),
        "disposalMethod": MessageLookupByLibrary.simpleMessage("處理方式"),
        "edit": MessageLookupByLibrary.simpleMessage("編輯"),
        "editFoodItem": MessageLookupByLibrary.simpleMessage("編輯食物"),
        "editLocation": MessageLookupByLibrary.simpleMessage("編輯位置"),
        "editName": MessageLookupByLibrary.simpleMessage("修改名稱"),
        "einvoiceAlreadyImported": MessageLookupByLibrary.simpleMessage(
          "這張發票已經匯入過了",
        ),
        "einvoiceCameraUnavailable": MessageLookupByLibrary.simpleMessage(
          "這台裝置沒有可用的相機",
        ),
        "einvoiceCodeMismatch": MessageLookupByLibrary.simpleMessage(
          "這是另一張發票的條碼，請掃描同一張的另一側",
        ),
        "einvoiceDraftExclude": MessageLookupByLibrary.simpleMessage("排除這項"),
        "einvoiceDraftExcluded": MessageLookupByLibrary.simpleMessage("已排除"),
        "einvoiceDraftInclude": MessageLookupByLibrary.simpleMessage("加回這項"),
        "einvoiceDraftNeedsReview": MessageLookupByLibrary.simpleMessage("待確認"),
        "einvoiceDraftsSubtitle": MessageLookupByLibrary.simpleMessage(
          "可以逐項修改或排除，確認後再加入清單",
        ),
        "einvoiceDraftsTitle": MessageLookupByLibrary.simpleMessage("確認匯入的食物"),
        "einvoiceEditDraft": MessageLookupByLibrary.simpleMessage("修改這一項"),
        "einvoiceEncodingUnsupported": MessageLookupByLibrary.simpleMessage(
          "這張發票使用的文字編碼無法解讀，請改為手動新增",
        ),
        "einvoiceImportAll": m5,
        "einvoiceImportAnyway": MessageLookupByLibrary.simpleMessage("仍要匯入"),
        "einvoiceImported": m6,
        "einvoiceItemsIncomplete": MessageLookupByLibrary.simpleMessage(
          "發票上還有品項沒讀到，請自行補齊",
        ),
        "einvoiceLeftCodeDone":
            MessageLookupByLibrary.simpleMessage("左側條碼：已取得"),
        "einvoiceLeftCodePending":
            MessageLookupByLibrary.simpleMessage("左側條碼：待掃描"),
        "einvoiceManualEntry": MessageLookupByLibrary.simpleMessage("改為手動新增"),
        "einvoiceNoDrafts":
            MessageLookupByLibrary.simpleMessage("這張發票沒有可匯入的品項"),
        "einvoiceParseFailed": MessageLookupByLibrary.simpleMessage(
          "讀不到發票內容，請再試一次",
        ),
        "einvoicePermissionDenied": MessageLookupByLibrary.simpleMessage(
          "需要相機權限才能掃描發票",
        ),
        "einvoicePermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
          "前往設定",
        ),
        "einvoiceRetry": MessageLookupByLibrary.simpleMessage("重新掃描"),
        "einvoiceRightCodeDone":
            MessageLookupByLibrary.simpleMessage("右側條碼：已取得"),
        "einvoiceRightCodePending": MessageLookupByLibrary.simpleMessage(
          "右側條碼：待掃描",
        ),
        "einvoiceScanEntry": MessageLookupByLibrary.simpleMessage("掃描發票"),
        "einvoiceScanHint":
            MessageLookupByLibrary.simpleMessage("對準發票證明聯上的兩個二維條碼"),
        "einvoiceScanTitle": MessageLookupByLibrary.simpleMessage("掃描電子發票"),
        "einvoiceScannerNotReady": MessageLookupByLibrary.simpleMessage(
          "掃描功能還在準備中，請稍後再試",
        ),
        "einvoiceSourceLine": m7,
        "email": MessageLookupByLibrary.simpleMessage("電子郵件"),
        "emptyFoodListDescription": MessageLookupByLibrary.simpleMessage(
          "用下面那一行輸入名稱，就能記下第一樣食物",
        ),
        "emptyFoodListTitle": MessageLookupByLibrary.simpleMessage("冰箱還空著"),
        "emptyLocationsDescription": MessageLookupByLibrary.simpleMessage(
          "建立「冰箱上層」「儲藏櫃」之類的位置，清單就能依位置分群",
        ),
        "emptyLocationsTitle": MessageLookupByLibrary.simpleMessage("還沒有存放位置"),
        "emptyScoreDescription": MessageLookupByLibrary.simpleMessage(
          "記下食物、吃掉它，點數就會開始累積",
        ),
        "emptyScoreTitle": MessageLookupByLibrary.simpleMessage("還沒有成績可以看"),
        "emptyUsedFoodListDescription": MessageLookupByLibrary.simpleMessage(
          "吃掉或丟掉食物後，紀錄會出現在這裡",
        ),
        "emptyUsedFoodListTitle":
            MessageLookupByLibrary.simpleMessage("這天沒有紀錄"),
        "errorOffline":
            MessageLookupByLibrary.simpleMessage("目前無法連線到雲端，請確認網路後再試"),
        "errorPermissionDenied": MessageLookupByLibrary.simpleMessage(
          "沒有存取雲端資料的權限",
        ),
        "errorTimeout": MessageLookupByLibrary.simpleMessage("連線逾時，請稍後再試"),
        "errorUnknown": MessageLookupByLibrary.simpleMessage("發生未知錯誤"),
        "expirationDate": MessageLookupByLibrary.simpleMessage("到期日期"),
        "expire": MessageLookupByLibrary.simpleMessage("過期"),
        "expireApproximatelyInDays": m8,
        "expireInDays": m9,
        "expireToday": MessageLookupByLibrary.simpleMessage("今日到期"),
        "expired": MessageLookupByLibrary.simpleMessage("已過期"),
        "expiredDaysAgo": m10,
        "expiredFoodListTitle": MessageLookupByLibrary.simpleMessage("過期食物清單"),
        "expiryEarliest": MessageLookupByLibrary.simpleMessage("最早"),
        "expiryLatest": MessageLookupByLibrary.simpleMessage("最晚"),
        "expiryPrecisionExact": MessageLookupByLibrary.simpleMessage("確定日期"),
        "expiryPrecisionMonthOnly":
            MessageLookupByLibrary.simpleMessage("只到月份"),
        "expiryPrecisionRange": MessageLookupByLibrary.simpleMessage("大約區間"),
        "expiryPrecisionUnknown": MessageLookupByLibrary.simpleMessage("不知道"),
        "expiryQuickOneMonth": MessageLookupByLibrary.simpleMessage("1 個月後"),
        "expiryQuickOneWeek": MessageLookupByLibrary.simpleMessage("1 週後"),
        "expiryQuickThreeDays": MessageLookupByLibrary.simpleMessage("3 天後"),
        "expiryQuickToday": MessageLookupByLibrary.simpleMessage("今天"),
        "expiryQuickTomorrow": MessageLookupByLibrary.simpleMessage("明天"),
        "expiryQuickTwoWeeks": MessageLookupByLibrary.simpleMessage("2 週後"),
        "expiryRangeInvalid":
            MessageLookupByLibrary.simpleMessage("最晚日期不能早於最早日期"),
        "expiryUnknown": MessageLookupByLibrary.simpleMessage("期限未知"),
        "fillExpiry": MessageLookupByLibrary.simpleMessage("補期限"),
        "filterAll": MessageLookupByLibrary.simpleMessage("全部"),
        "filterConsumed": MessageLookupByLibrary.simpleMessage("食用"),
        "filterWasted": MessageLookupByLibrary.simpleMessage("浪費"),
        "foodInfo": MessageLookupByLibrary.simpleMessage("食物資訊"),
        "foodItemListError": MessageLookupByLibrary.simpleMessage("載入失敗，請重試"),
        "foodItemListNavigationBarTitle": MessageLookupByLibrary.simpleMessage(
          "食物",
        ),
        "foodItemListViewTitle": MessageLookupByLibrary.simpleMessage("食物清單"),
        "foodItemStatusConsumed": MessageLookupByLibrary.simpleMessage("已使用"),
        "foodItemStatusExpired": MessageLookupByLibrary.simpleMessage("已過期"),
        "foodItemStatusFresh": MessageLookupByLibrary.simpleMessage("新鮮"),
        "foodItemStatusNearExpired":
            MessageLookupByLibrary.simpleMessage("快過期"),
        "foodItemStatusUnknownExpiry":
            MessageLookupByLibrary.simpleMessage("期限未知"),
        "foodItemStatusWasted": MessageLookupByLibrary.simpleMessage("已浪費"),
        "foodItemTypeBread": MessageLookupByLibrary.simpleMessage("麵包"),
        "foodItemTypeCannedFood": MessageLookupByLibrary.simpleMessage("罐頭"),
        "foodItemTypeCookedFood": MessageLookupByLibrary.simpleMessage("熟食"),
        "foodItemTypeDrink": MessageLookupByLibrary.simpleMessage("飲料"),
        "foodItemTypeEggAndMilk": MessageLookupByLibrary.simpleMessage("蛋奶類"),
        "foodItemTypeFruit": MessageLookupByLibrary.simpleMessage("水果"),
        "foodItemTypeMeat": MessageLookupByLibrary.simpleMessage("肉類"),
        "foodItemTypeOthers": MessageLookupByLibrary.simpleMessage("其他"),
        "foodItemTypeSeafood": MessageLookupByLibrary.simpleMessage("海鮮"),
        "foodItemTypeSnack": MessageLookupByLibrary.simpleMessage("零食"),
        "foodItemTypeVegetable": MessageLookupByLibrary.simpleMessage("蔬菜"),
        "foodPoints": MessageLookupByLibrary.simpleMessage("食物點數"),
        "foodType": MessageLookupByLibrary.simpleMessage("類型"),
        "forgotPassword": MessageLookupByLibrary.simpleMessage("忘記密碼？"),
        "goToFoodList": MessageLookupByLibrary.simpleMessage("去記第一樣食物"),
        "groupByLocation": MessageLookupByLibrary.simpleMessage("依存放位置"),
        "groupByType": MessageLookupByLibrary.simpleMessage("依食物類型"),
        "groupByUrgency": MessageLookupByLibrary.simpleMessage("依到期急迫度"),
        "grouping": MessageLookupByLibrary.simpleMessage("分群"),
        "invalidEmail": MessageLookupByLibrary.simpleMessage("無效的電子郵件"),
        "invalidPassword": MessageLookupByLibrary.simpleMessage("無效的密碼"),
        "isConsumed": MessageLookupByLibrary.simpleMessage("已食用"),
        "itemCount": m11,
        "language": MessageLookupByLibrary.simpleMessage("語言"),
        "levelGuardianName": MessageLookupByLibrary.simpleMessage("食物守護者"),
        "levelKeeperName": MessageLookupByLibrary.simpleMessage("冰箱管理員"),
        "levelMasterName": MessageLookupByLibrary.simpleMessage("零浪費大師"),
        "levelNoviceName": MessageLookupByLibrary.simpleMessage("食物見習生"),
        "levelSaverName": MessageLookupByLibrary.simpleMessage("惜食者"),
        "locationKindAmbient": MessageLookupByLibrary.simpleMessage("常溫"),
        "locationKindFrozen": MessageLookupByLibrary.simpleMessage("冷凍"),
        "locationKindOther": MessageLookupByLibrary.simpleMessage("其他"),
        "locationKindRefrigerated": MessageLookupByLibrary.simpleMessage("冷藏"),
        "locationNameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
          "位置名稱不能為空",
        ),
        "logIn": MessageLookupByLibrary.simpleMessage("登入"),
        "logInFailure": MessageLookupByLibrary.simpleMessage("登入失敗"),
        "logOut": MessageLookupByLibrary.simpleMessage("登出"),
        "loginPageTitle": MessageLookupByLibrary.simpleMessage("登入頁面"),
        "loginWelcome": MessageLookupByLibrary.simpleMessage("歡迎回來"),
        "markOpened": MessageLookupByLibrary.simpleMessage("標記開封"),
        "maxLevelReached": MessageLookupByLibrary.simpleMessage("已達最高等級"),
        "milestoneFirstRecordCondition": MessageLookupByLibrary.simpleMessage(
          "記下第一樣食物",
        ),
        "milestoneFirstRecordName":
            MessageLookupByLibrary.simpleMessage("踏出第一步"),
        "milestoneFiveHundredPointsCondition":
            MessageLookupByLibrary.simpleMessage(
          "累計 500 點",
        ),
        "milestoneFiveHundredPointsName": MessageLookupByLibrary.simpleMessage(
          "五百俱樂部",
        ),
        "milestoneHundredPointsCondition": MessageLookupByLibrary.simpleMessage(
          "累計 100 點",
        ),
        "milestoneHundredPointsName":
            MessageLookupByLibrary.simpleMessage("百分達成"),
        "milestoneMonthWithoutWasteCondition":
            MessageLookupByLibrary.simpleMessage(
          "連續 30 天沒有浪費",
        ),
        "milestoneMonthWithoutWasteName": MessageLookupByLibrary.simpleMessage(
          "一個月零浪費",
        ),
        "milestoneProgress": m12,
        "milestoneTenRescuesCondition": MessageLookupByLibrary.simpleMessage(
          "在到期前 3 天內用掉 10 樣食物",
        ),
        "milestoneTenRescuesName":
            MessageLookupByLibrary.simpleMessage("即期救援隊"),
        "milestoneWeekWithoutWasteCondition":
            MessageLookupByLibrary.simpleMessage(
          "連續 7 天沒有浪費",
        ),
        "milestoneWeekWithoutWasteName": MessageLookupByLibrary.simpleMessage(
          "一週零浪費",
        ),
        "milestones": MessageLookupByLibrary.simpleMessage("里程碑"),
        "moneyLost": MessageLookupByLibrary.simpleMessage("浪費"),
        "moneySaved": MessageLookupByLibrary.simpleMessage("救回"),
        "monthlyTrend": MessageLookupByLibrary.simpleMessage("每月趨勢"),
        "myScore": MessageLookupByLibrary.simpleMessage("我的成績"),
        "name": MessageLookupByLibrary.simpleMessage("名稱"),
        "nameCannotBeEmpty": MessageLookupByLibrary.simpleMessage("名稱不能為空"),
        "nameTooLong": MessageLookupByLibrary.simpleMessage("名稱不能超過 30 個字"),
        "nameUpdateFailure": MessageLookupByLibrary.simpleMessage("名稱更新失敗"),
        "nameUpdated": MessageLookupByLibrary.simpleMessage("名稱已更新"),
        "noAccountYet": MessageLookupByLibrary.simpleMessage("還沒有帳號？"),
        "noData": MessageLookupByLibrary.simpleMessage("尚無資料"),
        "noLocation": MessageLookupByLibrary.simpleMessage("未指定位置"),
        "noWasteReason": MessageLookupByLibrary.simpleMessage("未填原因"),
        "openSource": MessageLookupByLibrary.simpleMessage("開放原始碼"),
        "opened": MessageLookupByLibrary.simpleMessage("已開封"),
        "openedDate": MessageLookupByLibrary.simpleMessage("開封日期"),
        "password": MessageLookupByLibrary.simpleMessage("密碼"),
        "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage("密碼不相符"),
        "pendingExpiry": MessageLookupByLibrary.simpleMessage("待補期限"),
        "pointsLabel": m13,
        "pointsRuleChanged": MessageLookupByLibrary.simpleMessage(
          "點數規則自 2026-09-15 起改為依時效加權",
        ),
        "pointsToNextLevel": m14,
        "price": MessageLookupByLibrary.simpleMessage("金額（元）"),
        "priceLabel": m15,
        "priceMustBeNonNegative": MessageLookupByLibrary.simpleMessage(
          "金額必須是 0 或正整數",
        ),
        "priceOptional": MessageLookupByLibrary.simpleMessage("選填"),
        "processComplete": MessageLookupByLibrary.simpleMessage("處理完成"),
        "quickAdd": MessageLookupByLibrary.simpleMessage("快速新增"),
        "quickAddHint": MessageLookupByLibrary.simpleMessage("輸入名稱就能存，細節之後再補"),
        "recordByAmount": MessageLookupByLibrary.simpleMessage("改用數量"),
        "recordByFraction": MessageLookupByLibrary.simpleMessage("改用剩餘比例"),
        "refresh": MessageLookupByLibrary.simpleMessage("重新整理"),
        "remaining": MessageLookupByLibrary.simpleMessage("剩餘"),
        "remainingFractionAlmostGone":
            MessageLookupByLibrary.simpleMessage("剩一點"),
        "remainingFractionFull": MessageLookupByLibrary.simpleMessage("滿的"),
        "remainingFractionHalf": MessageLookupByLibrary.simpleMessage("約一半"),
        "remainingFractionLow": MessageLookupByLibrary.simpleMessage("不多了"),
        "remainingFractionMostly": MessageLookupByLibrary.simpleMessage("大部分"),
        "resetPassword": MessageLookupByLibrary.simpleMessage("重設密碼"),
        "resetPasswordFailure": MessageLookupByLibrary.simpleMessage("無法寄出重設信"),
        "resetPasswordSent": MessageLookupByLibrary.simpleMessage(
          "重設密碼的信已寄出，請到信箱查看",
        ),
        "restore": MessageLookupByLibrary.simpleMessage("還原"),
        "restoreFailure": MessageLookupByLibrary.simpleMessage("還原失敗"),
        "restoreNoBackup":
            MessageLookupByLibrary.simpleMessage("雲端沒有備份，本機資料未變動"),
        "restoreSuccess": MessageLookupByLibrary.simpleMessage("資料還原成功"),
        "save": MessageLookupByLibrary.simpleMessage("儲存"),
        "setName": MessageLookupByLibrary.simpleMessage("設定名稱"),
        "settingsNavigationBarTitle":
            MessageLookupByLibrary.simpleMessage("設定"),
        "settingsPageTitle": MessageLookupByLibrary.simpleMessage("設定頁面"),
        "settingsSection": MessageLookupByLibrary.simpleMessage("偏好設定"),
        "shelfLifeAfterOpen": MessageLookupByLibrary.simpleMessage("開封後可放（天）"),
        "showNotification": MessageLookupByLibrary.simpleMessage("顯示通知"),
        "signInWithGoogle":
            MessageLookupByLibrary.simpleMessage("使用 Google 登入"),
        "signUp": MessageLookupByLibrary.simpleMessage("註冊"),
        "signUpFailure": MessageLookupByLibrary.simpleMessage("註冊失敗"),
        "signUpPageTitle": MessageLookupByLibrary.simpleMessage("註冊頁面"),
        "signUpWelcome": MessageLookupByLibrary.simpleMessage("建立你的帳號"),
        "signedPoints": m16,
        "skip": MessageLookupByLibrary.simpleMessage("略過"),
        "statisticsMoney": MessageLookupByLibrary.simpleMessage("金額損益"),
        "statisticsTopWasted": MessageLookupByLibrary.simpleMessage("最常浪費的食物"),
        "statisticsWasteRate": MessageLookupByLibrary.simpleMessage("浪費率趨勢"),
        "statisticsWasteReasons":
            MessageLookupByLibrary.simpleMessage("浪費原因分佈"),
        "storageDate": MessageLookupByLibrary.simpleMessage("存放日期"),
        "storageLocation": MessageLookupByLibrary.simpleMessage("存放位置"),
        "storageLocations": MessageLookupByLibrary.simpleMessage("存放位置"),
        "title": MessageLookupByLibrary.simpleMessage("食物救世主"),
        "totalPoints": MessageLookupByLibrary.simpleMessage("累計點數"),
        "unit": MessageLookupByLibrary.simpleMessage("單位"),
        "unitBag": MessageLookupByLibrary.simpleMessage("袋"),
        "unitBottle": MessageLookupByLibrary.simpleMessage("瓶"),
        "unitBox": MessageLookupByLibrary.simpleMessage("盒"),
        "unitCan": MessageLookupByLibrary.simpleMessage("罐"),
        "unitCannotBeEmpty": MessageLookupByLibrary.simpleMessage("請選擇單位"),
        "unitGram": MessageLookupByLibrary.simpleMessage("公克"),
        "unitMilliliter": MessageLookupByLibrary.simpleMessage("毫升"),
        "unitPack": MessageLookupByLibrary.simpleMessage("包"),
        "unitPiece": MessageLookupByLibrary.simpleMessage("個"),
        "unitServing": MessageLookupByLibrary.simpleMessage("份"),
        "updated": MessageLookupByLibrary.simpleMessage("已更新"),
        "urgencyExpired": MessageLookupByLibrary.simpleMessage("已過期"),
        "urgencyPlenty": MessageLookupByLibrary.simpleMessage("充裕"),
        "urgencyToday": MessageLookupByLibrary.simpleMessage("今天到期"),
        "urgencyUnknownExpiry": MessageLookupByLibrary.simpleMessage("期限未知"),
        "urgencyWithinThreeDays": MessageLookupByLibrary.simpleMessage("3 天內"),
        "urgencyWithinWeek": MessageLookupByLibrary.simpleMessage("一週內"),
        "use": MessageLookupByLibrary.simpleMessage("使用"),
        "useAll": MessageLookupByLibrary.simpleMessage("全部使用"),
        "useFoodItem": MessageLookupByLibrary.simpleMessage("使用食物"),
        "usedDate": MessageLookupByLibrary.simpleMessage("使用日期"),
        "usedFoodItemListNavigationBarTitle":
            MessageLookupByLibrary.simpleMessage(
          "紀錄",
        ),
        "userNavigationBarTitle": MessageLookupByLibrary.simpleMessage("用戶"),
        "userPageTitle": MessageLookupByLibrary.simpleMessage("我的"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "viewOnGitHub": MessageLookupByLibrary.simpleMessage("在 GitHub 上查看"),
        "waste": MessageLookupByLibrary.simpleMessage("丟棄"),
        "wasteReason": MessageLookupByLibrary.simpleMessage("浪費原因"),
        "wasteReasonBoughtTooMuch": MessageLookupByLibrary.simpleMessage("買太多"),
        "wasteReasonDisliked": MessageLookupByLibrary.simpleMessage("不好吃"),
        "wasteReasonExpiredTooLong":
            MessageLookupByLibrary.simpleMessage("放到過期太久"),
        "wasteReasonForgotten": MessageLookupByLibrary.simpleMessage("忘記吃"),
        "wasteReasonOther": MessageLookupByLibrary.simpleMessage("其他"),
        "wasteReasonSpoiled": MessageLookupByLibrary.simpleMessage("壞掉了"),
        "wasted": MessageLookupByLibrary.simpleMessage("浪費"),
        "wastedAmount": MessageLookupByLibrary.simpleMessage("丟棄份量"),
        "wastedCountLabel": m17,
        "wastedFoodByType": MessageLookupByLibrary.simpleMessage("浪費筆數分布"),
        "weeklyNet": MessageLookupByLibrary.simpleMessage("本週"),
      };
}
