class BeldexTransactionCreationException implements Exception {
  BeldexTransactionCreationException(this.message);

  final String message;

  @override
  String toString() => message;
}
