import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../library/domain/library_models.dart';
import '../../../personalization/presentation/theme/wetar_tokens.dart';

/// Playlists entry screen (Phase 1 shell; full playlist CRUD, 2x2 collage covers,
/// M3U import/export, and smart playlists built in Phase 3).
class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({
    super.key,
    this.embedded = false,
    this.onOpenTrackDetails,
  });

  final bool embedded;
  final ValueChanged<WetarTrack>? onOpenTrackDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final body = Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.queue_music_rounded,
              size: 52,
              color: tokens.accentPrimary,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              l10n.playlistsEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPlaylists)),
      body: body,
    );
  }
}
