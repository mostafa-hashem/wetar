/// Canonical audio/video file format policy shared across scanners and importers.
/// Pure Dart with zero Flutter or platform-channel dependencies.
class AudioFormatPolicy {
  AudioFormatPolicy._();

  /// Video file extensions that must never enter Wetar's audio library or counts.
  static const Set<String> videoExtensions = <String>{
    '.mp4',
    '.m4v',
    '.mkv',
    '.webm',
    '.mov',
    '.qt',
    '.avi',
    '.wmv',
    '.flv',
    '.f4v',
    '.3gp',
    '.3g2',
    '.3gpp',
    '.3gpp2',
    '.ts',
    '.mts',
    '.m2ts',
    '.vob',
    '.mpg',
    '.mpeg',
    '.mpe',
    '.mpv',
    '.m2v',
    '.ogv',
    '.ogm',
    '.divx',
    '.xvid',
    '.asf',
    '.rm',
    '.rmvb',
    '.swf',
    '.dv',
    '.amv',
    '.h264',
    '.h265',
    '.hevc',
  };

  /// Supported local audio file extensions (MPEG, MPEG-4 audio, Xiph, PCM,
  /// lossless, voice, surround, and MIDI/tracker audio).
  static const Set<String> supportedAudioExtensions = <String>{
    // MPEG
    '.mp3',
    '.mp2',
    '.mp1',
    '.mpga',
    '.mpa',
    // MPEG-4 / AAC / Apple Audio
    '.m4a',
    '.m4b',
    '.m4r',
    '.m4p',
    '.aac',
    '.alac',
    '.3ga',
    '.f4a',
    // Xiph / Ogg / Matroska Audio
    '.ogg',
    '.oga',
    '.opus',
    '.spx',
    '.flac',
    '.mka',
    // Uncompressed / PCM / CoreAudio
    '.wav',
    '.wave',
    '.aiff',
    '.aif',
    '.aifc',
    '.caf',
    '.pcm',
    '.au',
    '.snd',
    // Lossless / Audiophile
    '.wv',
    '.ape',
    '.tta',
    '.tak',
    '.shn',
    '.dsf',
    '.dff',
    '.dsd',
    '.mlp',
    // Voice / Windows / Surround / Synth
    '.wma',
    '.amr',
    '.awb',
    '.ac3',
    '.eac3',
    '.ec3',
    '.dts',
    '.mid',
    '.midi',
    '.kar',
    '.imy',
    '.ota',
    '.rtttl',
    '.rtx',
    '.xmf',
    '.mxmf',
  };

  /// Extensions where an OS metadata probe should verify whether the container
  /// holds motion video or resolve missing pre-playback duration.
  static const Set<String> probeCandidateExtensions = <String>{
    '.m4a',
    '.m4b',
    '.m4r',
    '.aac',
    '.caf',
    '.3ga',
    '.ac3',
    '.eac3',
    '.amr',
    '.mka',
    '.ogg',
    '.opus',
  };

  static const Set<String> _audioApplicationMimeTypes = <String>{
    'application/ogg',
    'application/flac',
    'application/x-flac',
    'application/opus',
  };

  /// Extracts a normalized lowercase `.ext` from a path, filename, or URI.
  /// Handles iCloud placeholder names (e.g. `.Song.m4a.icloud` -> `.m4a`).
  static String normalizedExtension(String pathOrName) {
    var clean = pathOrName.trim();
    if (clean.isEmpty) return '';
    final qIdx = clean.indexOf('?');
    if (qIdx >= 0) clean = clean.substring(0, qIdx);
    final hIdx = clean.indexOf('#');
    if (hIdx >= 0) clean = clean.substring(0, hIdx);

    final slashIdx = clean.lastIndexOf('/');
    var baseName = slashIdx >= 0 ? clean.substring(slashIdx + 1) : clean;
    final bsIdx = baseName.lastIndexOf(r'\');
    if (bsIdx >= 0) baseName = baseName.substring(bsIdx + 1);

    if (baseName.toLowerCase().endsWith('.icloud') &&
        baseName.length > '.icloud'.length) {
      baseName = baseName.substring(0, baseName.length - '.icloud'.length);
    }

    final dotIdx = baseName.lastIndexOf('.');
    if (dotIdx <= 0 || dotIdx == baseName.length - 1) return '';
    return baseName.substring(dotIdx).toLowerCase();
  }

  /// Returns `true` for video, image, or text files/MIME types.
  static bool isVideoFile({required String pathOrName, String? mimeType}) {
    final mime = mimeType?.trim().toLowerCase() ?? '';
    if (mime.startsWith('video/') ||
        mime.startsWith('image/') ||
        mime.startsWith('text/')) {
      return true;
    }
    final ext = normalizedExtension(pathOrName);
    return ext.isNotEmpty && videoExtensions.contains(ext);
  }

  /// Returns `true` only if the file is a supported audio format and NOT video.
  static bool isSupportedAudioFile({
    required String pathOrName,
    String? mimeType,
  }) {
    if (isVideoFile(pathOrName: pathOrName, mimeType: mimeType)) {
      return false;
    }
    final ext = normalizedExtension(pathOrName);
    if (ext.isNotEmpty) {
      return supportedAudioExtensions.contains(ext);
    }
    final mime = mimeType?.trim().toLowerCase() ?? '';
    return mime.startsWith('audio/') ||
        _audioApplicationMimeTypes.contains(mime);
  }

  static String mimeTypeForExtension(String ext) {
    final lower = ext.trim().toLowerCase();
    final dotted = lower.isEmpty
        ? ''
        : (lower.startsWith('.') ? lower : '.$lower');
    return switch (dotted) {
      '.mp3' || '.mp2' || '.mp1' || '.mpga' || '.mpa' => 'audio/mpeg',
      '.m4a' || '.m4b' || '.m4r' || '.m4p' || '.alac' || '.f4a' => 'audio/mp4',
      '.aac' => 'audio/aac',
      '.3ga' => 'audio/3gpp',
      '.flac' => 'audio/flac',
      '.ogg' || '.oga' || '.spx' => 'audio/ogg',
      '.opus' => 'audio/opus',
      '.mka' => 'audio/x-matroska',
      '.wav' || '.wave' => 'audio/wav',
      '.aiff' || '.aif' || '.aifc' => 'audio/aiff',
      '.caf' => 'audio/x-caf',
      '.pcm' || '.au' || '.snd' => 'audio/basic',
      '.wv' => 'audio/x-wavpack',
      '.ape' => 'audio/x-ape',
      '.tta' => 'audio/x-tta',
      '.tak' => 'audio/x-tak',
      '.shn' => 'audio/x-shn',
      '.dsf' || '.dff' || '.dsd' => 'audio/dsd',
      '.mlp' => 'audio/mlp',
      '.wma' => 'audio/x-ms-wma',
      '.amr' => 'audio/amr',
      '.awb' => 'audio/amr-wb',
      '.ac3' => 'audio/ac3',
      '.eac3' || '.ec3' => 'audio/eac3',
      '.dts' => 'audio/vnd.dts',
      '.mid' || '.midi' || '.kar' || '.xmf' || '.mxmf' => 'audio/midi',
      '.imy' || '.ota' || '.rtttl' || '.rtx' => 'audio/imelody',
      _ => 'audio/*',
    };
  }
}
