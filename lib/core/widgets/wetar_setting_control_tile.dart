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
            value: value,
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
