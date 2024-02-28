int leftShift(int x, int n) {
  int s = n & 31;
  x = (x & 0xFFFFFFFF).toSigned(32);
  return (((x << s) | ((x & 0xFFFFFFFF) >> (32 - s))) & 0xFFFFFFFF)
      .toSigned(32);
}

List<int> hexStringToBytes(String hexString) {
  final length = hexString.length ~/ 2;
  final bytes = List<int>.filled(length, 0);
  for (int i = 0; i < length; i++) {
    final byteString = hexString.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(byteString, radix: 16);
  }
  return bytes;
}

String bytesToHexString(List<int> bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}