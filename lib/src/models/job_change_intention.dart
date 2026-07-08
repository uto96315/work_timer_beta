/// How actively the user is considering changing jobs, from most to least
/// eager.
enum JobChangeIntention {
  rightAway('今すぐ転職したい'),
  soon('近いうちに転職したい'),
  ifGoodOffer('良い所があれば考える'),
  notMuch('あまり考えていない'),
  notAtAll('全く考えていない');

  const JobChangeIntention(this.label);

  final String label;
}
