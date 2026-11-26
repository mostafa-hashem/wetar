import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/features/player/domain/queue_snapshot_codec.dart';
import 'package:wetar/features/player/domain/replay_gain_math.dart';
import 'package:wetar/features/settings/domain/playback_settings.dart';

void main() {
  test('PersistedQueueState encodes and clamps invalid indices cleanly', () {
    const original = PersistedQueueState(
      trackStableKeys: <String>['/a.mp3', '/b.mp3'],
      currentIndex: 1,
      positionMs: 42500,
      shuffleEnabled: true,
      repeatMode: WetarRepeatMode.all,
    );
    final decoded = PersistedQueueState.decode(
      itemsJson: original.encodeItems(),
      currentIndex: 99,
      positionMs: 42500,
      shuffleEnabled: true,
      repeatModeName: 'all',
    );
    expect(decoded.trackStableKeys, <String>['/a.mp3', '/b.mp3']);
    expect(decoded.currentIndex, 1);
    expect(decoded.positionMs, 42500);
    expect(decoded.shuffleEnabled, isTrue);
    expect(decoded.repeatMode, WetarRepeatMode.all);
  });

  test('ReplayGainCalculator attenuates loud tracks without clipping', () {
    final gain = ReplayGainCalculator.computeLinearVolume(
      mode: ReplayGainMode.track,
      preampDb: 0.0,
      trackGainDb: -6.0,
    );
    expect(gain, closeTo(0.501, 0.01));
    expect(ReplayGainCalculator.parseDbTag('-4.25 dB'), -4.25);
  });
}
