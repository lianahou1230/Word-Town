import 'package:flutter/material.dart';
import 'dialog_bubble.dart';

class DialogItem {
  final String text;
  final MessageType type;
  final String? npcName;
  final VoidCallback? onComplete;

  DialogItem({
    required this.text,
    required this.type,
    this.npcName,
    this.onComplete,
  });
}

class SequentialDialog extends StatefulWidget {
  final List<DialogItem> dialogs;
  final Widget? afterDialogs;

  const SequentialDialog({
    super.key,
    required this.dialogs,
    this.afterDialogs,
  });

  @override
  State<SequentialDialog> createState() => _SequentialDialogState();
}

class _SequentialDialogState extends State<SequentialDialog> {
  int _currentIndex = 0;

  void _onDialogComplete() {
    if (_currentIndex < widget.dialogs.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i <= _currentIndex && i < widget.dialogs.length; i++)
          DialogBubble(
            text: widget.dialogs[i].text,
            type: widget.dialogs[i].type,
            npcName: widget.dialogs[i].npcName,
            onTypingComplete: i == _currentIndex
                ? () {
                    widget.dialogs[i].onComplete?.call();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted && i == _currentIndex) {
                        _onDialogComplete();
                      }
                    });
                  }
                : null,
          ),
        if (_currentIndex >= widget.dialogs.length - 1 && widget.afterDialogs != null)
          widget.afterDialogs!,
      ],
    );
  }
}
