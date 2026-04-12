import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StardustParticlePainter extends StatefulWidget {
  final int particleCount;
  final bool isEnding;

  const StardustParticlePainter({
    super.key,
    this.particleCount = 15,
    this.isEnding = false,
  });

  @override
  State<StardustParticlePainter> createState() => _StardustParticlePainterState();
}

class _StardustParticlePainterState extends State<StardustParticlePainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<StardustParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _particles = List.generate(
      widget.particleCount,
      (index) => StardustParticle(random: _random, isEnding: widget.isEnding),
    );

    _controller.repeat();
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
        for (var particle in _particles) {
          particle.update();
        }
        return CustomPaint(
          size: Size.infinite,
          painter: StardustPainter(particles: _particles),
        );
      },
    );
  }
}

class StardustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;
  double life;
  double maxLife;
  final Random random;

  StardustParticle({required this.random, bool isEnding = false})
      : x = 0.3 + random.nextDouble() * 0.4,
        y = isEnding ? 0.4 + random.nextDouble() * 0.2 : 0.2 + random.nextDouble() * 0.3,
        vx = (random.nextDouble() - 0.5) * 0.005,
        vy = (random.nextDouble() - 0.5) * 0.005 + 0.001,
        size = 1.5 + random.nextDouble() * 2.5,
        alpha = 0.7 + random.nextDouble() * 0.3,
        life = 0,
        maxLife = 150 + random.nextDouble() * 100;

  void update() {
    x += vx;
    y += vy;
    vy += 0.00005;
    life++;
    alpha = (1 - life / maxLife) * 0.9;
    size *= 0.997;

    if (life >= maxLife || y > 1 || x < 0 || x > 1) {
      reset();
    }
  }

  void reset() {
    x = 0.3 + random.nextDouble() * 0.4;
    y = 0.2 + random.nextDouble() * 0.3;
    vx = (random.nextDouble() - 0.5) * 0.005;
    vy = (random.nextDouble() - 0.5) * 0.005 + 0.001;
    size = 1.5 + random.nextDouble() * 2.5;
    alpha = 0.7 + random.nextDouble() * 0.3;
    life = 0;
    maxLife = 150 + random.nextDouble() * 100;
  }
}

class StardustPainter extends CustomPainter {
  final List<StardustParticle> particles;

  StardustPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final px = particle.x * size.width;
      final py = particle.y * size.height;

      final color = _getParticleColor(particle.life / particle.maxLife);

      final paint = Paint()
        ..color = color.withAlpha((255 * particle.alpha).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(px, py),
        particle.size,
        paint,
      );
    }
  }

  Color _getParticleColor(double progress) {
    if (progress < 0.4) {
      return Color.lerp(
        AppColors.stardustParticleStart,
        AppColors.stardustParticleMid,
        progress / 0.4,
      )!;
    } else {
      return Color.lerp(
        AppColors.stardustParticleMid,
        AppColors.stardustParticleEnd,
        (progress - 0.4) / 0.6,
      )!;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
