/// How the user is employed at a workplace.
enum EmploymentType {
  partTimeArbeit('アルバイト'),
  partTime('パート'),
  fullTime('正社員'),
  contract('契約社員'),
  temporary('派遣'),
  other('その他');

  const EmploymentType(this.label);

  final String label;
}
