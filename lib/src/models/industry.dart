/// Broad industry categories for the workplace, used for benchmarking pay
/// against similar jobs.
enum Industry {
  foodService('飲食'),
  retail('小売・販売'),
  officeWork('事務・オフィスワーク'),
  itEngineer('IT・エンジニア'),
  education('教育'),
  medicalWelfare('医療・福祉'),
  logistics('運送・物流'),
  manufacturing('製造'),
  construction('建設'),
  serviceIndustry('サービス業'),
  agriculture('農林水産'),
  finance('金融'),
  publicServant('公務員'),
  student('学生(塾講師・家庭教師等)'),
  other('その他');

  const Industry(this.label);

  final String label;
}
