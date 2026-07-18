/// Displayed pet age as "0歳3ヶ月" counted up from [bornAt] (when the pet's
/// UserProfile.petBornAt was first set — effectively install date) rather
/// than tied to the food-based growth stage.
String petAgeLabel(DateTime bornAt, DateTime now) {
  var totalMonths =
      (now.year - bornAt.year) * 12 + (now.month - bornAt.month);
  if (now.day < bornAt.day) totalMonths -= 1;
  if (totalMonths < 0) totalMonths = 0;
  final years = totalMonths ~/ 12;
  final months = totalMonths % 12;
  return '$years歳$monthsヶ月';
}
