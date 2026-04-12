import 'package:flutter/material.dart';
import '../models/npc.dart';

class NpcPortrait extends StatefulWidget {
  final Npc npc;
  final NpcEmotion emotion;
  final bool isSpeaking;

  const NpcPortrait({
    super.key,
    required this.npc,
    required this.emotion,
    this.isSpeaking = false,
  });

  @override
  State<NpcPortrait> createState() => _NpcPortraitState();
}

class _NpcPortraitState extends State<NpcPortrait>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _speakController;
  late Animation<double> _breathAnimation;
  late Animation<double> _speakAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _breathAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _breathController.repeat(reverse: true);

    _speakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _speakAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _speakController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant NpcPortrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking && !oldWidget.isSpeaking) {
      _speakController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _speakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _speakController]),
      builder: (context, child) {
        final scale = _breathAnimation.value *
            (_speakAnimation.isAnimating ? _speakAnimation.value : 1.0);

        return Transform.scale(
          scale: scale,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Image.asset(
              widget.npc.getImagePath(widget.emotion),
              key: ValueKey('${widget.npc.id}_${widget.emotion.name}'),
              width: 280,
              height: 420,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 280,
                  height: 420,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.npc.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
