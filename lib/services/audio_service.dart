import 'package:audioplayers/audioplayers.dart';

/// Manages all audio players for the game.
class AudioService {
  final _bgmPlayer = AudioPlayer();
  final _sfxPlayer = AudioPlayer();
  final _coinPlayer = AudioPlayer();

  static final _sfxContext = AudioContext(
    android: const AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioMode: AndroidAudioMode.normal,
    ),
  );

  Future<void> playBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(1.0);
    await _bgmPlayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gain,
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioMode: AndroidAudioMode.normal,
        ),
      ),
    );
    await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));
  }

  Future<void> stopBgm() => _bgmPlayer.stop();

  Future<void> playSfx(String file, {bool loop = false}) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.setReleaseMode(
      loop ? ReleaseMode.loop : ReleaseMode.release,
    );
    await _sfxPlayer.setVolume(1.0);
    await _sfxPlayer.setAudioContext(_sfxContext);
    await _sfxPlayer.play(AssetSource('sounds/$file'));
  }

  Future<void> stopSfx() => _sfxPlayer.stop();

  Future<void> playCoin() async {
    await _coinPlayer.stop();
    await _coinPlayer.setReleaseMode(ReleaseMode.release);
    await _coinPlayer.setVolume(1.0);
    await _coinPlayer.setAudioContext(_sfxContext);
    await _coinPlayer.play(AssetSource('sounds/coin.mp3'));
  }

  Future<void> stopCoin() => _coinPlayer.stop();

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _coinPlayer.dispose();
  }
}
