import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/design_system/components/app_card.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Catalog product tile with image, title, price, and optional badge.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    this.imageUrl,
    this.badge,
    this.isSelected = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    super.key,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
  final String? imageUrl;
  final String? badge;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.outline),
                ),
                if (badge != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Chip(label: Text(badge!, style: const TextStyle(fontSize: 11))),
                  ),
                if (onFavoriteToggle != null)
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: IconButton(
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(priceLabel, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
    if (!isSelected) return Padding(padding: const EdgeInsets.all(AppSpacing.sm), child: card);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: card,
      ),
    );
  }
}

/// KPI / metric display card.
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                if (trend != null) Text(trend!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact summary row card.
class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

/// Tappable card with selection highlight.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.child,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final Widget child;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => onSelected(!isSelected),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
