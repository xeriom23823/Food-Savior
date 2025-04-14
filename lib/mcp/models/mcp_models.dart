import 'package:json_annotation/json_annotation.dart';

/// MCP 請求模型
class McpRequest {
  final String action;
  final Map<String, dynamic> parameters;

  McpRequest({required this.action, required this.parameters});

  Map<String, dynamic> toJson() => {
        'action': action,
        'parameters': parameters,
      };

  factory McpRequest.fromJson(Map<String, dynamic> json) => McpRequest(
        action: json['action'] as String,
        parameters: json['parameters'] as Map<String, dynamic>,
      );
}

/// MCP 響應模型
class McpResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  McpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data,
      };

  factory McpResponse.fromJson(Map<String, dynamic> json) => McpResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        data: json['data'] as Map<String, dynamic>?,
      );
}

/// MCP 操作類型枚舉
enum McpAction {
  getFoodItems,
  addFoodItem,
  updateFoodItem,
  deleteFoodItem,
  getStatistics,
}

/// MCP 操作類型擴展方法
extension McpActionExtension on McpAction {
  String get value {
    switch (this) {
      case McpAction.getFoodItems:
        return 'getFoodItems';
      case McpAction.addFoodItem:
        return 'addFoodItem';
      case McpAction.updateFoodItem:
        return 'updateFoodItem';
      case McpAction.deleteFoodItem:
        return 'deleteFoodItem';
      case McpAction.getStatistics:
        return 'getStatistics';
    }
  }
}
