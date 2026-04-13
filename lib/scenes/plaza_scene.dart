import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/npc.dart';
import '../providers/game_provider.dart';
import '../widgets/scene_background.dart';
import '../widgets/top_status_bar.dart';
import '../widgets/dialog_bubble.dart';
import '../widgets/choice_buttons.dart';
import '../widgets/npc_portrait.dart';
import '../widgets/page_turn_transition.dart';
import '../widgets/effects/stardust_particle_painter.dart';
import '../audio/audio_manager.dart';
import 'forge_scene.dart';

class PlazaScene extends ConsumerStatefulWidget {
  const PlazaScene({super.key});

  @override
  ConsumerState<PlazaScene> createState() => _PlazaSceneState();
}

class _PlazaSceneState extends ConsumerState<PlazaScene> {
  NpcEmotion _ephemeralEmotion = NpcEmotion.sad;
  int _dialogIndex = 0;
  bool _showFirstChoices = false;
  bool _showSecondDialog = false;
  bool _showMapDialog = false;
  bool _showSecondChoice = false;
  bool _isSpeaking = false;
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('plaza');
    _playFirework();
  }

  void _playFirework() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        AudioManager().playSfx('firework');
      }
    });
  }

  void _nextDialog() {
    if (_dialogIndex < 1) {
      setState(() {
        _dialogIndex++;
        _isTypingComplete = false;
      });
    } else if (!_showFirstChoices && !_showSecondChoice) {
      setState(() {
        _showFirstChoices = true;
        _isTypingComplete = false;
      });
    }
  }

  void _onUnderstandCorrect() {
    AudioManager().playSfx('success');
    setState(() {
      _ephemeralEmotion = NpcEmotion.calm;
      _isSpeaking = true;
      _showFirstChoices = false;
    });

    ref.read(gameProvider.notifier).updateWordStage('lament', 2);
    ref.read(gameProvider.notifier).addReputation(2);
    ref.read(gameProvider.notifier).setLamentUnderstood(true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _showSecondDialog = true;
          _isTypingComplete = true;
        });
      }
    });
  }

  void _onUnderstandWrong() {
    AudioManager().playSfx('failure');
    setState(() {
      _ephemeralEmotion = NpcEmotion.angry;
      _isSpeaking = true;
      _showFirstChoices = false;
    });

    ref.read(gameProvider.notifier).updateWordStage('lament', 2);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _showSecondDialog = true;
          _isTypingComplete = true;
        });
      }
    });
  }

  void _showNextDialog() {
    if (_showSecondDialog && !_showMapDialog) {
      setState(() {
        _showMapDialog = true;
        _isTypingComplete = true;
      });
    } else if (_showMapDialog && !_showSecondChoice) {
      setState(() {
        _showSecondChoice = true;
        _isTypingComplete = false;
      });
    }
  }

  void _goToForge() {
    AudioManager().stopBgm();
    ref.read(gameProvider.notifier).advanceTime();
    Navigator.push(
      context,
      PageTurnTransition(child: const ForgeScene()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      body: Column(
        children: [
          const TopStatusBar(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isTypingComplete && !_showFirstChoices && !_showSecondChoice) {
                  if (_showSecondDialog) {
                    _showNextDialog();
                  } else {
                    _nextDialog();
                  }
                }
              },
              child: Stack(
                children: [
                  SceneBackground(
                    backgroundImage: 'assets/backgrounds/bg_plaza_afternoon.png',
                    timeSlot: gameState.timeOfDay,
                  ),
                  const StardustParticlePainter(particleCount: 12),
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: NpcPortrait(
                              npc: NpcData.ephemeral,
                              emotion: _ephemeralEmotion,
                              isSpeaking: _isSpeaking,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_dialogIndex >= 0)
                                  DialogBubble(
                                    text:
                                        '广场上，Ephemeral望着消散的星尘叹息："我 <word>lament</word> 那段与黑市商人的友谊，也 lament 这座城市即将面临的灾难。"',
                                    type: MessageType.npc,
                                    npcName: 'Ephemeral',
                                    onTypingComplete: () {
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('lament', 1);
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_dialogIndex >= 1)
                                  DialogBubble(
                                    text: '他告诉你，旧搭档Cinder发誓要报复，点燃整条街区。',
                                    type: MessageType.npc,
                                    npcName: 'Ephemeral',
                                    onTypingComplete: () {
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_showFirstChoices)
                                  ChoiceButtons(
                                    options: [
                                      ChoiceOption(
                                        text: '💬 "我后悔没能阻止他。"',
                                        onPressed: _onUnderstandCorrect,
                                      ),
                                      ChoiceOption(
                                        text: '😐 "我一点也不在乎。"',
                                        onPressed: _onUnderstandWrong,
                                      ),
                                    ],
                                  ),
                                if (_showSecondDialog && !_showMapDialog) ...[
                                  if (!ref.watch(gameProvider).lamentUnderstood)
                                    DialogBubble(
                                      text:
                                          'Ephemeral 失望："你没能理解 lament 的悲伤……但线索还是给你吧。"',
                                      type: MessageType.npc,
                                      npcName: 'Ephemeral',
                                    )
                                  else
                                    DialogBubble(
                                      text:
                                          'Ephemeral 点头："是的， lament 就是这种痛惜之情。"',
                                      type: MessageType.npc,
                                      npcName: 'Ephemeral',
                                    ),
                                ],
                                if (_showMapDialog && !_showSecondChoice)
                                  DialogBubble(
                                    text:
                                        'Ephemeral 递给你一张旧地图："Cinder 藏身于地下火药库，入口在老铁匠铺后面。快去！"',
                                    type: MessageType.npc,
                                    npcName: 'Ephemeral',
                                  ),
                                if (_showSecondChoice)
                                  ChoiceButtons(
                                    options: [
                                      ChoiceOption(
                                        text: '🔨 前往铁匠铺',
                                        onPressed: _goToForge,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
