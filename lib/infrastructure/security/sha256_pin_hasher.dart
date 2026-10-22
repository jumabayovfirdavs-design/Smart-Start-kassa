import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/services/pin_hasher.dart';

class Sha256PinHasher implements PinHasher {
  const Sha256PinHasher();
  @override
  String hash(String pin, String salt) => sha256.convert(utf8.encode('educore:$salt:$pin')).toString();
}
