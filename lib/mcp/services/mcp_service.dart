import 'dart:convert';
import 'dart:io';

import 'package:food_savior/mcp/models/mcp_models.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/repositories/used_food_item_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

/// MCP 服務
class McpService {
  final FoodItemRepository foodItemRepository;
  final UsedFoodItemRepository usedFoodItemRepository;
  HttpServer? _server;
  bool _isRunning = false;

  McpService({
    required this.foodItemRepository,
    required this.usedFoodItemRepository,
  });

  /// 公共 getter 來獲取服務運行狀態
  bool get isRunning => _isRunning;

  /// 啟動 MCP 服務
  Future<void> start({int port = 8080}) async {
    if (_isRunning) return;

    final app = Router();

    // 定義 MCP API 路由
    app.post('/mcp', _handleMcpRequest);

    // 定義健康檢查路由
    app.get('/health', (Request request) {
      return Response.ok(
        jsonEncode(
            {'status': 'ok', 'timestamp': DateTime.now().toIso8601String()}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // 設定中間件
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(app);

    // 啟動服務器
    _server = await serve(handler, InternetAddress.anyIPv4, port);
    _isRunning = true;
    print('MCP 服務已啟動於: ${_server!.address.host}:${_server!.port}');
  }

  /// 停止 MCP 服務
  Future<void> stop() async {
    if (!_isRunning || _server == null) return;

    await _server!.close();
    _server = null;
    _isRunning = false;
    print('MCP 服務已停止');
  }

  /// 處理 MCP 請求
  Future<Response> _handleMcpRequest(Request request) async {
    try {
      // 解析請求體
      final requestBody = await request.readAsString();
      final requestJson = jsonDecode(requestBody) as Map<String, dynamic>;
      final mcpRequest = McpRequest.fromJson(requestJson);

      // 根據 action 分發處理
      switch (mcpRequest.action) {
        case 'getFoodItems':
          return await _handleGetFoodItems();
        case 'addFoodItem':
          return await _handleAddFoodItem(mcpRequest.parameters);
        case 'updateFoodItem':
          return await _handleUpdateFoodItem(mcpRequest.parameters);
        case 'deleteFoodItem':
          return await _handleDeleteFoodItem(mcpRequest.parameters);
        case 'getStatistics':
          return await _handleGetStatistics();
        default:
          return _createErrorResponse('不支援的操作: ${mcpRequest.action}');
      }
    } catch (e) {
      return _createErrorResponse('處理請求時發生錯誤: $e');
    }
  }

  /// 處理獲取食物項目列表
  Future<Response> _handleGetFoodItems() async {
    try {
      final foodItems = foodItemRepository.getAllFoodItems();

      // 將食物項目列表轉換為可序列化格式
      final serializedItems = foodItems.map((item) => item.toJson()).toList();

      final response = McpResponse(
        success: true,
        message: '成功獲取食物項目列表',
        data: {'items': serializedItems},
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _createErrorResponse('獲取食物項目列表時發生錯誤: $e');
    }
  }

  /// 處理添加食物項目
  Future<Response> _handleAddFoodItem(Map<String, dynamic> parameters) async {
    try {
      // 從參數創建食物項目
      final foodItem = FoodItem.fromJson(parameters['foodItem']);

      // 添加食物項目
      await foodItemRepository.saveFoodItem(foodItem);

      final response = McpResponse(
        success: true,
        message: '成功添加食物項目',
        data: {'item': foodItem.toJson()},
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _createErrorResponse('添加食物項目時發生錯誤: $e');
    }
  }

  /// 處理更新食物項目
  Future<Response> _handleUpdateFoodItem(
      Map<String, dynamic> parameters) async {
    try {
      // 從參數創建食物項目
      final foodItem = FoodItem.fromJson(parameters['foodItem']);

      // 更新食物項目
      await foodItemRepository.saveFoodItem(foodItem);

      final response = McpResponse(
        success: true,
        message: '成功更新食物項目',
        data: {'item': foodItem.toJson()},
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _createErrorResponse('更新食物項目時發生錯誤: $e');
    }
  }

  /// 處理刪除食物項目
  Future<Response> _handleDeleteFoodItem(
      Map<String, dynamic> parameters) async {
    try {
      final foodItemId = parameters['id'] as String;

      // 刪除食物項目
      await foodItemRepository.deleteFoodItem(foodItemId);

      final response = McpResponse(
        success: true,
        message: '成功刪除食物項目',
        data: {'id': foodItemId},
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _createErrorResponse('刪除食物項目時發生錯誤: $e');
    }
  }

  /// 處理獲取統計資料
  Future<Response> _handleGetStatistics() async {
    try {
      final foodItems = foodItemRepository.getAllFoodItems();
      final usedFoodItems = usedFoodItemRepository.getAllUsedFoodItems();

      // 計算基本統計數據
      final stats = {
        'totalItems': foodItems.length,
        'totalUsed': usedFoodItems.length,
        'savedFromWaste': usedFoodItems.length,
      };

      final response = McpResponse(
        success: true,
        message: '成功獲取統計資料',
        data: {'statistics': stats},
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _createErrorResponse('獲取統計資料時發生錯誤: $e');
    }
  }

  /// 創建錯誤響應
  Response _createErrorResponse(String message) {
    final response = McpResponse(
      success: false,
      message: message,
    );

    return Response.internalServerError(
      body: jsonEncode(response.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// CORS 中間件
  Middleware _corsMiddleware() {
    return createMiddleware(
      requestHandler: (request) {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        return null;
      },
      responseHandler: (response) {
        return response.change(headers: {...response.headers, ..._corsHeaders});
      },
    );
  }

  /// CORS 頭部信息
  final Map<String, String> _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
    'Access-Control-Allow-Credentials': 'true',
  };
}
