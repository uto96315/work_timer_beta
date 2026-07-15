/// How a workplace's pay is structured.
enum SalaryType {
  /// Paid per hour actually worked.
  hourly('時給制'),
  /// Fixed monthly pay, optionally including a fixed overtime allowance
  /// covering a set number of overtime hours in advance.
  monthly('月給制');

  const SalaryType(this.label);

  final String label;
}
