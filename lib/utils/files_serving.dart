import 'dart:io';

// for example the user will ask the following http://domain.com/endpoint/folder_alias/actual-file.html
// or http://domain.com/endpoint/folder_alias/images/image.png

class FileServing {
  final List<FolderHost> folders;

  /// if true the user can view the whole content of a sub folder
  /// /folder_alias/sub-folder  , this will return the whole sub-children of that sub-folder
  /// if false this will return null, so the user can only ask for a file either it was direct child of the folder_alias or a sub file
  final bool allowServingSubFolders;

  const FileServing(
    this.folders, {
    this.allowServingSubFolders = false,
  });

  /// this will return either a file or a directory or null if there were no file nor a folder
  /// the path must be at the formula /(folder_alias)/(request_file.extension) or any other format that starts with the folder_alias then the path of the file or the sub folder
  StorageEntity? getEntityPath(String path) {
    if (path.contains('//')) return null;
    String parsedPath =
        path.startsWith('/') ? path.replaceFirst('/', '') : path;

    List<String> pathParts = parsedPath.split('/');
    String folderAlias = pathParts.first;
    String? folderPath = folders
        .cast()
        .firstWhere(
          (element) => element.alias == folderAlias,
          orElse: () => null,
        )
        .path;
    if (folderPath == null) {
      return null;
    }
    String entityPath = parsedPath + pathParts.sublist(1).join('/');
    File file = File(entityPath);
    if (file.existsSync()) {
      return StorageEntity(entityPath, StorageEntityType.file);
    }
    Directory directory = Directory(entityPath);
    if (directory.existsSync()) {
      return StorageEntity(entityPath, StorageEntityType.folder);
    }
    return null;
  }
}

class FolderHost {
  /// is the actual path for the folder you want to host
  /// should end with / <br>
  /// if not it will be added automatically to be on the format /path/to/folder/
  String path;

  /// is the alias for the folder path, will map to the actual folder path <br>
  /// path: `/folder/path` => alias: `images`
  final String alias;

  FolderHost({
    required this.path,
    required this.alias,
  }) {
    if (!isAlphaNumeric(alias)) {
      throw Exception(
          'alias must only contain numbers or letter like \'alias1\' or \'5images\'');
    }
    if (!Directory(path).existsSync()) {
      throw Exception('folder $path doesn\'t exist');
    }
    if (!path.endsWith('/')) {
      path = '$path/';
    }
  }
}

bool isAlphaNumeric(String str) {
  final pattern = RegExp(r'^[a-zA-Z0-9]+$');
  return pattern.hasMatch(str);
}

class StorageEntity {
  final StorageEntityType type;
  final String path;
  const StorageEntity(this.path, this.type);
}

enum StorageEntityType {
  file,
  folder,
}
