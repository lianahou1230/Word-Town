import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GoldenFlashOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const GoldenFlashOverlay({
    super.key,
    this.onComplete,
  });

  @override
  State<GoldenFlashOverlay> createState() => _GoldenFlashOverlayState();
}

class _GoldenFlashOverlayState extends State<GoldenFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 37.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 62.5,
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
              color: AppColors.goldenFlash,
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
    final center = Offset(size.width / 2, size.height / 3);
    final radius = size.width * 0.8;

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        color.withAlpha((255 * opacity).toInt()),
        color.withAlpha((100 * opacity).toInt()),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
