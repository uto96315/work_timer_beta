import 'dart:math' as math;

/// Points gained the first time a day is worked.
const affectionGainPerDay = 8;

/// Points lost per day gone by since [UserProfile.lastWorkedDate] beyond
/// the day itself (i.e. missing exactly one day doesn't count against you
/// until the day after).
const affectionDecayPerMissedDay = 6;

const affectionMax = 100;

/// Affection level (0-100) to display, distinct from the pet's growth
/// stage (`pet_stage.dart`, driven by lifetime [UserProfile.totalFood] and
/// permanent). This reflects *recent* engagement instead: it rises with
/// consecutive days worked and decays the longer [lastWorkedDate] falls
/// behind today, so it can go back down — unlike growth, which never does.
///
/// Deliberately computed as a pure function of the stored raw points and
/// last-worked date rather than a value written on a schedule — decay
/// just falls out of how long it's been since the last write, no
/// scheduled job needed.
int displayedAffection({
  required int rawPoints,
  required String? lastWorkedDate,
  required DateTime now,
}) {
  if (lastWorkedDate == null) return 0;
  final capped = math.min(rawPoints, affectionMax);
  final last = DateTime.parse(lastWorkedDate);
  final today = DateTime(now.year, now.month, now.day);
  final missedDays = today.difference(last).inDays - 1;
  if (missedDays <= 0) return capped;
  return math.max(0, capped - missedDays * affectionDecayPerMissedDay);
}

/// Short label for a [displayedAffection] score.
String affectionLabel(int score) {
  if (score >= 71) return '大好き';
  if (score >= 41) return 'なついている';
  if (score >= 21) return '慣れてきた';
  return 'よそよそしい';
}
