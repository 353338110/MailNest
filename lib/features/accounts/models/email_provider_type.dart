/// Mail account providers known to the first MailNest release.
enum EmailProviderType {
  qq,
  netease163,
  netease126,
  yeah,
  tencentEnterprise,
  aliyun,
  gmail,
  outlook,
  custom;

  String get storageValue => name;
}
