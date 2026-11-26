import 'package:material_ui/material_ui.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';

/// Full-width setting block that stacks its control below the title/subtitle
/// so labels never wrap mid-word on narrow phone screens.
class WetarStackedControlTile extends StatelessWidget {
  const WetarStackedControlTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingMd,
        vertical: tokens.spacingSm * 1.1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                SizedBox(width: tokens.spacingMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.inkPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: tokens.inkMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSm * 1.25),
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );
  }
}

/// Full-width dropdown setting tile preventing narrow-viewport title squishing.
class WetarDropdownTile<T> extends StatelessWidget {
  const WetarDropdownTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final T? effectiveValue = items.any((item) => item.value == value)
        ? value
        : (items.isNotEmpty ? items.first.value : null);
    return WetarStackedControlTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacingMd * 0.85,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusCard * 0.85),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: effectiveValue,
            dropdownColor: tokens.surfaceElevated,
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

/// Option item displayed inside [WetarOptionChips].
class WetarOptionItem<T> {
  const WetarOptionItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Single-line wrapping option pills that never break words mid-word across
/// narrow viewports or scaled text sizes.
class WetarOptionChips<T> extends StatelessWidget {
  const WetarOptionChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<WetarOptionItem<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: options.map((item) {
        final selected = item.value == selectedValue;
        final fgColor = selected ? tokens.accentPrimary : tokens.inkPrimary;
        return Material(
          color: selected
              ? tokens.accentPrimary.withValues(alpha: 0.16)
              : tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusCard * 0.85),
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusCard * 0.85),
            onTap: () => onSelected(item.value),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingMd * 0.85,
                vertical: tokens.spacingSm * 1.15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.radiusCard * 0.85),
                border: Border.all(
                  color: selected ? tokens.accentPrimary : tokens.borderSubtle,
                  width: selected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (selected) ...<Widget>[
                    Icon(Icons.check_rounded, size: 16, color: fgColor),
                    SizedBox(width: tokens.spacingXs * 1.5),
                  ] else if (item.icon != null) ...<Widget>[
                    Icon(item.icon, size: 16, color: tokens.inkMuted),
                    SizedBox(width: tokens.spacingXs * 1.5),
                  ],
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle?.copyWith(
                        color: fgColor,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Full-width stacked slider tile keeping title and value readout uncramped.
class WetarSliderTile extends StatelessWidget {
  const WetarSliderTile({
    super.key,
    required this.title,
    this.valueLabel,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.divisions,
    this.activeColor,
  });

  final String title;
  final String? valueLabel;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double>? onChanged;
  final int? divisions;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    final textTheme = Theme.of(context).textTheme;
    final clamped = value.clamp(min, max).toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingMd,
        vertical: tokens.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: tokens.inkPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (valueLabel != null) ...<Widget>[
                SizedBox(width: tokens.spacingSm),
                Text(
                  valueLabel!,
                  maxLines: 1,
                  softWrap: false,
                  style: textTheme.labelLarge?.copyWith(
                    color: tokens.accentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: clamped,
            activeColor: activeColor ?? tokens.accentPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
