class StorageExceptions implements Exception {
  final String message;

  const StorageExceptions(this.message);
  @override
  String toString() {
    return message;
  }
}

class FileExistsException extends StorageExceptions {
  FileExistsException() : super('File already exists');
}
