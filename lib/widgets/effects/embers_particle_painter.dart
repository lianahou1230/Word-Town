import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EmbersParticlePainter extends StatefulWidget {
  final int particleCount;
  final bool isExplosion;

  const EmbersParticlePainter({
    super.key,
    this.particleCount = 20,
    this.isExplosion = false,
  });

  @override
  State<EmbersParticlePainter> createState() => _EmbersParticlePainterState();
}

class _EmbersParticlePainterState extends State<EmbersParticlePainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<EmberParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _particles = List.generate(
      widget.particleCount,
      (index) => EmberParticle(random: _random, isExplosion: widget.isExplosion),
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
          painter: EmbersPainter(particles: _particles),
        );
      },
    );
  }
}

class EmberParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;
  double life;
  double maxLife;
  double phase;
  final Random random;

  EmberParticle({required this.random, bool isExplosion = false})
      : x = random.nextDouble(),
        y = isExplosion ? 0.5 + random.nextDouble() * 0.3 : 1.0,
        vx = (random.nextDouble() - 0.5) * 0.002,
        vy = isExplosion
            ? (random.nextDouble() - 0.5) * 0.01
            : -(0.002 + random.nextDouble() * 0.003),
        size = 2.0 + random.nextDouble() * 4.0,
        alpha = 0.6 + random.nextDouble() * 0.4,
        life = 0,
        maxLife = 200 + random.nextDouble() * 100,
        phase = random.nextDouble() * pi * 2;

  void update() {
    x += vx + sin(life * 0.02 + phase) * 0.001;
    y += vy;
    life++;
    alpha = (1 - life / maxLife) * 0.8;
    size *= 0.998;

    if (life >= maxLife || y < 0 || y > 1 || x < 0 || x > 1) {
      reset();
    }
  }

  void reset() {
    x = random.nextDouble();
    y = 1.0;
    vx = (random.nextDouble() - 0.5) * 0.002;
    vy = -(0.002 + random.nextDouble() * 0.003);
    size = 2.0 + random.nextDouble() * 4.0;
    alpha = 0.6 + random.nextDouble() * 0.4;
    life = 0;
    maxLife = 200 + random.nextDouble() * 100;
    phase = random.nextDouble() * pi * 2;
  }
}

class EmbersPainter extends CustomPainter {
  final List<EmberParticle> particles;

  EmbersPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final px = particle.x * size.width;
      final py = particle.y * size.height;

      final color = _getParticleColor(particle.life / particle.maxLife);

      final paint = Paint()
        ..color = color.withAlpha((255 * particle.alpha).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(px, py),
        particle.size,
        paint,
      );
    }
  }

  Color _getParticleColor(double progress) {
    if (progress < 0.3) {
      return Color.lerp(
        AppColors.emberParticleStart,
        AppColors.emberParticleMid,
        progress / 0.3,
      )!;
    } else {
      return Color.lerp(
        AppColors.emberParticleMid,
        AppColors.emberParticleEnd,
        (progress - 0.3) / 0.7,
      )!;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
