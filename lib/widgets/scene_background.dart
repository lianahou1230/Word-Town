import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/game_state.dart';

class SceneBackground extends StatelessWidget {
  final String backgroundImage;
  final TimeSlot timeSlot;
  final Widget? child;

  const SceneBackground({
    super.key,
    required this.backgroundImage,
    required this.timeSlot,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          backgroundImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.scaffoldBackgroundStart,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                _getTimeColor().withAlpha(_getAlpha()),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.parchment.withAlpha(100),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        ?child,
      ],
    );
  }

  Color _getTimeColor() {
    switch (timeSlot) {
      case TimeSlot.morning:
        return AppColors.timeMorning;
      case TimeSlot.afternoon:
        return AppColors.timeAfternoon;
      case TimeSlot.dusk:
        return AppColors.timeDusk;
      case TimeSlot.night:
        return AppColors.timeNight;
      case TimeSlot.lateNight:
        return AppColors.timeLateNight;
    }
  }

  int _getAlpha() {
    switch (timeSlot) {
      case TimeSlot.morning:
        return 38;
      case TimeSlot.afternoon:
        return 25;
      case TimeSlot.dusk:
        return 51;
      case TimeSlot.night:
        return 102;
      case TimeSlot.lateNight:
        return 128;
    }
  }
}
