import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/word.dart';

class WordDrawer extends ConsumerWidget {
  const WordDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final words = gameState.words.values.toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '词本',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.choiceButtonText,
                  fontFamily: 'Courier',
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(color: AppColors.wordBookBorder),
          Expanded(
            child: ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return _buildWordItem(word);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordItem(Word word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.parchment.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.wordBookBorder.withAlpha(100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: WordProgressPainter(stage: word.stage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getWordColor(word.stage),
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word.stage == 0 ? '???' : word.meaning,
                  style: TextStyle(
                    fontSize: 13,
                    color: word.stage == 0 ? Colors.grey.shade500 : AppColors.choiceButtonText,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStageColor(word.stage).withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStageLabel(word.stage),
              style: TextStyle(
                fontSize: 11,
                color: _getStageColor(word.stage),
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWordColor(int stage) {
    final colors = [
      Colors.grey.shade600,
      const Color(0xFFB8860B),
      const Color(0xFFCC8400),
      const Color(0xFF8B4513),
      const Color(0xFF4A6741),
    ];
    return colors[stage.clamp(0, 4)];
  }

  Color _getStageColor(int stage) {
    final colors = [
      Colors.grey.shade600,
      const Color(0xFFB8860B),
      const Color(0xFFCC8400),
      const Color(0xFF8B4513),
      const Color(0xFF4A6741),
    ];
    return colors[stage.clamp(0, 4)];
  }

  String _getStageLabel(int stage) {
    final labels = ['未接触', '已接触', '已理解', '已运用', '已掌握'];
    return labels[stage.clamp(0, 4)];
  }
}

class WordProgressPainter extends CustomPainter {
  final int stage;

  WordProgressPainter({required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final bgPaint = Paint()
      ..color = Colors.grey.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, bgPaint);

    if (stage > 0) {
      final progressPaint = Paint()
        ..color = _getStageColor(stage)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final sweepAngle = (stage / 4) * 2 * 3.14159;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  Color _getStageColor(int stage) {
    final colors = [
      Colors.grey.shade600,
      const Color(0xFFB8860B),
      const Color(0xFFCC8400),
      const Color(0xFF8B4513),
      const Color(0xFF4A6741),
    ];
    return colors[stage.clamp(0, 4)];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
