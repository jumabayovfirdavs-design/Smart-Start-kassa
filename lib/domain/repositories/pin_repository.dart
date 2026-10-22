/// Parol (PIN) hash'i va tuzini saqlash shartnomasi.
abstract interface class PinRepository {
  String? get hash;
  String? get salt;
  Future<void> save({required String hash, required String salt});
}
