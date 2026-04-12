import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'scenes/letter_scene.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WordTownApp(),
    ),
  );
}

class WordTownApp extends StatelessWidget {
  const WordTownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '平行城市 · 灰烬之夜',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LetterScene(),
    );
  }
}
