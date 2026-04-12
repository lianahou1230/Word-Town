import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'word_highlight_span.dart';

enum MessageType { system, npc, player }

class DialogBubble extends StatefulWidget {
  final String text;
  final MessageType type;
  final String? npcName;
  final VoidCallback? onTypingComplete;
  final VoidCallback? onTap;

  const DialogBubble({
    super.key,
    required this.text,
    required this.type,
    this.npcName,
    this.onTypingComplete,
    this.onTap,
  });

  @override
  State<DialogBubble> createState() => _DialogBubbleState();
}

class _DialogBubbleState extends State<DialogBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    final duration = widget.text.isEmpty ? 100 : widget.text.length * 40;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );
    _charCount = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _charCount.addListener(() {
      if (mounted) {
        setState(() {
          _displayText = widget.text.substring(0, _charCount.value.clamp(0, widget.text.length));
        });
      }
    });
    _controller.addStatusListener(_onAnimationStatusChanged);
    if (widget.text.isEmpty) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      widget.onTypingComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void skipTyping() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.stop();
      if (mounted) {
        setState(() {
          _displayText = widget.text;
        });
      }
      widget.onTypingComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.status != AnimationStatus.completed) {
          skipTyping();
        } else {
          widget.onTap?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border(
            left: BorderSide(
              color: _getBorderColor(),
              width: 6,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.npcName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.npcName!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.choiceButtonText,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            WordHighlightSpan(
              text: _displayText,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.choiceButtonText,
                fontFamily: 'Courier',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case MessageType.system:
        return AppColors.systemMessageBg;
      case MessageType.npc:
        return AppColors.npcMessageBg;
      case MessageType.player:
        return AppColors.playerMessageBg;
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case MessageType.system:
        return AppColors.systemMessageBorder;
      case MessageType.npc:
        return AppColors.npcMessageBorder;
      case MessageType.player:
        return AppColors.playerMessageBorder;
    }
  }
}
