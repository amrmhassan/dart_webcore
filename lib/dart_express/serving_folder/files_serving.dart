import 'dart:io';

import 'serving_result.dart';

// for example the user will ask the following http://domain.com/endpoint/folder_alias/actual-file.html
// or http://domain.com/endpoint/folder_alias/images/image.png

class FileServing {
  final List<FolderHost> _folders;
  final bool _allowServingSubFolders;
  final bool _allowViewingEntityPath;

  const FileServing(
    this._folders, {
    bool allowServingSubFolders = false,

    /// if true the user can view the whole content of a sub folder
    /// /folder_alias/sub-folder  , this will return the whole sub-children of that sub-folder
    /// if false this will return null, so the user can only ask for a file either it was direct child of the folder_alias or a sub file
    bool allowViewingEntityPath = false,
  })  : _allowServingSubFolders = allowServingSubFolders,
        _allowViewingEntityPath = allowViewingEntityPath
  //
  ;

  StorageEntity? _getEntityPath(String passedPath) {
    String parsedPath = passedPath.replaceAll('//', '/');
    parsedPath = parsedPath.startsWith('/')
        ? parsedPath.replaceFirst('/', '')
        : parsedPath;

    List<String> pathParts = parsedPath.split('/');
    String folderAlias = pathParts.first;
    FolderHost? folderHost = _folders.cast().firstWhere(
          (element) => element.alias == folderAlias,
          orElse: () => null,
        );
    if (folderHost == null) {
      return null;
    }
    String entityPath = folderHost.path + pathParts.sublist(1).join('/');
    File file = File(entityPath);
    if (file.existsSync()) {
      return StorageEntity(entityPath, StorageEntityType.file,
          parentAlias: folderHost.alias);
    }
    Directory directory = Directory(entityPath);
    if (directory.existsSync() && _allowServingSubFolders) {
      return StorageEntity(
        entityPath,
        StorageEntityType.folder,
        parentAlias: folderHost.alias,
      );
    }
    return null;
  }

  /// this will return either a file or a directory or null if there were no file nor a folder
  /// the path must be at the formula /(folder_alias)/(request_file.extension) or any other format that starts with the folder_alias then the path of the file or the sub folder
  ServingResult? serveResult(String path) {
    StorageEntity? entity = _getEntityPath(path);
    if (entity == null) {
      return null;
    }
    if (entity.type == StorageEntityType.folder) {
      return FolderResult(
        entity.path,
        allowSendPath: _allowViewingEntityPath,
        parentAlias: entity.parentAlias,
      );
    } else if (entity.type == StorageEntityType.file) {
      return FileResult(
        entity.path,
        parentAlias: entity.parentAlias,
      );
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
    isFolderAliasValid(alias);

    if (!Directory(path).existsSync()) {
      throw Exception('folder $path doesn\'t exist');
    }
    if (!path.endsWith('/')) {
      path = '$path/';
    }
  }
}

class StorageEntity {
  final StorageEntityType type;
  final String path;
  final String parentAlias;
  const StorageEntity(
    this.path,
    this.type, {
    required this.parentAlias,
  });

  @override
  String toString() {
    return 'path: $path \ntype: ${type.name}\nparentAlias: $parentAlias';
  }
}

enum StorageEntityType {
  file,
  folder,
}

void isFolderAliasValid(String str) {
  if (str.isEmpty) {
    throw Exception('alias can\'t be empty');
  }
  String specialChars = '/=?& ';

  var chars = specialChars.split('');
  for (var i = 0; i < chars.length; i++) {
    var char = chars[i];
    if (str.contains(char)) {
      throw Exception(
          'folder alias can\'t contain special chars from $specialChars');
    }
  }
}
