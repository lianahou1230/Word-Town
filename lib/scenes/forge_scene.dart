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
import 'underground_scene.dart';

class ForgeScene extends ConsumerStatefulWidget {
  const ForgeScene({super.key});

  @override
  ConsumerState<ForgeScene> createState() => _ForgeSceneState();
}

class _ForgeSceneState extends ConsumerState<ForgeScene> {
  NpcEmotion _tallowEmotion = NpcEmotion.calm;
  int _dialogIndex = 0;
  bool _showInput = false;
  bool _showSuccess = false;
  bool _showFailure = false;
  bool _showResultDialog = false;
  bool _showNextChoice = false;
  bool _showGoldenFlash = false;
  bool _isSpeaking = false;
  bool _isTypingComplete = false;
  String _userInput = '';
  final GlobalKey<SentenceInputState> _inputKey = GlobalKey<SentenceInputState>();

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('forge');
    _playForgeAmbience();
  }

  void _playForgeAmbience() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AudioManager().playSfx('forge_hit');
      }
    });
  }

  void _nextDialog() {
    if (_dialogIndex < 2) {
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
    });
    final hasKindle = input.toLowerCase().contains('kindle');

    if (hasKindle) {
      AudioManager().playSfx('success');
      setState(() {
        _showInput = false;
        _showGoldenFlash = true;
        _tallowEmotion = NpcEmotion.smile;
        _isSpeaking = true;
      });

      ref.read(gameProvider.notifier).updateWordStage('kindle', 3);
      ref.read(gameProvider.notifier).updateWordStage('ember', 2);
      ref.read(gameProvider.notifier).setKindleSuccess(true);
      ref.read(gameProvider.notifier).addReputation(3);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _showResultDialog = true;
          });
        }
      });
    } else {
      AudioManager().playSfx('failure');
      setState(() {
        _showFailure = true;
        _tallowEmotion = NpcEmotion.angry;
        _isSpeaking = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showFailure = false;
            _tallowEmotion = NpcEmotion.calm;
            _isSpeaking = false;
          });
          _inputKey.currentState?.clear();
        }
      });
    }
  }

  void _goToUnderground() {
    AudioManager().playSfx('click');
    AudioManager().playSfx('page_turn');
    AudioManager().stopBgm();
    ref.read(gameProvider.notifier).advanceTime();
    Navigator.push(
      context,
      PageTurnTransition(child: const UndergroundScene()),
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
                if (_isTypingComplete && !_showInput && !_showNextChoice && _showResultDialog) {
                  setState(() {
                    _showNextChoice = true;
                    _isTypingComplete = false;
                  });
                } else if (_isTypingComplete && !_showInput && !_showNextChoice && !_showResultDialog) {
                  _nextDialog();
                }
              },
              child: Stack(
                children: [
                  SceneBackground(
                    backgroundImage: 'assets/backgrounds/bg_forge_dusk.png',
                    timeSlot: gameState.timeOfDay,
                  ),
                  const EmbersParticlePainter(particleCount: 20),
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
                              npc: NpcData.tallow,
                              emotion: _tallowEmotion,
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
                                        '老铁匠铺，炉火噼啪。工匠 Tallow 指着炉底的 <word>embers</word>："别小看余烬，它们能在风中复燃。Cinder 就利用 ember 埋了引线。"',
                                    type: MessageType.npc,
                                    npcName: 'Tallow',
                                    onTypingComplete: () {
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('ember', 1);
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_dialogIndex >= 1)
                                  DialogBubble(
                                    text:
                                        '"我们需要 <word>kindle</word> 市民的勇气，而不是火焰。"',
                                    type: MessageType.npc,
                                    npcName: 'Tallow',
                                    onTypingComplete: () {
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('kindle', 1);
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_dialogIndex >= 2)
                                  DialogBubble(
                                    text:
                                        '✍️ 请用单词「kindle」造一个句子，最好包含"希望"或"勇气"：',
                                    type: MessageType.system,
                                    onTypingComplete: () {
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_showResultDialog)
                                  DialogBubble(
                                    text:
                                        '✅ 你说："$_userInput" Tallow 感动："对！ kindle 希望，我们就能战胜恐惧。"',
                                    type: MessageType.system,
                                    onTypingComplete: () {
                                      if (!_showNextChoice) {
                                        setState(() {
                                          _isTypingComplete = true;
                                        });
                                      }
                                    },
                                  ),
                                if (_showFailure)
                                  DialogBubble(
                                    text:
                                        '❌ "$_userInput" 中没有 kindle，Tallow 摇头。再试一次吧。',
                                    type: MessageType.system,
                                  ),
                                if (_showNextChoice) ...[
                                  DialogBubble(
                                    text:
                                        'Tallow 给了你灭火弹和 Cinder 火药库的详细入口。',
                                    type: MessageType.npc,
                                    npcName: 'Tallow',
                                  ),
                                  ChoiceButtons(
                                    options: [
                                      ChoiceOption(
                                        text: '🔥 前往地下火药库',
                                        onPressed: _goToUnderground,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (_showInput)
                          SentenceInput(
                            key: _inputKey,
                            hint: '输入你的句子...',
                            targetWord: 'kindle',
                            onSubmit: _onSubmit,
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
