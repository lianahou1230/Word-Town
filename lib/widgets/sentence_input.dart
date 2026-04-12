import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../audio/audio_manager.dart';

class SentenceInput extends StatefulWidget {
  final String hint;
  final String? targetWord;
  final List<String>? targetWords;
  final VoidCallback? onSubmit;
  final Function(String)? onChanged;
  final bool enabled;

  const SentenceInput({
    super.key,
    required this.hint,
    this.targetWord,
    this.targetWords,
    this.onSubmit,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<SentenceInput> createState() => SentenceInputState();
}

class SentenceInputState extends State<SentenceInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasTargetWord = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkInput(String value) {
    AudioManager().playSfx('type');
    final lowerValue = value.toLowerCase();
    bool hasWord = false;

    if (widget.targetWord != null) {
      hasWord = lowerValue.contains(widget.targetWord!.toLowerCase());
    } else if (widget.targetWords != null) {
      hasWord = widget.targetWords!
          .every((word) => lowerValue.contains(word.toLowerCase()));
    }

    setState(() {
      _hasTargetWord = hasWord;
    });

    widget.onChanged?.call(value);
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputAreaBg,
        border: Border(
          top: BorderSide(color: AppColors.inputAreaBorder, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              onChanged: _checkInput,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Courier',
                color: AppColors.choiceButtonText,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: true,
                fillColor: AppColors.inputFieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.inputFieldBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: _hasTargetWord
                        ? AppColors.playerMessageBorder
                        : AppColors.inputFieldBorder,
                    width: _hasTargetWord ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: _hasTargetWord
                        ? AppColors.playerMessageBorder
                        : AppColors.inputFieldFocusBorder,
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: _hasTargetWord
                    ? AppColors.sendButton
                    : AppColors.sendButton.withAlpha(180),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/icon_send.png',
                    width: 20,
                    height: 20,
                    color: Colors.white,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '提交',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Courier',
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

  String get text => _controller.text;

  void clear() {
    _controller.clear();
    setState(() {
      _hasTargetWord = false;
    });
  }
}
