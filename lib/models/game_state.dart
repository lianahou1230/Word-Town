import 'word.dart';

enum SceneId { letter, plaza, forge, underground, clinic, ending }

enum TimeSlot { morning, afternoon, dusk, night, lateNight }

enum EndingType { good, medium, bad, miss }

class GameState {
  final SceneId currentScene;
  final TimeSlot timeOfDay;
  final int reputation;
  final Map<String, Word> words;

  final bool kindleSuccess;
  final bool bombDefused;
  final bool salvageVigilSuccess;
  final int fireSeverity;
  final bool endingTriggered;

  final EndingType? endingType;
  final bool lamentUnderstood;

  const GameState({
    this.currentScene = SceneId.letter,
    this.timeOfDay = TimeSlot.morning,
    this.reputation = 0,
    required this.words,
    this.kindleSuccess = false,
    this.bombDefused = false,
    this.salvageVigilSuccess = false,
    this.fireSeverity = 0,
    this.endingTriggered = false,
    this.endingType,
    this.lamentUnderstood = false,
  });

  GameState copyWith({
    SceneId? currentScene,
    TimeSlot? timeOfDay,
    int? reputation,
    Map<String, Word>? words,
    bool? kindleSuccess,
    bool? bombDefused,
    bool? salvageVigilSuccess,
    int? fireSeverity,
    bool? endingTriggered,
    EndingType? endingType,
    bool? lamentUnderstood,
  }) {
    return GameState(
      currentScene: currentScene ?? this.currentScene,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      reputation: reputation ?? this.reputation,
      words: words ?? this.words,
      kindleSuccess: kindleSuccess ?? this.kindleSuccess,
      bombDefused: bombDefused ?? this.bombDefused,
      salvageVigilSuccess: salvageVigilSuccess ?? this.salvageVigilSuccess,
      fireSeverity: fireSeverity ?? this.fireSeverity,
      endingTriggered: endingTriggered ?? this.endingTriggered,
      endingType: endingType ?? this.endingType,
      lamentUnderstood: lamentUnderstood ?? this.lamentUnderstood,
    );
  }

  int get successCount {
    int count = 0;
    if (kindleSuccess) count++;
    if (bombDefused) count++;
    if (salvageVigilSuccess) count++;
    return count;
  }

  String get timeDisplay {
    switch (timeOfDay) {
      case TimeSlot.morning:
        return '清晨';
      case TimeSlot.afternoon:
        return '午后';
      case TimeSlot.dusk:
        return '黄昏';
      case TimeSlot.night:
        return '夜晚';
      case TimeSlot.lateNight:
        return '深夜';
    }
  }

  String get timeIconPath {
    switch (timeOfDay) {
      case TimeSlot.morning:
        return 'assets/icons/icon_morning.png';
      case TimeSlot.afternoon:
        return 'assets/icons/icon_afternoon.png';
      case TimeSlot.dusk:
        return 'assets/icons/icon_dusk.png';
      case TimeSlot.night:
        return 'assets/icons/icon_night.png';
      case TimeSlot.lateNight:
        return 'assets/icons/icon_latenight.png';
    }
  }
}
