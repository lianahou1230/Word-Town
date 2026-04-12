enum NpcEmotion { calm, sad, angry, smile }

class Npc {
  final String id;
  final String name;
  final String displayName;

  const Npc({
    required this.id,
    required this.name,
    required this.displayName,
  });

  String getImagePath(NpcEmotion emotion) {
    final emotionStr = emotion.name;
    return 'assets/characters/$id/npc_${id}_$emotionStr.png';
  }
}

class NpcData {
  static const Npc ephemeral = Npc(
    id: 'ephemeral',
    name: 'Ephemeral',
    displayName: '烟火爆破师 Ephemeral',
  );

  static const Npc tallow = Npc(
    id: 'tallow',
    name: 'Tallow',
    displayName: '老工匠 Tallow',
  );

  static const Npc cinder = Npc(
    id: 'cinder',
    name: 'Cinder',
    displayName: 'Cinder',
  );

  static const Npc heloise = Npc(
    id: 'heloise',
    name: 'Heloise',
    displayName: '医生 Heloise',
  );
}
