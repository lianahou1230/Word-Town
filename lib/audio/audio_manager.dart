import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<void> playSfx(String soundType) async {
    try {
      switch (soundType) {
        case 'click':
          await _sfxPlayer.play(AssetSource('audio/click.mp3'));
          break;
        case 'success':
          await _sfxPlayer.play(AssetSource('audio/success.mp3'));
          break;
        case 'failure':
          await _sfxPlayer.play(AssetSource('audio/failure.mp3'));
          break;
        case 'page_turn':
          await _sfxPlayer.play(AssetSource('audio/page_turn.mp3'));
          break;
        case 'word_mastered':
          await _sfxPlayer.play(AssetSource('audio/word_mastered.mp3'));
          break;
        case 'explosion':
          await _sfxPlayer.play(AssetSource('audio/explosion.mp3'));
          break;
        case 'crowd_cheer':
          await _sfxPlayer.play(AssetSource('audio/crowd_cheer.mp3'));
          break;
        case 'firework':
          await _sfxPlayer.play(AssetSource('audio/firework.mp3'));
          break;
        case 'ember':
          await _sfxPlayer.play(AssetSource('audio/ember.mp3'));
          break;
        case 'heartbeat':
          await _sfxPlayer.play(AssetSource('audio/heartbeat.mp3'));
          break;
        case 'water_drip':
          await _sfxPlayer.play(AssetSource('audio/water_drip.mp3'));
          break;
        case 'bomb_tick':
          await _sfxPlayer.play(AssetSource('audio/bomb_tick.mp3'));
          break;
        case 'whisper':
          await _sfxPlayer.play(AssetSource('audio/whisper.mp3'));
          break;
        case 'heal':
          await _sfxPlayer.play(AssetSource('audio/heal.mp3'));
          break;
        case 'dawn':
          await _sfxPlayer.play(AssetSource('audio/dawn.mp3'));
          break;
        case 'hover':
          await _sfxPlayer.play(AssetSource('audio/hover.mp3'));
          break;
        case 'type':
          await _sfxPlayer.play(AssetSource('audio/type.mp3'));
          break;
        case 'word_click':
          await _sfxPlayer.play(AssetSource('audio/word_click.mp3'));
          break;
        case 'forge_hit':
          await _sfxPlayer.play(AssetSource('audio/forge_hit.mp3'));
          break;
        case 'letter_open':
          await _sfxPlayer.play(AssetSource('audio/letter_open.mp3'));
          break;
      }
    } catch (e) {
      // 音频文件不存在时静默处理
    }
  }

  Future<void> playBgm(String scene) async {
    try {
      String bgmPath;
      switch (scene) {
        case 'letter':
          bgmPath = 'audio/bgm_letter.mp3';
          break;
        case 'plaza':
          bgmPath = 'audio/bgm_plaza.mp3';
          break;
        case 'forge':
          bgmPath = 'audio/bgm_forge.mp3';
          break;
        case 'underground':
          bgmPath = 'audio/bgm_underground.mp3';
          break;
        case 'clinic':
          bgmPath = 'audio/bgm_clinic.mp3';
          break;
        case 'ending':
          bgmPath = 'audio/bgm_ending.mp3';
          break;
        default:
          return;
      }
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource(bgmPath));
    } catch (e) {
      // 音频文件不存在时静默处理
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _bgmPlayer.dispose();
  }
}
