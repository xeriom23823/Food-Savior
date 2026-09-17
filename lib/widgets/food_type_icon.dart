import 'package:flutter/material.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/food_item_visuals.dart';

/// 食物類型的 24dp 線性圖示。
///
/// Asset 保留透明 alpha；顏色以 [BlendMode.srcIn] 套用呼叫端的
/// IconTheme／語意色，所以同一套圖示可在明暗主題與不同狀態色中重用。
class FoodTypeIcon extends StatelessWidget {
  const FoodTypeIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  final FoodItemType type;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor =
        color ?? IconTheme.of(context).color ?? theme.colorScheme.onSurface;
    final image = Image.asset(
      FoodItemVisuals.assetOf(type),
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );

    return ColorFiltered(
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      child: image,
    );
  }
}
