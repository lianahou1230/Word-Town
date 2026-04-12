import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import 'word_drawer.dart';

class TopStatusBar extends ConsumerWidget {
  const TopStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.headerBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.headerBorder, width: 3),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '平行城市 · 灰烬之夜',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.choiceButtonText,
                fontFamily: 'Courier',
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showWordBook(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          gameState.timeIconPath,
                          width: 16,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.access_time,
                                  color: AppColors.badgeText, size: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          gameState.timeDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.badgeText,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBackground,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/icon_reputation.png',
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.local_fire_department,
                                color: AppColors.badgeText, size: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${gameState.reputation}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.badgeText,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showWordBook(context),
                  child: Image.asset(
                    'assets/icons/icon_wordbook.png',
                    width: 28,
                    height: 28,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.menu_book,
                            color: AppColors.choiceButtonText, size: 28),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWordBook(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.wordBookBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => const WordDrawer(),
    );
  }
}
