import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'View All',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.tsTitle),
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel, style: AppTheme.tsAccent),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chips ───────────────────────────────────────────────────────────
class CategoryChips extends StatelessWidget {
  final List<SportCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final sel = selectedId == cat.id;
          return GestureDetector(
            onTap: () => onSelect(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppTheme.kAccent : AppTheme.kCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: sel ? AppTheme.kAccent : AppTheme.kBorder),
                boxShadow: sel
                    ? [BoxShadow(
                        color: AppTheme.kAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(cat.name,
                    style: TextStyle(
                      color: sel
                          ? const Color(0xFF0A1828)
                          : Colors.white60,
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                    )),
              ]),
            ),
          );
        },
      ),
    );
  }
}
