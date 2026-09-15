import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/theme/app_tokens.dart';

/// 修改顯示名稱。Email 註冊的使用者原本連名字都沒有。
class EditNameSheet extends StatefulWidget {
  const EditNameSheet({super.key, this.initialName});

  final String? initialName;

  static const int maxLength = 30;

  static Future<String?> show(BuildContext context, {String? initialName}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditNameSheet(initialName: initialName),
    );
  }

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.editName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: EditNameSheet.maxLength,
                decoration: InputDecoration(
                  labelText: strings.name,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: _submit, child: Text(strings.save)),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final strings = S.of(context);
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = strings.nameCannotBeEmpty);
      return;
    }
    if (name.length > EditNameSheet.maxLength) {
      setState(() => _error = strings.nameTooLong);
      return;
    }
    Navigator.of(context).pop(name);
  }
}
