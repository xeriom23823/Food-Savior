import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_form_validator.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/app_scaffold.dart';
import 'package:food_savior/widgets/expiry_field.dart';
import 'package:food_savior/widgets/food_type_icon.dart';
import 'package:food_savior/widgets/location_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// 新增／編輯食物的全螢幕表單（design D6）。
///
/// 除名稱與份量外全部選填，而且每個欄位都有合理預設——欄位變多不該讓記錄變難。
class FoodItemFormPage extends StatefulWidget {
  const FoodItemFormPage({
    super.key,
    this.original,
    required this.locations,
    required this.now,
  });

  final FoodItem? original;
  final List<StorageLocation> locations;
  final DateTime now;

  @override
  State<FoodItemFormPage> createState() => _FoodItemFormPageState();
}

class _FoodItemFormPageState extends State<FoodItemFormPage> {
  static const FoodItemFormValidator _validator = FoodItemFormValidator();
  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _afterOpenController;

  late FoodItemType _type;
  late Unit? _unit;
  late RemainingFraction? _fraction;
  late bool _useFraction;
  late ExpiryValue _expiry;
  late DateTime _storageDate;
  late DateTime? _openedDate;
  late String? _locationId;

  FoodFormError? _nameError;
  FoodFormError? _amountError;
  FoodFormError? _expiryError;
  FoodFormError? _priceError;

  @override
  void initState() {
    super.initState();
    final original = widget.original;
    _nameController = TextEditingController(text: original?.name ?? '');
    // 新增時預設 1：份量是必填，留空會讓使用者一送出就吃到錯誤訊息。
    _amountController = TextEditingController(
      text: original == null
          ? '1'
          : (original.amount == null ? '' : _formatAmount(original.amount!)),
    );
    _priceController = TextEditingController(
      text: original?.priceTotal?.toString() ?? '',
    );
    _descriptionController =
        TextEditingController(text: original?.description ?? '');
    _afterOpenController = TextEditingController(
      text: original?.shelfLifeAfterOpenDays?.toString() ?? '',
    );

    _type = original?.type ?? FoodItemType.others;
    _unit = original?.unit ?? Unit.piece;
    _fraction = original?.remainingFraction;
    _useFraction = original?.remainingFraction != null;
    _expiry = original == null
        ? ExpiryValue.exact(widget.now.add(const Duration(days: 7)))
        : ExpiryValue.of(original);
    _storageDate = original?.storageDate ?? widget.now;
    _openedDate = original?.openedDate;
    _locationId = original?.storageLocationId ??
        (widget.locations.isEmpty ? null : widget.locations.first.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _afterOpenController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.original != null;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return AppScaffold(
      title: _isEditing ? strings.editFoodItem : strings.addFoodItem,
      actions: [
        TextButton(onPressed: _submit, child: Text(strings.save)),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          TextField(
            controller: _nameController,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: strings.name,
              errorText: _nameError?.localizedMessage(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<FoodItemType>(
            initialValue: _type,
            isExpanded: true,
            decoration: InputDecoration(labelText: strings.foodType),
            items: FoodItemType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          FoodTypeIcon(type: type, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(type.localizedName(context)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildAmountSection(strings),
          const SizedBox(height: AppSpacing.lg),
          LocationPicker(
            locations: widget.locations,
            selectedId: _locationId,
            onChanged: (value) => setState(() => _locationId = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DateRow(
            label: strings.storageDate,
            value: _dayFormat.format(_storageDate),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _storageDate,
                firstDate: DateTime(widget.now.year - 5),
                lastDate: DateTime(widget.now.year + 10),
              );
              if (picked != null) setState(() => _storageDate = picked);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          ExpiryField(
            value: _expiry,
            now: widget.now,
            errorText: _expiryError?.localizedMessage(context),
            onChanged: (value) => setState(() => _expiry = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildOpenedSection(strings),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: strings.price,
              helperText: strings.priceOptional,
              errorText: _priceError?.localizedMessage(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(labelText: strings.description),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _submit, child: Text(strings.save)),
        ],
      ),
    );
  }

  Widget _buildAmountSection(S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(strings.amount,
                    style: Theme.of(context).textTheme.labelLarge)),
            TextButton(
              onPressed: () => setState(() {
                _useFraction = !_useFraction;
                _fraction ??= RemainingFraction.full;
              }),
              child: Text(
                _useFraction
                    ? strings.recordByAmount
                    : strings.recordByFraction,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_useFraction)
          Wrap(
            spacing: AppSpacing.sm,
            children: RemainingFraction.values
                .map((fraction) => ChoiceChip(
                      label: Text(fraction.localizedName(context)),
                      selected: _fraction == fraction,
                      onSelected: (_) => setState(() => _fraction = fraction),
                    ))
                .toList(),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    errorText: _amountError?.localizedMessage(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<Unit>(
                  initialValue: _unit,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: strings.unit),
                  items: Unit.values
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit.localizedName(context)),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _unit = value),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOpenedSection(S strings) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.opened),
          subtitle: _openedDate == null
              ? null
              : Text('${strings.openedDate}: '
                  '${_dayFormat.format(_openedDate!)}'),
          value: _openedDate != null,
          onChanged: (value) => setState(() {
            _openedDate = value ? widget.now : null;
          }),
        ),
        if (_openedDate != null)
          TextField(
            controller: _afterOpenController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: strings.shelfLifeAfterOpen),
          ),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text;
    final nameError = _validator.validateName(name);
    final amountError = _useFraction
        ? null
        : _validator.validateAmount(
            rawAmount: _amountController.text,
            unit: _unit,
            remainingFraction: null,
          );
    final expiryError = _validator.validateExpiry(_expiry);
    final priceError = _validator.validatePrice(_priceController.text);

    setState(() {
      _nameError = nameError;
      _amountError = amountError;
      _expiryError = expiryError;
      _priceError = priceError;
    });

    if (nameError != null ||
        amountError != null ||
        expiryError != null ||
        priceError != null) {
      return;
    }

    final original = widget.original;
    final item = FoodItem(
      id: original?.id ?? const Uuid().v4(),
      name: name.trim(),
      type: _type,
      status: original?.status ?? FoodItemStatus.unknownExpiry,
      storageDate: _storageDate,
      amount: _useFraction ? null : double.tryParse(_amountController.text),
      unit: _useFraction ? null : _unit,
      remainingFraction: _useFraction ? _fraction : null,
      description: _descriptionController.text.trim(),
      expiryEarliest: _expiry.earliest,
      expiryLatest: _expiry.latest,
      expiryPrecision: _expiry.precision,
      openedDate: _openedDate,
      shelfLifeAfterOpenDays:
          _openedDate == null ? null : int.tryParse(_afterOpenController.text),
      storageLocationId: _locationId,
      priceTotal: int.tryParse(_priceController.text),
    );

    Navigator.of(context).pop(item);
  }

  static String _formatAmount(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.field,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(child: Text(value)),
            Icon(Icons.calendar_today_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
