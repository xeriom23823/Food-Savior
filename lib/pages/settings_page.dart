import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/cubits/theme_cubit.dart';
import 'package:food_savior/cubits/locale_cubit.dart';
import 'package:clipboard/clipboard.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isMcpServiceRunning = false;
  String _ipAddress = '';

  @override
  void initState() {
    super.initState();
    _checkMcpServiceStatus();
    _getDeviceIp();
  }

  Future<void> _checkMcpServiceStatus() async {
    setState(() {
      _isMcpServiceRunning = mcpService.isRunning;
    });
  }

  Future<void> _getDeviceIp() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            setState(() {
              _ipAddress = addr.address;
            });
            return;
          }
        }
      }
    } catch (e) {
      setState(() {
        _ipAddress = '獲取IP地址失敗';
      });
    }
  }

  Future<void> _toggleMcpService() async {
    if (_isMcpServiceRunning) {
      await mcpService.stop();
    } else {
      try {
        await mcpService.start(port: 8080);
      } catch (e) {
        // 處理啟動失敗
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('啟動 MCP 服務失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    await _checkMcpServiceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsNavigationBarTitle),
      ),
      body: ListView(
        children: [
          _buildThemeSettings(),
          _buildLanguageSettings(),
          _buildMcpSettings(),
        ],
      ),
    );
  }

  Widget _buildThemeSettings() {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, state) {
        final isDark = state.brightness == Brightness.dark;
        final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  S.of(context).darkMode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                leading: const Icon(Icons.brightness_6),
              ),
              RadioListTile<bool>(
                title: Text('light mode'),
                value: false,
                groupValue: isDark,
                onChanged: (bool? value) {
                  if (value != null && value == false) {
                    context.read<ThemeCubit>().switchTheme();
                  }
                },
              ),
              RadioListTile<bool>(
                title: Text(S.of(context).darkMode),
                value: true,
                groupValue: isDark,
                onChanged: (bool? value) {
                  if (value != null && value == true) {
                    context.read<ThemeCubit>().switchTheme();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettings() {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  S.of(context).language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                leading: const Icon(Icons.language),
              ),
              RadioListTile<Locale>(
                title: const Text('繁體中文'),
                value: const Locale('zh', 'TW'),
                groupValue: state,
                onChanged: (Locale? value) {
                  if (value != null) {
                    context.read<LocaleCubit>().setLocale(value);
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en', 'US'),
                groupValue: state,
                onChanged: (Locale? value) {
                  if (value != null) {
                    context.read<LocaleCubit>().setLocale(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMcpSettings() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'AI 助手連接 (MCP)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            leading: const Icon(Icons.smart_toy),
          ),
          SwitchListTile(
            title: const Text('啟用 MCP 服務'),
            subtitle: Text(_isMcpServiceRunning ? '服務已啟動' : '服務已停止'),
            value: _isMcpServiceRunning,
            onChanged: (bool value) async {
              await _toggleMcpService();
            },
          ),
          const Divider(),
          if (_isMcpServiceRunning) ...[
            ListTile(
              title: const Text('連接資訊'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('裝置 IP: $_ipAddress'),
                  const Text('連接埠: 8080'),
                  Text('API 端點: http://$_ipAddress:8080/mcp'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('複製連接資訊'),
                onPressed: () {
                  final connectionInfo = '''
MCP 連接資訊：
裝置 IP: $_ipAddress
連接埠: 8080
API 端點: http://$_ipAddress:8080/mcp
''';
                  // 使用剪貼簿功能複製資訊
                  FlutterClipboard.copy(connectionInfo).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('連接資訊已複製到剪貼簿'),
                      ),
                    );
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '提示：啟用此功能後，ChatGPT 等 AI 助手可以連接到您的 Food-Savior 應用，協助您管理食物庫存，並提供食譜建議。',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
