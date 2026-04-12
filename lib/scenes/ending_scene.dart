import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/scene_background.dart';
import '../widgets/top_status_bar.dart';
import '../widgets/choice_buttons.dart';
import '../widgets/page_turn_transition.dart';
import '../widgets/effects/stardust_particle_painter.dart';
import '../widgets/effects/embers_particle_painter.dart';
import '../audio/audio_manager.dart';
import 'letter_scene.dart';

class EndingScene extends ConsumerStatefulWidget {
  const EndingScene({super.key});

  @override
  ConsumerState<EndingScene> createState() => _EndingSceneState();
}

class _EndingSceneState extends ConsumerState<EndingScene> {
  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('ending');
    _playEndingSound();
  }

  void _playEndingSound() {
    final endingType = ref.read(gameProvider).endingType;
    switch (endingType) {
      case EndingType.good:
        AudioManager().playSfx('crowd_cheer');
        AudioManager().playSfx('success');
        break;
      case EndingType.medium:
        AudioManager().playSfx('page_turn');
        break;
      case EndingType.bad:
      case EndingType.miss:
        AudioManager().playSfx('failure');
        break;
      default:
        break;
    }
  }

  String _getBackgroundImage(EndingType? type) {
    switch (type) {
      case EndingType.good:
        return 'assets/backgrounds/bg_ending_good.png';
      case EndingType.medium:
        return 'assets/backgrounds/bg_ending_medium.png';
      case EndingType.bad:
      case EndingType.miss:
        return 'assets/backgrounds/bg_ending_bad.png';
      default:
        return 'assets/backgrounds/bg_ending_bad.png';
    }
  }

  String _getEndingTitle(EndingType? type) {
    switch (type) {
      case EndingType.good:
        return '🏆 【好结局·重生】';
      case EndingType.medium:
        return '🌫️ 【中等结局·余烬】';
      case EndingType.bad:
        return '💀 【坏结局·灰烬】';
      case EndingType.miss:
        return '💀 【坏结局·错过】';
      default:
        return '';
    }
  }

  String _getEndingText(EndingType? type) {
    switch (type) {
      case EndingType.good:
        return '火势被完全扑灭。Ephemeral 在广场表演"重生烟火"，每一朵星尘拼出一个单词：ephemeral, kindle, salvage… 市民们举行 vigil 纪念，你成为城市守护者。';
      case EndingType.medium:
        return '街区烧毁一半，但生命得以保全。Ephemeral 在废墟上 lament，发誓重建。你已学会部分单词。';
      case EndingType.bad:
        return '全城化为焦土，Cinder 狂笑。你站在 scorch 的大地上，耳边只有 lament。城市进入灰烬时间线。';
      case EndingType.miss:
        return '你错过了所有事件，单词成为模糊记忆。';
      default:
        return '';
    }
  }

  String _getRestartText(EndingType? type) {
    switch (type) {
      case EndingType.good:
        return '🌆 重新开始';
      case EndingType.medium:
        return '🔄 重来，争取完美结局';
      case EndingType.bad:
      case EndingType.miss:
        return '🔥 重启城市';
      default:
        return '重新开始';
    }
  }

  void _restartGame() {
    AudioManager().playSfx('click');
    AudioManager().playSfx('page_turn');
    ref.read(gameProvider.notifier).resetGame();
    Navigator.pushAndRemoveUntil(
      context,
      PageTurnTransition(child: const LetterScene()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final endingType = gameState.endingType;

    return Scaffold(
      body: Column(
        children: [
          const TopStatusBar(),
          Expanded(
            child: Stack(
              children: [
                SceneBackground(
                  backgroundImage: _getBackgroundImage(endingType),
                  timeSlot: TimeSlot.morning,
                ),
                if (endingType == EndingType.good) ...[
                  const StardustParticlePainter(
                    particleCount: 40,
                    isEnding: true,
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/endings/ending_firework_word.png',
                        width: 350,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
                if (endingType == EndingType.medium) ...[
                  const EmbersParticlePainter(
                    particleCount: 15,
                    isExplosion: false,
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/endings/ending_ruin_silhouette.png',
                        width: 350,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
                if (endingType == EndingType.bad || endingType == EndingType.miss) ...[
                  const EmbersParticlePainter(
                    particleCount: 15,
                    isExplosion: false,
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/endings/ending_cinder_shadow.png',
                        width: 350,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getEndingTitle(endingType),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Courier',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _getEndingText(endingType),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'Courier',
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                ChoiceButtons(
                                  options: [
                                    ChoiceOption(
                                      text: _getRestartText(endingType),
                                      onPressed: _restartGame,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
