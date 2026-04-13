import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChoiceButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const ChoiceButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.choiceButtonPressed
              : AppColors.choiceButtonBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.choiceButtonBorder),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        transform: _isPressed
            ? Matrix4.translationValues(0, 2, 0)
            : Matrix4.identity(),
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.choiceButtonText,
            fontFamily: 'Courier',
          ),
        ),
      ),
      ),
    );
  }
}

class ChoiceButtons extends StatelessWidget {
  final List<ChoiceOption> options;

  const ChoiceButtons({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: options
            .map((option) => ChoiceButton(
                  text: option.text,
                  onPressed: option.onPressed,
                ))
            .toList(),
      ),
    );
  }
}

class ChoiceOption {
  final String text;
  final VoidCallback onPressed;

  ChoiceOption({
    required this.text,
    required this.onPressed,
  });
}
