import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/features/equalizer/presentation/bloc/equalizer_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Native equalizer screen with interactive Bézier response curve, preset strip,
/// custom preset save/delete, BassBoost, Virtualizer, and LoudnessEnhancer.
class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  String _formatHz(double hz) {
    if (hz >= 1000) {
      return '${(hz / 1000).toStringAsFixed(hz % 1000 == 0 ? 0 : 1)}k';
    }
    return '${hz.round()}';
  }

  Future<void> _savePresetDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.equalizerSavePreset),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.equalizerPresetNameHint),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty && context.mounted) {
      await context.read<EqualizerCubit>().saveCustomPreset(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();

    return BlocBuilder<EqualizerCubit, EqualizerState>(
      builder: (context, state) {
        final cubit = context.read<EqualizerCubit>();
        if (!state.isAvailable) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.playerEqualizer)),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(tokens.spacingLg),
                child: Text(
                  l10n.equalizerUnavailable,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.playerEqualizer),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.equalizerSavePreset,
                icon: const Icon(Icons.bookmark_add_outlined),
                onPressed: () => _savePresetDialog(context),
              ),
              Switch(
                value: state.isEnabled,
                activeTrackColor: tokens.accentPrimary,
                onChanged: cubit.setEnabled,
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(tokens.spacingMd),
            children: <Widget>[
              // Frequency response curve graph
              Container(
                height: 150,
                padding: EdgeInsets.all(tokens.spacingMd),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(tokens.radiusCard),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: CustomPaint(
                  painter: _EqCurvePainter(
                    bands: state.bands,
                    minDb: state.minDb,
                    maxDb: state.maxDb,
                    enabled: state.isEnabled,
                    accent: tokens.accentPrimary,
                    secondary: tokens.accentSecondary,
                    gridColor: tokens.borderSubtle,
                  ),
                ),
              ),
              SizedBox(height: tokens.spacingMd),

              // Preset chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.presets.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: tokens.spacingSm),
                  itemBuilder: (context, idx) {
                    final preset = state.presets[idx];
                    final selected = state.activePresetName == preset.name;
                    return InputChip(
                      selected: selected,
                      label: Text(preset.name),
                      onSelected: (_) => cubit.applyPreset(preset),
                      onDeleted: preset.isCustom
                          ? () => cubit.deleteCustomPreset(preset.name)
                          : null,
                    );
                  },
                ),
              ),
              SizedBox(height: tokens.spacingMd),

              // Band sliders
              Card(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: state.bands.map((band) {
                      return Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              band.gainDb.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SizedBox(
                              height: 180,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  min: state.minDb,
                                  max: state.maxDb,
                                  value: band.gainDb.clamp(
                                    state.minDb,
                                    state.maxDb,
                                  ),
                                  activeColor: state.isEnabled
                                      ? tokens.accentPrimary
                                      : tokens.inkMuted,
                                  onChanged: state.isEnabled
                                      ? (v) => cubit.setBandGain(band.index, v)
                                      : null,
                                ),
                              ),
                            ),
                            Text(
                              _formatHz(band.centerFreqHz),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacingMd),

              if (caps.supportsBassBoost)
                ListTile(
                  title: Text(l10n.equalizerBassBoost),
                  trailing: Text('${(state.bassBoostStrength / 10).round()}%'),
                  subtitle: Slider(
                    min: 0,
                    max: 1000,
                    value: state.bassBoostStrength.toDouble(),
                    activeColor: tokens.accentPrimary,
                    onChanged: (v) => cubit.setBassBoost(v.round()),
                  ),
                ),
              if (caps.supportsVirtualizer)
                ListTile(
                  title: Text(l10n.equalizerVirtualizer),
                  trailing: Text(
                    '${(state.virtualizerStrength / 10).round()}%',
                  ),
                  subtitle: Slider(
                    min: 0,
                    max: 1000,
                    value: state.virtualizerStrength.toDouble(),
                    activeColor: tokens.accentSecondary,
                    onChanged: (v) => cubit.setVirtualizer(v.round()),
                  ),
                ),
              if (caps.supportsLoudnessEnhancer) ...<Widget>[
                ListTile(
                  title: Text(l10n.equalizerLoudness),
                  trailing: Text(
                    '+${state.loudnessGainDb.toStringAsFixed(1)} dB',
                  ),
                  subtitle: Slider(
                    min: 0,
                    max: 12,
                    divisions: 24,
                    value: state.loudnessGainDb,
                    activeColor: tokens.accentPrimary,
                    onChanged: cubit.setLoudnessGain,
                  ),
                ),
                if (state.loudnessGainDb >= 6.0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
                    child: Text(
                      l10n.equalizerLoudnessWarning,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: tokens.danger),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EqCurvePainter extends CustomPainter {
  const _EqCurvePainter({
    required this.bands,
    required this.minDb,
    required this.maxDb,
    required this.enabled,
    required this.accent,
    required this.secondary,
    required this.gridColor,
  });

  final List<EqBandInfo> bands;
  final double minDb;
  final double maxDb;
  final bool enabled;
  final Color accent;
  final Color secondary;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );
    if (bands.isEmpty) return;

    final points = <Offset>[];
    final span = (maxDb - minDb).abs().clamp(1.0, 60.0);
    for (var i = 0; i < bands.length; i++) {
      final x = bands.length == 1
          ? size.width / 2
          : (i / (bands.length - 1)) * size.width;
      final norm = ((bands[i].gainDb - minDb) / span).clamp(0.0, 1.0);
      final y = size.height - norm * size.height;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final ctrlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(ctrlX, p0.dy, ctrlX, p1.dy, p1.dx, p1.dy);
    }

    final lineColor = enabled ? accent : accent.withValues(alpha: 0.35);
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (final pt in points) {
      canvas.drawCircle(pt, 5, Paint()..color = secondary);
    }
  }

  @override
  bool shouldRepaint(covariant _EqCurvePainter oldDelegate) {
    return oldDelegate.bands != bands ||
        oldDelegate.enabled != enabled ||
        oldDelegate.accent != accent;
  }
}
