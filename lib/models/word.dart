class Word {
  final String word;
  final String meaning;
  int stage;

  Word({
    required this.word,
    required this.meaning,
    this.stage = 0,
  });

  Word copyWith({
    String? word,
    String? meaning,
    int? stage,
  }) {
    return Word(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      stage: stage ?? this.stage,
    );
  }
}

class WordData {
  static final Map<String, Word> words = {
    'ephemeral': Word(word: 'ephemeral', meaning: '短暂的，转瞬即逝的'),
    'lament': Word(word: 'lament', meaning: '哀悼，痛惜'),
    'ember': Word(word: 'ember', meaning: '余烬，未熄的火种'),
    'kindle': Word(word: 'kindle', meaning: '点燃（火焰/情感）；激发'),
    'ignite': Word(word: 'ignite', meaning: '点燃，引发'),
    'scorch': Word(word: 'scorch', meaning: '烧焦，烤焦'),
    'conflagration': Word(word: 'conflagration', meaning: '大火，毁灭性火灾'),
    'salvage': Word(word: 'salvage', meaning: '抢救，挽回'),
    'vigil': Word(word: 'vigil', meaning: '守夜，守望'),
  };

  static Word getWord(String key) {
    return words[key] ?? Word(word: key, meaning: '未知');
  }
}
