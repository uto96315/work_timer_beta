enum Gender {
  male('男性'),
  female('女性'),
  other('その他'),
  preferNotToSay('回答しない');

  const Gender(this.label);

  final String label;
}
