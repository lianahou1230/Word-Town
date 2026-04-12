import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RedFlashOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const RedFlashOverlay({
    super.key,
    this.onComplete,
  });

  @override
  State<RedFlashOverlay> createState() => _RedFlashOverlayState();
}

class _RedFlashOverlayState extends State<RedFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 21.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 14.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 21.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 42.9,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: RadialFlashPainter(
              color: AppColors.redFlash,
              opacity: _opacityAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class RadialFlashPainter extends CustomPainter {
  final Color color;
  final double opacity;

  RadialFlashPainter({
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.9;

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        color.withAlpha((200 * opacity).toInt()),
        color.withAlpha((80 * opacity).toInt()),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => true;
}
