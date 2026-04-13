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
import '../widgets/effects/red_flash_overlay.dart';
import '../widgets/effects/embers_particle_painter.dart';
import '../audio/audio_manager.dart';
import '../theme/app_colors.dart';
import 'clinic_scene.dart';

enum BombState { idle, selecting, confirming, success, failure }

class UndergroundScene extends ConsumerStatefulWidget {
  const UndergroundScene({super.key});

  @override
  ConsumerState<UndergroundScene> createState() => _UndergroundSceneState();
}

class _UndergroundSceneState extends ConsumerState<UndergroundScene>
    with TickerProviderStateMixin {
  NpcEmotion _cinderEmotion = NpcEmotion.smile;
  int _dialogIndex = 0;
  bool _showBombDevice = false;
  bool _showResult = false;
  bool _showNextChoice = false;
  bool _showRedFlash = false;
  bool _isExplosion = false;
  bool _isSpeaking = false;
  bool _isTypingComplete = false;
  
  BombState _bombState = BombState.idle;
  String? _answer1;
  String? _answer2;
  
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('underground');
    AudioManager().playAmbient('water_drip');
    _playWhisper();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  void _playWhisper() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AudioManager().playSfx('whisper');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _nextDialog() {
    if (_dialogIndex < 1) {
      setState(() {
        _dialogIndex++;
        _isTypingComplete = false;
      });
    } else if (!_showBombDevice && !_showResult && !_showNextChoice) {
      setState(() {
        _showBombDevice = true;
        _isTypingComplete = false;
        _bombState = BombState.selecting;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _fadeController.forward();
          AudioManager().playAmbient('bomb_tick');
        }
      });
    }
  }

  void _selectAnswer(int questionIndex, String answer) {
    AudioManager().playSfx('click');
    setState(() {
      if (questionIndex == 1) {
        _answer1 = answer;
      } else {
        _answer2 = answer;
      }
    });
  }

  void _confirm() {
    if (_answer1 == null || _answer2 == null) return;
    
    AudioManager().playSfx('click');
    AudioManager().stopAmbient();
    setState(() => _bombState = BombState.confirming);

    final isCorrect1 = _answer1!.toLowerCase() == 'ignite';
    final isCorrect2 = _answer2!.toLowerCase() == 'scorch';

    if (isCorrect1 && isCorrect2) {
      AudioManager().playSfx('success');
      setState(() {
        _bombState = BombState.success;
        _showBombDevice = false;
        _showResult = true;
        _cinderEmotion = NpcEmotion.angry;
        _isSpeaking = true;
      });

      ref.read(gameProvider.notifier).updateWordStage('ignite', 3);
      ref.read(gameProvider.notifier).updateWordStage('scorch', 3);
      ref.read(gameProvider.notifier).setBombDefused(true);
      ref.read(gameProvider.notifier).addReputation(5);

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
      AudioManager().playSfx('explosion');
      _shakeController.forward();
      setState(() {
        _bombState = BombState.failure;
        _showBombDevice = false;
        _showResult = true;
        _showRedFlash = true;
        _isExplosion = true;
        _cinderEmotion = NpcEmotion.smile;
        _isSpeaking = true;
      });

      ref.read(gameProvider.notifier).setFireSeverity(1);

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

  void _goToClinic() {
    AudioManager().stopBgm();
    AudioManager().stopAmbient();
    ref.read(gameProvider.notifier).advanceTime();
    Navigator.push(
      context,
      PageTurnTransition(child: const ClinicScene()),
    );
  }

  Widget _buildBombDevice() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _shakeController]),
      builder: (context, child) {
        final shakeOffset = _shakeAnimation.value * 10;
        return Transform.translate(
          offset: Offset(
            (shakeOffset * 2 - 10) * (_bombState == BombState.failure ? 1 : 0),
            (shakeOffset * 2 - 10) * (_bombState == BombState.failure ? 1 : 0),
          ),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.parchment,
                border: Border.all(
                  color: _bombState == BombState.success 
                      ? AppColors.sendButton 
                      : (_bombState == BombState.failure ? Colors.red : AppColors.headerBorder),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    offset: Offset(3, 3),
                    blurRadius: 6,
                  ),
                  if (_bombState == BombState.failure)
                    const BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning, 
                        color: _bombState == BombState.success ? AppColors.sendButton : Colors.red, 
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '拆除系统',
                        style: TextStyle(
                          color: AppColors.choiceButtonText,
                          fontSize: 16,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.warning, 
                        color: _bombState == BombState.success ? AppColors.sendButton : Colors.red, 
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildQuestion(
                    1,
                    '如果火柴靠近火药，会 ________ (点燃)',
                    _answer1,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildQuestion(
                    2,
                    '火灾过后，树木被 ________ (烧焦)',
                    _answer2,
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: (_answer1 != null && _answer2 != null) ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sendButton,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Color(0xFF2F5438)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      elevation: 2,
                    ),
                    child: const Text(
                      '确认拆除',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/decorations/decor_bomb_device.png',
                    width: 140,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestion(int index, String question, String? selectedAnswer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.parchmentLight,
        border: Border.all(color: AppColors.inputFieldBorder, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '填空$index：$question',
            style: const TextStyle(
              color: AppColors.choiceButtonText,
              fontSize: 14,
              fontFamily: 'Courier',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['ignite', 'scorch'].map((option) {
              final isSelected = selectedAnswer == option;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(index, option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? AppColors.wordHighlightBg : AppColors.choiceButtonBg,
                    foregroundColor: isSelected ? AppColors.wordHighlightText : AppColors.choiceButtonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppColors.wordHighlightText : AppColors.choiceButtonBorder,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    elevation: isSelected ? 3 : 1,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
                if (_isTypingComplete && !_showBombDevice && !_showNextChoice) {
                  if (_showResult && !_showNextChoice) {
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
                    backgroundImage: 'assets/backgrounds/bg_underground_night.png',
                    timeSlot: gameState.timeOfDay,
                  ),
                  Container(
                    color: Colors.black.withAlpha(80),
                  ),
                  EmbersParticlePainter(
                    particleCount: _isExplosion ? 30 : 15,
                    isExplosion: _isExplosion,
                  ),
                  if (_showRedFlash)
                    RedFlashOverlay(
                      onComplete: () => setState(() => _showRedFlash = false),
                    ),
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: NpcPortrait(
                              npc: NpcData.cinder,
                              emotion: _cinderEmotion,
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
                                        '地下火药库，Cinder 狂笑："我要 <word>ignite</word> 这场盛大的 <word>conflagration</word>，把整条街 <word>scorch</word> 成焦土！"',
                                    type: MessageType.npc,
                                    npcName: 'Cinder',
                                    onTypingComplete: () {
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('ignite', 1);
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('scorch', 1);
                                      ref
                                          .read(gameProvider.notifier)
                                          .updateWordStage('conflagration', 1);
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_dialogIndex >= 1)
                                  DialogBubble(
                                    text: '你需要拆除引爆装置。装置上有两道填空：',
                                    type: MessageType.system,
                                    onTypingComplete: () {
                                      setState(() {
                                        _isTypingComplete = true;
                                      });
                                    },
                                  ),
                                if (_showResult) ...[
                                  if (ref.watch(gameProvider).bombDefused) ...[
                                    DialogBubble(
                                      text: '✅ 装置成功拆除！Cinder 被赶来的守卫逮捕。',
                                      type: MessageType.system,
                                    ),
                                    DialogBubble(
                                      text: '虽然装置拆除，但仍有零星火点。必须立刻去诊所组织救援。',
                                      type: MessageType.system,
                                    ),
                                  ] else ...[
                                    DialogBubble(
                                      text: '⚠️ 填空错误，部分引线点燃，火势蔓延！',
                                      type: MessageType.system,
                                    ),
                                    DialogBubble(
                                      text: '爆炸波及街区，多处起火。你赶往诊所帮忙。',
                                      type: MessageType.system,
                                    ),
                                  ],
                                ],
                                if (_showNextChoice)
                                  ChoiceButtons(
                                    options: [
                                      ChoiceOption(
                                        text: '🏥 前往临时诊所',
                                        onPressed: _goToClinic,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_showBombDevice)
                          _buildBombDevice(),
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
