import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/features/music_folders/domain/audio_format_policy.dart';

void main() {
  group('AudioFormatPolicy', () {
    test('accepts comprehensive audio extensions regardless of case', () {
      const audioFiles = <String>[
        '/music/track.mp3',
        '/music/TRACK.MP3',
        '/music/book.m4b',
        '/music/ring.m4r',
        '/music/song.m4a',
        '/music/live.aac',
        '/music/studio.flac',
        '/music/raw.wav',
        '/music/raw2.wave',
        '/music/vorbis.ogg',
        '/music/vorbis2.oga',
        '/music/podcast.opus',
        '/music/apple.aiff',
        '/music/apple2.aif',
        '/music/core.caf',
        '/music/wavpack.wv',
        '/music/monkey.ape',
        '/music/matroska.mka',
        '/music/windows.wma',
        '/music/voice.amr',
        '/music/voice2.awb',
        '/music/mobile.3ga',
        '/music/surround.ac3',
        '/music/surround2.eac3',
        '/music/theater.dts',
        '/music/audiophile.dsf',
        '/music/audiophile2.dff',
        '/music/lossless.tta',
        '/music/synth.mid',
        '/music/synth2.midi',
        '/music/.HiddenCloud.m4a.icloud',
      ];

      for (final path in audioFiles) {
        expect(
          AudioFormatPolicy.isSupportedAudioFile(pathOrName: path),
          isTrue,
          reason: 'Expected $path to be accepted as audio',
        );
        expect(
          AudioFormatPolicy.isVideoFile(pathOrName: path),
          isFalse,
          reason: 'Expected $path not to be treated as video',
        );
      }
    });

    test(
      'strictly rejects all video extensions even with audio MIME types',
      () {
        const videoFiles = <String>[
          '/videos/clip.mp4',
          '/videos/CLIP.MP4',
          '/videos/movie.mkv',
          '/videos/web.webm',
          '/videos/camera.mov',
          '/videos/old.avi',
          '/videos/phone.3gp',
          '/videos/phone2.3g2',
          '/videos/stream.flv',
          '/videos/win.wmv',
          '/videos/ts_video.ts',
          '/videos/apple_vid.m4v',
          '/videos/mpg_clip.mpg',
          '/videos/mpeg_clip.mpeg',
          '/videos/ogv_clip.ogv',
          '/videos/.CloudVideo.mp4.icloud',
        ];

        const misleadingMimes = <String?>[
          null,
          'video/mp4',
          'audio/mp4',
          'audio/3gpp',
          'audio/webm',
        ];

        for (final path in videoFiles) {
          for (final mime in misleadingMimes) {
            expect(
              AudioFormatPolicy.isVideoFile(pathOrName: path, mimeType: mime),
              isTrue,
              reason: 'Expected $path ($mime) to be classified as video',
            );
            expect(
              AudioFormatPolicy.isSupportedAudioFile(
                pathOrName: path,
                mimeType: mime,
              ),
              isFalse,
              reason:
                  'Expected $path ($mime) to be rejected from audio library',
            );
          }
        }
      },
    );
  });
}
