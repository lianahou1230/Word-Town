import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/word.dart';

class TypedWordWidget extends ConsumerStatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback? onComplete;

  const TypedWordWidget({
    super.key,
    required this.text,
    required this.style,
    this.onComplete,
  });

  @override
  ConsumerState<TypedWordWidget> createState() => _TypedWordWidgetState();
}

class _TypedWordWidgetState extends ConsumerState<TypedWordWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _charProgress;
  int _displayedChars = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 40),
      vsync: this,
    );
    _charProgress = Tween<double>(begin: 0, end: widget.text.length.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.addListener(_updateCharCount);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _isComplete = true;
          _displayedChars = widget.text.length;
        });
        widget.onComplete?.call();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  void _updateCharCount() {
    if (mounted) {
      setState(() {
        _displayedChars = _charProgress.value.floor().clamp(0, widget.text.length);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCharCount);
    _controller.dispose();
    super.dispose();
  }

  void _skipTyping() {
    if (!_isComplete && mounted) {
      _controller.forward(from: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skipTyping,
      child: Consumer(
        builder: (context, ref, child) {
          final displayedText = widget.text.substring(0, _displayedChars);
          final spans = _buildSpans(context, ref, displayedText);

          return RichText(
            text: TextSpan(children: spans),
          );
        },
      ),
    );
  }

  List<TextSpan> _buildSpans(BuildContext context, WidgetRef ref, String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'<word>(\w+)</word>');
    final matches = regex.allMatches(text);

    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: widget.style,
        ));
      }

      final word = match.group(1)!;
      spans.add(TextSpan(
        text: word,
        style: widget.style.copyWith(
          backgroundColor: AppColors.wordHighlightBg,
          color: AppColors.wordHighlightText,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _showWordDefinition(context, ref, word),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: widget.style,
      ));
    }

    if (!_isComplete && _displayedChars > 0) {
      spans.add(TextSpan(
        text: '|',
        style: widget.style.copyWith(color: AppColors.wordHighlightText),
      ));
    }

    return spans;
  }

  String _getSingularWord(String word) {
    final lowerWord = word.toLowerCase();
    
    if (lowerWord.endsWith('ies') && lowerWord.length > 3) {
      return lowerWord.substring(0, lowerWord.length - 3) + 'y';
    }
    if (lowerWord.endsWith('es') && lowerWord.length > 2) {
      final withoutEs = lowerWord.substring(0, lowerWord.length - 2);
      if (withoutEs.endsWith('s') || withoutEs.endsWith('sh') || 
          withoutEs.endsWith('ch') || withoutEs.endsWith('x') || 
          withoutEs.endsWith('z')) {
        return withoutEs;
      }
    }
    if (lowerWord.endsWith('s') && lowerWord.length > 1) {
      return lowerWord.substring(0, lowerWord.length - 1);
    }
    return lowerWord;
  }

  Word _findWordData(Map<String, Word> words, String word) {
    final lowerWord = word.toLowerCase();
    
    if (lowerWord == 'embers') {
      return words['ember']!;
    }
    
    if (words.containsKey(lowerWord)) {
      return words[lowerWord]!;
    }
    
    final singularWord = _getSingularWord(word);
    if (singularWord != lowerWord && words.containsKey(singularWord)) {
      return words[singularWord]!;
    }
    
    return Word(word: word, meaning: '未知');
  }

  void _showWordDefinition(BuildContext context, WidgetRef ref, String word) {
    final gameState = ref.read(gameProvider);
    final wordData = _findWordData(gameState.words, word);

    // 只更新实际找到的单数形式，不创建新的复数条目
    final targetWord = wordData.word.toLowerCase();
    ref.read(gameProvider.notifier).updateWordStage(targetWord, 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.wordBookBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.wordHighlightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    wordData.word,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.wordHighlightText,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildStageIndicator(wordData.stage),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              wordData.stage == 0 ? '???' : wordData.meaning,
              style: TextStyle(
                fontSize: 16,
                color: wordData.stage == 0 ? Colors.grey.shade500 : AppColors.choiceButtonText,
                fontFamily: 'Courier',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sendButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageIndicator(int stage) {
    final colors = [
      Colors.grey.shade600,
      const Color(0xFFB8860B),
      const Color(0xFFCC8400),
      const Color(0xFF8B4513),
      const Color(0xFF4A6741),
    ];
    final labels = ['未接触', '已接触', '已理解', '已运用', '已掌握'];

    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: colors[stage.clamp(0, 4)]),
        const SizedBox(width: 4),
        Text(
          labels[stage.clamp(0, 4)],
          style: TextStyle(
            fontSize: 12,
            color: colors[stage.clamp(0, 4)],
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}
