// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(days) => "${days} days after opening";

  static String m1(count) => "${count} batches";

  static String m2(percent) => "${percent}% of records";

  static String m3(days) => "${days} days";

  static String m4(count) =>
      "${count} items are stored here. They will move to \"No location\" instead of being deleted.";

  static String m5(count) => "Add all (${count})";

  static String m6(count) => "Imported ${count} items";

  static String m7(name) => "On receipt: ${name}";

  static String m8(days) => "Expires in about ${days} days";

  static String m9(days) => "Expires in ${days} days";

  static String m10(days) => "Expired ${days} days ago";

  static String m11(count) => "${count} items";

  static String m12(achieved, total) => "${achieved} of ${total} unlocked";

  static String m13(points) => "${points} pts";

  static String m14(points) => "${points} points to the next level";

  static String m15(amount) => "NT\$${amount}";

  static String m16(points) => "${points} pts";

  static String m17(count) => "wasted ${count} times";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutSection": MessageLookupByLibrary.simpleMessage("About"),
        "accountSection": MessageLookupByLibrary.simpleMessage("Account"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addFoodItem": MessageLookupByLibrary.simpleMessage("Add food"),
        "addLocation": MessageLookupByLibrary.simpleMessage("Add location"),
        "addPriceHint": MessageLookupByLibrary.simpleMessage(
          "Add prices to your food to see this",
        ),
        "added": MessageLookupByLibrary.simpleMessage("Added"),
        "afterOpenDaysLabel": m0,
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "amountCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
          "Enter an amount or pick how much is left",
        ),
        "amountExceedsAvailable": MessageLookupByLibrary.simpleMessage(
          "More than what is left",
        ),
        "amountMustBeANumber": MessageLookupByLibrary.simpleMessage(
          "Amount must be a number",
        ),
        "amountMustBePositive": MessageLookupByLibrary.simpleMessage(
          "Amount must be greater than 0",
        ),
        "backup": MessageLookupByLibrary.simpleMessage("Back up"),
        "backupFailure": MessageLookupByLibrary.simpleMessage("Backup failed"),
        "backupSuccess":
            MessageLookupByLibrary.simpleMessage("Backup complete"),
        "batchCount": m1,
        "batchUse": MessageLookupByLibrary.simpleMessage("Partial"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chartAndStatisticsNavigationBarTitle":
            MessageLookupByLibrary.simpleMessage("Charts"),
        "chartAndStatisticsPageTitle": MessageLookupByLibrary.simpleMessage(
          "Charts & stats",
        ),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm password"),
        "consumed": MessageLookupByLibrary.simpleMessage("Eaten"),
        "consumedAmount": MessageLookupByLibrary.simpleMessage("Eaten"),
        "consumedFoodByType":
            MessageLookupByLibrary.simpleMessage("Eaten by type"),
        "coverageLabel": m2,
        "createAccount": MessageLookupByLibrary.simpleMessage("Create account"),
        "dailyFoodPointsCapReached": MessageLookupByLibrary.simpleMessage(
          "Today\'s points are full; taking a break is okay too",
        ),
        "darkMode": MessageLookupByLibrary.simpleMessage("Dark mode"),
        "days": MessageLookupByLibrary.simpleMessage("days"),
        "daysCount": m3,
        "daysSinceLastWaste": MessageLookupByLibrary.simpleMessage(
          "Since last waste",
        ),
        "defaultLocationAmbient":
            MessageLookupByLibrary.simpleMessage("Pantry"),
        "defaultLocationFrozen":
            MessageLookupByLibrary.simpleMessage("Freezer"),
        "defaultLocationRefrigerated": MessageLookupByLibrary.simpleMessage(
          "Fridge",
        ),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete account"),
        "deleteAccountFailure": MessageLookupByLibrary.simpleMessage(
          "Could not delete the account",
        ),
        "deleteAccountMessage": MessageLookupByLibrary.simpleMessage(
          "Your account and cloud backup will be permanently deleted and cannot be recovered. The food list and history on this device are not deleted.",
        ),
        "deleteAccountRequiresRecentLogin":
            MessageLookupByLibrary.simpleMessage(
          "For your security, sign in again and retry",
        ),
        "deleteLocation":
            MessageLookupByLibrary.simpleMessage("Delete location"),
        "deleteLocationMessage": m4,
        "deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
        "description": MessageLookupByLibrary.simpleMessage("Notes"),
        "details": MessageLookupByLibrary.simpleMessage("Details"),
        "disposalComposted": MessageLookupByLibrary.simpleMessage("Composted"),
        "disposalDiscarded":
            MessageLookupByLibrary.simpleMessage("Threw it out"),
        "disposalEaten": MessageLookupByLibrary.simpleMessage("Ate it"),
        "disposalEatenAtRisk": MessageLookupByLibrary.simpleMessage(
          "Ate it past date",
        ),
        "disposalGivenAway":
            MessageLookupByLibrary.simpleMessage("Gave it away"),
        "disposalMethod": MessageLookupByLibrary.simpleMessage("What happened"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editFoodItem": MessageLookupByLibrary.simpleMessage("Edit food"),
        "editLocation": MessageLookupByLibrary.simpleMessage("Edit location"),
        "editName": MessageLookupByLibrary.simpleMessage("Edit name"),
        "einvoiceAlreadyImported": MessageLookupByLibrary.simpleMessage(
          "You have already imported this receipt",
        ),
        "einvoiceCameraUnavailable": MessageLookupByLibrary.simpleMessage(
          "No camera is available on this device",
        ),
        "einvoiceCodeMismatch": MessageLookupByLibrary.simpleMessage(
          "That code belongs to a different receipt. Scan the other side of the same one.",
        ),
        "einvoiceDraftExclude": MessageLookupByLibrary.simpleMessage("Exclude"),
        "einvoiceDraftExcluded":
            MessageLookupByLibrary.simpleMessage("Excluded"),
        "einvoiceDraftInclude": MessageLookupByLibrary.simpleMessage("Include"),
        "einvoiceDraftNeedsReview": MessageLookupByLibrary.simpleMessage(
          "Check this",
        ),
        "einvoiceDraftsSubtitle": MessageLookupByLibrary.simpleMessage(
          "Edit or exclude any row before adding them to your list",
        ),
        "einvoiceDraftsTitle": MessageLookupByLibrary.simpleMessage(
          "Confirm what to import",
        ),
        "einvoiceEditDraft":
            MessageLookupByLibrary.simpleMessage("Edit this item"),
        "einvoiceEncodingUnsupported": MessageLookupByLibrary.simpleMessage(
          "This receipt uses a text encoding we cannot read. Please add the items manually.",
        ),
        "einvoiceImportAll": m5,
        "einvoiceImportAnyway": MessageLookupByLibrary.simpleMessage(
          "Import anyway",
        ),
        "einvoiceImported": m6,
        "einvoiceItemsIncomplete": MessageLookupByLibrary.simpleMessage(
          "Some items on the receipt were not read. Please add them yourself.",
        ),
        "einvoiceLeftCodeDone": MessageLookupByLibrary.simpleMessage(
          "Left code: captured",
        ),
        "einvoiceLeftCodePending": MessageLookupByLibrary.simpleMessage(
          "Left code: not scanned",
        ),
        "einvoiceManualEntry": MessageLookupByLibrary.simpleMessage(
          "Add manually instead",
        ),
        "einvoiceNoDrafts": MessageLookupByLibrary.simpleMessage(
          "This receipt has no items to import",
        ),
        "einvoiceParseFailed": MessageLookupByLibrary.simpleMessage(
          "Could not read the receipt. Try again.",
        ),
        "einvoicePermissionDenied": MessageLookupByLibrary.simpleMessage(
          "Camera access is needed to scan receipts",
        ),
        "einvoicePermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
          "Open settings",
        ),
        "einvoiceRetry": MessageLookupByLibrary.simpleMessage("Scan again"),
        "einvoiceRightCodeDone": MessageLookupByLibrary.simpleMessage(
          "Right code: captured",
        ),
        "einvoiceRightCodePending": MessageLookupByLibrary.simpleMessage(
          "Right code: not scanned",
        ),
        "einvoiceScanEntry":
            MessageLookupByLibrary.simpleMessage("Scan receipt"),
        "einvoiceScanHint": MessageLookupByLibrary.simpleMessage(
          "Point the camera at both QR codes on the receipt",
        ),
        "einvoiceScanTitle":
            MessageLookupByLibrary.simpleMessage("Scan e-invoice"),
        "einvoiceScannerNotReady": MessageLookupByLibrary.simpleMessage(
          "The scanner is still getting ready. Try again in a moment.",
        ),
        "einvoiceSourceLine": m7,
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "emptyFoodListDescription": MessageLookupByLibrary.simpleMessage(
          "Type a name in the bar below to add your first item",
        ),
        "emptyFoodListTitle": MessageLookupByLibrary.simpleMessage(
          "Nothing in here yet",
        ),
        "emptyLocationsDescription": MessageLookupByLibrary.simpleMessage(
          "Add places like \"Top shelf\" or \"Pantry\" to group your food by where it is",
        ),
        "emptyLocationsTitle": MessageLookupByLibrary.simpleMessage(
          "No locations yet",
        ),
        "emptyScoreDescription": MessageLookupByLibrary.simpleMessage(
          "Log some food and eat it — points start adding up",
        ),
        "emptyScoreTitle": MessageLookupByLibrary.simpleMessage(
          "Nothing to show yet",
        ),
        "emptyUsedFoodListDescription": MessageLookupByLibrary.simpleMessage(
          "Records show up here after you eat or throw out food",
        ),
        "emptyUsedFoodListTitle": MessageLookupByLibrary.simpleMessage(
          "Nothing on this day",
        ),
        "errorOffline": MessageLookupByLibrary.simpleMessage(
          "Can\'t reach the cloud, check your connection",
        ),
        "errorPermissionDenied": MessageLookupByLibrary.simpleMessage(
          "No permission to access cloud data",
        ),
        "errorTimeout": MessageLookupByLibrary.simpleMessage(
          "Timed out, please try again",
        ),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
          "Something went wrong",
        ),
        "expirationDate": MessageLookupByLibrary.simpleMessage("Use by"),
        "expire": MessageLookupByLibrary.simpleMessage("Expire"),
        "expireApproximatelyInDays": m8,
        "expireInDays": m9,
        "expireToday": MessageLookupByLibrary.simpleMessage("Expires today"),
        "expired": MessageLookupByLibrary.simpleMessage("Expired"),
        "expiredDaysAgo": m10,
        "expiredFoodListTitle": MessageLookupByLibrary.simpleMessage(
          "Expired food",
        ),
        "expiryEarliest": MessageLookupByLibrary.simpleMessage("Earliest"),
        "expiryLatest": MessageLookupByLibrary.simpleMessage("Latest"),
        "expiryPrecisionExact":
            MessageLookupByLibrary.simpleMessage("Exact date"),
        "expiryPrecisionMonthOnly": MessageLookupByLibrary.simpleMessage(
          "Month only",
        ),
        "expiryPrecisionRange":
            MessageLookupByLibrary.simpleMessage("Rough range"),
        "expiryPrecisionUnknown": MessageLookupByLibrary.simpleMessage(
          "Don\'t know",
        ),
        "expiryQuickOneMonth":
            MessageLookupByLibrary.simpleMessage("In 1 month"),
        "expiryQuickOneWeek": MessageLookupByLibrary.simpleMessage("In 1 week"),
        "expiryQuickThreeDays":
            MessageLookupByLibrary.simpleMessage("In 3 days"),
        "expiryQuickToday": MessageLookupByLibrary.simpleMessage("Today"),
        "expiryQuickTomorrow": MessageLookupByLibrary.simpleMessage("Tomorrow"),
        "expiryQuickTwoWeeks":
            MessageLookupByLibrary.simpleMessage("In 2 weeks"),
        "expiryRangeInvalid": MessageLookupByLibrary.simpleMessage(
          "Latest date cannot be before the earliest",
        ),
        "expiryUnknown": MessageLookupByLibrary.simpleMessage("No date"),
        "fillExpiry": MessageLookupByLibrary.simpleMessage("Add date"),
        "filterAll": MessageLookupByLibrary.simpleMessage("All"),
        "filterConsumed": MessageLookupByLibrary.simpleMessage("Eaten"),
        "filterWasted": MessageLookupByLibrary.simpleMessage("Wasted"),
        "foodInfo": MessageLookupByLibrary.simpleMessage("Food info"),
        "foodItemListError": MessageLookupByLibrary.simpleMessage(
          "Failed to load, please retry",
        ),
        "foodItemListNavigationBarTitle": MessageLookupByLibrary.simpleMessage(
          "Food",
        ),
        "foodItemListViewTitle":
            MessageLookupByLibrary.simpleMessage("Food list"),
        "foodItemStatusConsumed": MessageLookupByLibrary.simpleMessage("Eaten"),
        "foodItemStatusExpired":
            MessageLookupByLibrary.simpleMessage("Expired"),
        "foodItemStatusFresh": MessageLookupByLibrary.simpleMessage("Fresh"),
        "foodItemStatusNearExpired": MessageLookupByLibrary.simpleMessage(
          "Expiring",
        ),
        "foodItemStatusUnknownExpiry": MessageLookupByLibrary.simpleMessage(
          "No date",
        ),
        "foodItemStatusWasted": MessageLookupByLibrary.simpleMessage("Wasted"),
        "foodItemTypeBread": MessageLookupByLibrary.simpleMessage("Bread"),
        "foodItemTypeCannedFood":
            MessageLookupByLibrary.simpleMessage("Canned"),
        "foodItemTypeCookedFood":
            MessageLookupByLibrary.simpleMessage("Cooked"),
        "foodItemTypeDrink": MessageLookupByLibrary.simpleMessage("Drink"),
        "foodItemTypeEggAndMilk": MessageLookupByLibrary.simpleMessage(
          "Egg & Dairy",
        ),
        "foodItemTypeFruit": MessageLookupByLibrary.simpleMessage("Fruit"),
        "foodItemTypeMeat": MessageLookupByLibrary.simpleMessage("Meat"),
        "foodItemTypeOthers": MessageLookupByLibrary.simpleMessage("Other"),
        "foodItemTypeSeafood": MessageLookupByLibrary.simpleMessage("Seafood"),
        "foodItemTypeSnack": MessageLookupByLibrary.simpleMessage("Snack"),
        "foodItemTypeVegetable":
            MessageLookupByLibrary.simpleMessage("Vegetable"),
        "foodPoints": MessageLookupByLibrary.simpleMessage("Food points"),
        "foodType": MessageLookupByLibrary.simpleMessage("Type"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot password?"),
        "goToFoodList":
            MessageLookupByLibrary.simpleMessage("Log your first item"),
        "groupByLocation": MessageLookupByLibrary.simpleMessage("Where it is"),
        "groupByType": MessageLookupByLibrary.simpleMessage("Food type"),
        "groupByUrgency": MessageLookupByLibrary.simpleMessage(
          "How soon it expires",
        ),
        "grouping": MessageLookupByLibrary.simpleMessage("Group by"),
        "invalidEmail": MessageLookupByLibrary.simpleMessage("Invalid email"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Invalid password"),
        "isConsumed": MessageLookupByLibrary.simpleMessage("Eaten"),
        "itemCount": m11,
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "levelGuardianName":
            MessageLookupByLibrary.simpleMessage("Food guardian"),
        "levelKeeperName":
            MessageLookupByLibrary.simpleMessage("Fridge keeper"),
        "levelMasterName": MessageLookupByLibrary.simpleMessage(
          "Zero-waste master",
        ),
        "levelNoviceName": MessageLookupByLibrary.simpleMessage("Rookie"),
        "levelSaverName": MessageLookupByLibrary.simpleMessage("Food saver"),
        "locationKindAmbient": MessageLookupByLibrary.simpleMessage("Pantry"),
        "locationKindFrozen": MessageLookupByLibrary.simpleMessage("Freezer"),
        "locationKindOther": MessageLookupByLibrary.simpleMessage("Other"),
        "locationKindRefrigerated":
            MessageLookupByLibrary.simpleMessage("Fridge"),
        "locationNameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
          "Location name cannot be empty",
        ),
        "logIn": MessageLookupByLibrary.simpleMessage("Log in"),
        "logInFailure": MessageLookupByLibrary.simpleMessage("Log in failed"),
        "logOut": MessageLookupByLibrary.simpleMessage("Log out"),
        "loginPageTitle": MessageLookupByLibrary.simpleMessage("Log in"),
        "loginWelcome": MessageLookupByLibrary.simpleMessage("Welcome back"),
        "markOpened": MessageLookupByLibrary.simpleMessage("Mark as opened"),
        "maxLevelReached": MessageLookupByLibrary.simpleMessage(
          "Top level reached",
        ),
        "milestoneFirstRecordCondition": MessageLookupByLibrary.simpleMessage(
          "Log your first item",
        ),
        "milestoneFirstRecordName": MessageLookupByLibrary.simpleMessage(
          "First step",
        ),
        "milestoneFiveHundredPointsCondition":
            MessageLookupByLibrary.simpleMessage(
          "Reach 500 points",
        ),
        "milestoneFiveHundredPointsName": MessageLookupByLibrary.simpleMessage(
          "500 club",
        ),
        "milestoneHundredPointsCondition": MessageLookupByLibrary.simpleMessage(
          "Reach 100 points",
        ),
        "milestoneHundredPointsName": MessageLookupByLibrary.simpleMessage(
          "Century",
        ),
        "milestoneMonthWithoutWasteCondition":
            MessageLookupByLibrary.simpleMessage(
          "30 days without wasting anything",
        ),
        "milestoneMonthWithoutWasteName": MessageLookupByLibrary.simpleMessage(
          "A month, no waste",
        ),
        "milestoneProgress": m12,
        "milestoneTenRescuesCondition": MessageLookupByLibrary.simpleMessage(
          "Use up 10 items within 3 days of expiry",
        ),
        "milestoneTenRescuesName": MessageLookupByLibrary.simpleMessage(
          "Rescue squad",
        ),
        "milestoneWeekWithoutWasteCondition":
            MessageLookupByLibrary.simpleMessage(
          "7 days without wasting anything",
        ),
        "milestoneWeekWithoutWasteName": MessageLookupByLibrary.simpleMessage(
          "A week, no waste",
        ),
        "milestones": MessageLookupByLibrary.simpleMessage("Milestones"),
        "moneyLost": MessageLookupByLibrary.simpleMessage("Lost"),
        "moneySaved": MessageLookupByLibrary.simpleMessage("Saved"),
        "monthlyTrend": MessageLookupByLibrary.simpleMessage("Monthly trend"),
        "myScore": MessageLookupByLibrary.simpleMessage("My progress"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
          "Name cannot be empty",
        ),
        "nameTooLong": MessageLookupByLibrary.simpleMessage(
          "Name cannot be longer than 30 characters",
        ),
        "nameUpdateFailure": MessageLookupByLibrary.simpleMessage(
          "Could not update the name",
        ),
        "nameUpdated": MessageLookupByLibrary.simpleMessage("Name updated"),
        "noAccountYet": MessageLookupByLibrary.simpleMessage("No account yet?"),
        "noData": MessageLookupByLibrary.simpleMessage("No data yet"),
        "noLocation": MessageLookupByLibrary.simpleMessage("No location"),
        "noWasteReason":
            MessageLookupByLibrary.simpleMessage("No reason given"),
        "openSource": MessageLookupByLibrary.simpleMessage("Open source"),
        "opened": MessageLookupByLibrary.simpleMessage("Opened"),
        "openedDate": MessageLookupByLibrary.simpleMessage("Opened on"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
          "Passwords do not match",
        ),
        "pendingExpiry": MessageLookupByLibrary.simpleMessage("Needs a date"),
        "pointsLabel": m13,
        "pointsRuleChanged": MessageLookupByLibrary.simpleMessage(
          "Points are weighted by timing since 2026-09-15",
        ),
        "pointsToNextLevel": m14,
        "price": MessageLookupByLibrary.simpleMessage("Price"),
        "priceLabel": m15,
        "priceMustBeNonNegative": MessageLookupByLibrary.simpleMessage(
          "Price must be 0 or a positive number",
        ),
        "priceOptional": MessageLookupByLibrary.simpleMessage("optional"),
        "processComplete": MessageLookupByLibrary.simpleMessage("Done"),
        "quickAdd": MessageLookupByLibrary.simpleMessage("Quick add"),
        "quickAddHint": MessageLookupByLibrary.simpleMessage(
          "Just type a name, fill in details later",
        ),
        "recordByAmount": MessageLookupByLibrary.simpleMessage("Use a number"),
        "recordByFraction": MessageLookupByLibrary.simpleMessage(
          "Use portion left",
        ),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "remaining": MessageLookupByLibrary.simpleMessage("Left"),
        "remainingFractionAlmostGone": MessageLookupByLibrary.simpleMessage(
          "Almost gone",
        ),
        "remainingFractionFull": MessageLookupByLibrary.simpleMessage("Full"),
        "remainingFractionHalf":
            MessageLookupByLibrary.simpleMessage("About half"),
        "remainingFractionLow":
            MessageLookupByLibrary.simpleMessage("Running low"),
        "remainingFractionMostly": MessageLookupByLibrary.simpleMessage(
          "Most left",
        ),
        "resetPassword": MessageLookupByLibrary.simpleMessage("Reset password"),
        "resetPasswordFailure": MessageLookupByLibrary.simpleMessage(
          "Could not send the reset email",
        ),
        "resetPasswordSent": MessageLookupByLibrary.simpleMessage(
          "Reset email sent — check your inbox",
        ),
        "restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "restoreFailure":
            MessageLookupByLibrary.simpleMessage("Restore failed"),
        "restoreNoBackup": MessageLookupByLibrary.simpleMessage(
          "No backup in the cloud, nothing changed",
        ),
        "restoreSuccess":
            MessageLookupByLibrary.simpleMessage("Restore complete"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "setName": MessageLookupByLibrary.simpleMessage("Set a name"),
        "settingsNavigationBarTitle": MessageLookupByLibrary.simpleMessage(
          "Settings",
        ),
        "settingsPageTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsSection": MessageLookupByLibrary.simpleMessage("Preferences"),
        "shelfLifeAfterOpen": MessageLookupByLibrary.simpleMessage(
          "Days after opening",
        ),
        "showNotification":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "signInWithGoogle": MessageLookupByLibrary.simpleMessage(
          "Sign in with Google",
        ),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signUpFailure": MessageLookupByLibrary.simpleMessage("Sign up failed"),
        "signUpPageTitle": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signUpWelcome": MessageLookupByLibrary.simpleMessage(
          "Create your account",
        ),
        "signedPoints": m16,
        "skip": MessageLookupByLibrary.simpleMessage("Skip"),
        "statisticsMoney": MessageLookupByLibrary.simpleMessage("Money"),
        "statisticsTopWasted": MessageLookupByLibrary.simpleMessage(
          "Most wasted foods",
        ),
        "statisticsWasteRate":
            MessageLookupByLibrary.simpleMessage("Waste rate"),
        "statisticsWasteReasons": MessageLookupByLibrary.simpleMessage(
          "Why food was wasted",
        ),
        "storageDate": MessageLookupByLibrary.simpleMessage("Stored on"),
        "storageLocation": MessageLookupByLibrary.simpleMessage("Location"),
        "storageLocations": MessageLookupByLibrary.simpleMessage(
          "Storage locations",
        ),
        "title": MessageLookupByLibrary.simpleMessage("Food Savior"),
        "totalPoints": MessageLookupByLibrary.simpleMessage("Total points"),
        "unit": MessageLookupByLibrary.simpleMessage("Unit"),
        "unitBag": MessageLookupByLibrary.simpleMessage("bag"),
        "unitBottle": MessageLookupByLibrary.simpleMessage("bottle"),
        "unitBox": MessageLookupByLibrary.simpleMessage("box"),
        "unitCan": MessageLookupByLibrary.simpleMessage("can"),
        "unitCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
          "Please choose a unit",
        ),
        "unitGram": MessageLookupByLibrary.simpleMessage("g"),
        "unitMilliliter": MessageLookupByLibrary.simpleMessage("ml"),
        "unitPack": MessageLookupByLibrary.simpleMessage("pack"),
        "unitPiece": MessageLookupByLibrary.simpleMessage("pc"),
        "unitServing": MessageLookupByLibrary.simpleMessage("serving"),
        "updated": MessageLookupByLibrary.simpleMessage("Updated"),
        "urgencyExpired": MessageLookupByLibrary.simpleMessage("Expired"),
        "urgencyPlenty": MessageLookupByLibrary.simpleMessage("Plenty of time"),
        "urgencyToday": MessageLookupByLibrary.simpleMessage("Today"),
        "urgencyUnknownExpiry": MessageLookupByLibrary.simpleMessage("No date"),
        "urgencyWithinThreeDays": MessageLookupByLibrary.simpleMessage(
          "Within 3 days",
        ),
        "urgencyWithinWeek": MessageLookupByLibrary.simpleMessage("This week"),
        "use": MessageLookupByLibrary.simpleMessage("Use"),
        "useAll": MessageLookupByLibrary.simpleMessage("Use all"),
        "useFoodItem": MessageLookupByLibrary.simpleMessage("Use food"),
        "usedDate": MessageLookupByLibrary.simpleMessage("Used on"),
        "usedFoodItemListNavigationBarTitle":
            MessageLookupByLibrary.simpleMessage(
          "History",
        ),
        "userNavigationBarTitle": MessageLookupByLibrary.simpleMessage("User"),
        "userPageTitle": MessageLookupByLibrary.simpleMessage("Me"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "viewOnGitHub": MessageLookupByLibrary.simpleMessage("View on GitHub"),
        "waste": MessageLookupByLibrary.simpleMessage("Throw out"),
        "wasteReason": MessageLookupByLibrary.simpleMessage("Why"),
        "wasteReasonBoughtTooMuch": MessageLookupByLibrary.simpleMessage(
          "Bought too much",
        ),
        "wasteReasonDisliked": MessageLookupByLibrary.simpleMessage(
          "Didn\'t like it",
        ),
        "wasteReasonExpiredTooLong": MessageLookupByLibrary.simpleMessage(
          "Long past date",
        ),
        "wasteReasonForgotten": MessageLookupByLibrary.simpleMessage(
          "Forgot about it",
        ),
        "wasteReasonOther": MessageLookupByLibrary.simpleMessage("Other"),
        "wasteReasonSpoiled":
            MessageLookupByLibrary.simpleMessage("It went bad"),
        "wasted": MessageLookupByLibrary.simpleMessage("Wasted"),
        "wastedAmount": MessageLookupByLibrary.simpleMessage("Thrown out"),
        "wastedCountLabel": m17,
        "wastedFoodByType":
            MessageLookupByLibrary.simpleMessage("Wasted by type"),
        "weeklyNet": MessageLookupByLibrary.simpleMessage("This week"),
      };
}
