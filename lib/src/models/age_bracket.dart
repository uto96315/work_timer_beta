/// 5-year age brackets rather than a raw number, to lower the input barrier
/// and make averages easier to compute.
enum AgeBracket {
  under18('18歳未満'),
  age18to19('18〜19歳'),
  age20to24('20〜24歳'),
  age25to29('25〜29歳'),
  age30to34('30〜34歳'),
  age35to39('35〜39歳'),
  age40to44('40〜44歳'),
  age45to49('45〜49歳'),
  age50to54('50〜54歳'),
  age55to59('55〜59歳'),
  age60plus('60歳以上');

  const AgeBracket(this.label);

  final String label;
}
