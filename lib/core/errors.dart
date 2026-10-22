/// Biznes qoidasi buzilganda tashlanadi; UI uni foydalanuvchiga ko'rsatadi.
class DomainException implements Exception {
  const DomainException(this.message);
  final String message;
  @override
  String toString() => message;
}
