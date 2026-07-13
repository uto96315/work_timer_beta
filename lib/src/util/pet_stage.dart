/// The pet's growth stage, derived from lifetime food earned by working —
/// higher stages need progressively more food, so growth visibly slows
/// rather than racing through every stage in the first week.
class PetStage {
  const PetStage({
    required this.name,
    required this.emoji,
    required this.minFood,
  });

  final String name;
  final String emoji;
  final int minFood;
}

const petStages = [
  PetStage(name: '子犬', emoji: '🐶', minFood: 0),
  PetStage(name: '若犬', emoji: '🐕', minFood: 20),
  PetStage(name: '立派な犬', emoji: '🐕‍🦺', minFood: 60),
  PetStage(name: '伝説の犬', emoji: '🐩', minFood: 150),
];

/// The highest stage whose [PetStage.minFood] threshold [totalFood] meets.
PetStage stageFor(int totalFood) {
  var current = petStages.first;
  for (final stage in petStages) {
    if (totalFood < stage.minFood) break;
    current = stage;
  }
  return current;
}

/// Food still needed to reach the next stage, or null if already at the
/// highest one.
int? foodToNextStage(int totalFood) {
  for (final stage in petStages) {
    if (totalFood < stage.minFood) return stage.minFood - totalFood;
  }
  return null;
}
