import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/npc.dart';
import '../providers/game_provider.dart';
import '../widgets/scene_background.dart';
import '../widgets/top_status_bar.dart';
import '../widgets/dialog_bubble.dart';
import '../widgets/choice_buttons.dart';
import '../widgets/npc_portrait.dart';
import '../widgets/sentence_input.dart';
import '../widgets/page_turn_transition.dart';
import '../widgets/effects/golden_flash_overlay.dart';
import '../widgets/effects/embers_particle_painter.dart';
import '../audio/audio_manager.dart';
import 'ending_scene.dart';

class ClinicScene extends ConsumerStatefulWidget {
  const ClinicScene({super.key});

  @override
  ConsumerState<ClinicScene> createState() => _ClinicSceneState();
}

class _ClinicSceneState extends ConsumerState<ClinicScene> {
  NpcEmotion _heloiseEmotion = NpcEmotion.calm;
  int _dialogIndex = 0;
  bool _showInput = false;
  bool _showSuccess = false;
  bool _showFailure = false;
  bool _showNextChoice = false;
  bool _showGoldenFlash = false;
  bool _isSpeaking = false;
  bool _isTypingComplete = false;
  String _userInput = '';
  final GlobalKey<SentenceInputState> _inputKey = GlobalKey<SentenceInputState>();

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('clinic');
  }

  void _nextDialog() {
    if (_dialogIndex < 1) {
      setState(() {
        _dialogIndex++;
        _isTypingComplete = false;
      });
    } else if (!_showInput && !_showSuccess && !_showFailure && !_showNextChoice) {
      setState(() {
        _showInput = true;
        _isTypingComplete = false;
      });
    }
  }

  void _onSubmit() {
    AudioManager().playSfx('click');
    final input = _inputKey.currentState?.text ?? '';
    setState(() {
      _userInput = input;
      _showInput = false;
    });
    final lowerInput = input.toLowerCase();
    final hasSalvage = lowerInput.contains('salvage');
    final hasVigil = lowerInput.contains('vigil');

    if (hasSalvage && hasVigil) {
      AudioManager().playSfx('success');
      AudioManager().playSfx('crowd_cheer');
      setState(() {
        _showSuccess = true;
        _showGoldenFlash = true;
        _heloiseEmotion = NpcEmotion.smile;
        _isSpeaking = true;
      });

      ref.read(gameProvider.notifier).updateWordStage('salvage', 3);
      ref.read(gameProvider.notifier).updateWordStage('vigil', 3);
      ref.read(gameProvider.notifier).setSalvageVigilSuccess(true);
      ref.read(gameProvider.notifier).addReputation(4);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isTypingComplete = true;
          });
        }
      });
    } else {
      AudioManager().playSfx('failure');
      setState(() {
        _showFailure = true;
        _heloiseEmotion = NpcEmotion.sad;
        _isSpeaking = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isTypingComplete = true;
          });
        }
      });
    }
  }

  void _goToEnding() {
    AudioManager().playSfx('click');
    AudioManager().playSfx('page_turn');
    AudioManager().stopBgm();
    final endingType = ref.read(gameProvider.notifier).calculateEnding();
    ref.read(gameProvider.notifier).setEndingType(endingType);
    Navigator.push(
      context,
      PageTurnTransition(child: const EndingScene()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final hasFire = gameState.fireSeverity > 0;

    return Scaffold(
      body: Column(
        children: [
          const TopStatusBar(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isTypingComplete && !_showInput && !_showNextChoice) {
                  if ((_showSuccess || _showFailure) && !_showNextChoice) {
                    setState(() {
                      _showNextChoice = true;
                      _isTypingComplete = false;
                    });
                  } else {
                    _nextDialog();
                  }
                }
              },
              child: Stack(
                children: [
                  SceneBackground(
                    backgroundImage: 'assets/backgrounds/bg_clinic_latenight.png',
                    timeSlot: gameState.timeOfDay,
                  ),
                  if (hasFire)
                    const EmbersParticlePainter(
                      particleCount: 10,
                      isExplosion: false,
                    ),
                  if (_showGoldenFlash)
                    GoldenFlashOverlay(
                      onComplete: () => setState(() => _showGoldenFlash = false),
                    ),
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: NpcPortrait(
                              npc: NpcData.heloise,
                              emotion: _heloiseEmotion,
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
                                        '临时诊所，医生 Heloise 正在救治烧伤者："我们能做的只有 <word>salvage</word> 每一个生命。今晚全城都在 <word>vigil</word>，等待黎明。"',
                                    type: MessageType.npc,
                                    npcName: 'Heloise',
                                    onTypingComplete: () {
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('salvage', 1);
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('vigil', 1);
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_dialogIndex >= 1)
                                  DialogBubble(
                                    text:
                                        '你需要向市民发表演讲，鼓舞士气。请写一段简短号召，必须包含「salvage」和「vigil」。',
                                    type: MessageType.system,
                                    onTypingComplete: () {
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_showSuccess) ...[
                                  DialogBubble(
                                    text:
                                        '🗣️ 你喊道："$_userInput" 市民们士气大振，共同扑灭余火！',
                                    type: MessageType.system,
                                  ),
                                ],
                                if (_showFailure)
                                  DialogBubble(
                                    text:
                                        '⚠️ 演讲中缺少 salvage 或 vigil，部分市民逃离，损失加重。',
                                    type: MessageType.system,
                                  ),
                                if (_showNextChoice)
                                  ChoiceButtons(
                                    options: [
                                      ChoiceOption(
                                        text: '🌅 等待黎明',
                                        onPressed: _goToEnding,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_showInput)
                          SentenceInput(
                            key: _inputKey,
                            hint: '输入你的演讲...',
                            targetWords: const ['salvage', 'vigil'],
                            onSubmit: _onSubmit,
                          ),
                        Positioned(
                          bottom: 100,
                          left: 30,
                          child: Image.asset(
                            'assets/decorations/decor_vigil_candle.png',
                            width: 60,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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
