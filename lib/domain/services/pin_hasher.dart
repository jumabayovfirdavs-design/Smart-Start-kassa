/// Hash algoritmi domain'dan ajratilgan (DIP): infrastructure'da amalga oshiriladi.
abstract interface class PinHasher {
  String hash(String pin, String salt);
}
