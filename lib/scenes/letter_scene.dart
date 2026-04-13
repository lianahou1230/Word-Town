import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/scene_background.dart';
import '../widgets/top_status_bar.dart';
import '../widgets/choice_buttons.dart';
import '../widgets/page_turn_transition.dart';
import '../widgets/typed_word_widget.dart';
import '../audio/audio_manager.dart';
import 'plaza_scene.dart';
import 'ending_scene.dart';

enum EnvelopeState { closed, opening, open }

class LetterScene extends ConsumerStatefulWidget {
  const LetterScene({super.key});

  @override
  ConsumerState<LetterScene> createState() => _LetterSceneState();
}

class _LetterSceneState extends ConsumerState<LetterScene>
    with TickerProviderStateMixin {
  bool _showChoices = false;
  bool _isTypingComplete = false;
  EnvelopeState _envelopeState = EnvelopeState.closed;

  late AnimationController _envelopeController;
  late Animation<double> _lidRotation;
  late Animation<double> _lidTranslation;

  late AnimationController _paperFadeController;
  late Animation<double> _paperFadeAnimation;
  bool _isPaperExpanded = false;

  final String _letterContent = '''【城市来信】

烟火爆破师 Ephemeral 在广场表演新戏法，
烟火升空后如晨雾般消散。
他沮丧大喊："我的艺术为何总是如此 <word>ephemeral</word>！"
城里的空气似乎有些焦躁，不只是烟火的味道。

—— 城务院''';

  @override
  void initState() {
    super.initState();
    _envelopeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _lidRotation = Tween<double>(begin: 0, end: -1.5).animate(
      CurvedAnimation(parent: _envelopeController, curve: Curves.easeInOut),
    );
    _lidTranslation = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _envelopeController, curve: Curves.easeInOut),
    );

    _envelopeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _envelopeState = EnvelopeState.open;
        });
        _showLetterContent();
      }
    });

    _paperFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _paperFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _paperFadeController, curve: Curves.easeIn),
    );

    _paperFadeController.addListener(() => setState(() {}));
  }

  void _showLetterContent() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isPaperExpanded = true);
        _paperFadeController.forward();
      }
    });
  }

  void _onTypingComplete() {
    setState(() {
      _isTypingComplete = true;
    });
    ref.read(gameProvider.notifier).updateWordStage('ephemeral', 1);
  }

  void _showOptions() {
    setState(() {
      _showChoices = true;
      _isTypingComplete = false;
    });
  }

  void _openLetter() {
    if (_envelopeState != EnvelopeState.closed) return;
    setState(() => _envelopeState = EnvelopeState.opening);
    AudioManager().playBgm('letter');
    AudioManager().playSfx('letter_open');
    _envelopeController.forward();
  }

  void _goToPlaza() {
    ref.read(gameProvider.notifier).advanceTime();
    Navigator.push(
      context,
      PageTurnTransition(child: const PlazaScene()),
    );
  }

  void _goToEnding() {
    ref.read(gameProvider.notifier).setEndingType(EndingType.miss);
    Navigator.push(
      context,
      PageTurnTransition(child: const EndingScene()),
    );
  }

  @override
  void dispose() {
    _envelopeController.dispose();
    _paperFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      body: Column(
        children: [
          const TopStatusBar(),
          Expanded(
            child: SceneBackground(
              backgroundImage: 'assets/backgrounds/bg_letter_morning.png',
              timeSlot: gameState.timeOfDay,
              child: SafeArea(
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_envelopeState == EnvelopeState.open) {
      return _buildLetterPaper();
    }
    return _buildSealedLetter();
  }

  Widget _buildSealedLetter() {
    return AnimatedBuilder(
      animation: _envelopeController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _openLetter,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/scenes/letter/envelope_closed.png',
                width: 300,
                height: 220,
                fit: BoxFit.contain,
              ),
              if (_envelopeState != EnvelopeState.open)
                Positioned.fill(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, _lidTranslation.value),
                      child: Transform.rotate(
                        angle: _lidRotation.value * 3.14159 / 180,
                        child: Opacity(
                          opacity: _envelopeState == EnvelopeState.closed ? 1 : 0.5,
                          child: Image.asset(
                            'assets/scenes/letter/envelope_lid.png',
                            width: 300,
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLetterPaper() {
    return Opacity(
      opacity: _paperFadeAnimation.value,
      child: GestureDetector(
        onTap: () {
          if (_isTypingComplete && !_showChoices) {
            _showOptions();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/scenes/letter/letter_paper_bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50, 60, 50, 120),
                    child: _isPaperExpanded
                        ? TypedWordWidget(
                            text: _letterContent,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A3728),
                              fontFamily: 'Courier',
                              height: 2.0,
                              letterSpacing: 1.5,
                            ),
                            onComplete: _onTypingComplete,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              if (_showChoices)
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 40),
                  child: ChoiceButtons(
                    options: [
                      ChoiceOption(
                        text: '🎆 去广场找烟火师',
                        onPressed: _goToPlaza,
                      ),
                      ChoiceOption(
                        text: '🛌 回旅馆休息',
                        onPressed: _goToEnding,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
