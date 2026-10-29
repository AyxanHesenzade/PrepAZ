abstract interface class QuestionImageRepository {
  /// Şəkil üçün müvəqqəti (imzalı) link. Bucket gizlidir, ona görə birbaşa link işləmir.
  Future<String> signedUrl(String path);
}
