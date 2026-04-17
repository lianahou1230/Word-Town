import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/word.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
      : super(GameState(
          words: Map.from(WordData.words),
        ));

  void resetGame() {
    state = GameState(
      words: Map.from(WordData.words),
    );
  }

  void advanceScene(SceneId scene) {
    state = state.copyWith(currentScene: scene);
  }

  void advanceTime() {
    final order = [
      TimeSlot.morning,
      TimeSlot.afternoon,
      TimeSlot.dusk,
      TimeSlot.night,
      TimeSlot.lateNight,
    ];
    final idx = order.indexOf(state.timeOfDay);
    if (idx != -1 && idx < order.length - 1) {
      state = state.copyWith(timeOfDay: order[idx + 1]);
    }
  }

  void updateWordStage(String wordKey, int stage) {
    final newWords = Map<String, Word>.from(state.words);
    if (newWords.containsKey(wordKey)) {
      final currentStage = newWords[wordKey]!.stage;
      if (stage > currentStage) {
        newWords[wordKey] = newWords[wordKey]!.copyWith(stage: stage);
        state = state.copyWith(words: newWords);
      }
    }
  }

  void addReputation(int value) {
    state = state.copyWith(reputation: state.reputation + value);
  }

  void setKindleSuccess(bool value) {
    state = state.copyWith(kindleSuccess: value);
  }

  void setBombDefused(bool value) {
    state = state.copyWith(bombDefused: value);
  }

  void setSalvageVigilSuccess(bool value) {
    state = state.copyWith(salvageVigilSuccess: value);
  }

  void setFireSeverity(int value) {
    state = state.copyWith(fireSeverity: value);
  }

  void setEndingTriggered(bool value) {
    state = state.copyWith(endingTriggered: value);
  }

  void setEndingType(EndingType type) {
    state = state.copyWith(endingType: type, endingTriggered: true);
  }

  void setLamentUnderstood(bool value) {
    state = state.copyWith(lamentUnderstood: value);
  }

  EndingType calculateEnding() {
    final successCount = state.successCount;

    if (state.bombDefused &&
        state.salvageVigilSuccess &&
        successCount >= 3) {
      return EndingType.good;
    } else if (successCount >= 1) {
      return EndingType.medium;
    } else {
      return EndingType.bad;
    }
  }

  List<String> getLearnedWords() {
    return state.words.entries
        .where((e) => e.value.stage >= 3)
        .map((e) => e.key)
        .toList();
  }

  List<String> getPartialWords() {
    return state.words.entries
        .where((e) => e.value.stage >= 1 && e.value.stage < 3)
        .map((e) => '${e.key}✓')
        .toList();
  }
}
