import 'package:flutter/material.dart';

class AppColors {
  static const Color scaffoldBackgroundStart = Color(0xFF1A2A2F);
  static const Color scaffoldBackgroundEnd = Color(0xFF0F1A1F);

  static const Color parchment = Color(0xFFFEF7E0);
  static const Color parchmentLight = Color(0xFFFFFAF0);

  static const Color headerBackground = Color(0xFFD9C8A9);
  static const Color headerBorder = Color(0xFFB49B6F);

  static const Color badgeBackground = Color(0xFF2D2B23);
  static const Color badgeText = Color(0xFFFFECB3);

  static const Color systemMessageBg = Color(0xFFE9E3D5);
  static const Color systemMessageBorder = Color(0xFFCB9E6B);

  static const Color npcMessageBg = Color(0xFFF2E5CF);
  static const Color npcMessageBorder = Color(0xFFBC8F6B);

  static const Color playerMessageBg = Color(0xFFCBE4D4);
  static const Color playerMessageBorder = Color(0xFF2F6B47);

  static const Color wordHighlightBg = Color(0xFFFFECB3);
  static const Color wordHighlightText = Color(0xFFB45309);

  static const Color choiceButtonBg = Color(0xFFE6DCC8);
  static const Color choiceButtonBorder = Color(0xFFB6A27A);
  static const Color choiceButtonText = Color(0xFF3A2C1C);
  static const Color choiceButtonPressed = Color(0xFFDACAA8);

  static const Color inputAreaBg = Color(0xFFF3ECD9);
  static const Color inputAreaBorder = Color(0xFFE1CFAA);
  static const Color inputFieldBg = Color(0xFFFFFCF5);
  static const Color inputFieldBorder = Color(0xFFCBBD96);
  static const Color inputFieldFocusBorder = Color(0xFFB47C48);
  static const Color inputFieldFocusGlow = Color(0xFFFFDD99);

  static const Color sendButton = Color(0xFF4A6741);
  static const Color sendButtonPressed = Color(0xFF2F5438);

  static const Color wordBookBg = Color(0xFFDCCFAF);
  static const Color wordBookBorder = Color(0xFFB1976B);

  static const Color resetButton = Color(0xFFAE8F64);

  static const Color goldenFlash = Color(0xFFFFD700);
  static const Color redFlash = Color(0xFFFF2222);

  static const Color emberParticleStart = Color(0xFFFF6B00);
  static const Color emberParticleMid = Color(0xFFFF2200);
  static const Color emberParticleEnd = Color(0xFF880000);

  static const Color stardustParticleStart = Color(0xFFFFD700);
  static const Color stardustParticleMid = Color(0xFFFFECB3);
  static const Color stardustParticleEnd = Color(0xFFFFFFFF);

  static const Color timeMorning = Color(0xFFFFC864);
  static const Color timeAfternoon = Color(0xFFC8B478);
  static const Color timeDusk = Color(0xFFB45028);
  static const Color timeNight = Color(0xFF140A28);
  static const Color timeLateNight = Color(0xFF0A051E);

  static const Gradient scaffoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [scaffoldBackgroundStart, scaffoldBackgroundEnd],
  );
}
