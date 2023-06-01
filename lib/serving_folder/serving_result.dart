import 'dart:io';

import 'package:custom_shelf/serving_folder/files_serving.dart';
import 'package:path/path.dart';

abstract class ServingResult {
  late String path;
  late String parentAlias;

  /// this will return either a file path for the file <br>
  /// and List<Map<String, dynamic>> object if the request entity was a folder and the returned list contains the children info
  dynamic result();
}

class FolderResult implements ServingResult {
  final bool allowSendPath;
  @override
  List<EntityInfo> result() {
    List<EntityInfo> info = [];
    Directory directory = Directory(path);
    var children = directory.listSync();
    // ignore: unused_local_variable
    for (var child in children) {
      var stats = child.statSync();
      EntityInfo entityInfo = EntityInfo(
        path: allowSendPath ? path : null,
        name: basename(child.path),
        modified: stats.modified,
        size: stats.type == FileSystemEntityType.file ? stats.size : null,
        type: stats.type == FileSystemEntityType.file
            ? StorageEntityType.file
            : StorageEntityType.folder,
      );
      info.add(entityInfo);
    }
    return info;
  }

  @override
  String path;

  FolderResult(
    this.path, {
    required this.parentAlias,
    this.allowSendPath = false,
  });

  @override
  String parentAlias;
}

class FileResult implements ServingResult {
  @override
  String result() {
    return path;
  }

  @override
  String path;
  FileResult(
    this.path, {
    required this.parentAlias,
  });

  @override
  String parentAlias;
}

class EntityInfo {
  final String? path;
  final String name;
  final DateTime modified;
  final int? size;
  final StorageEntityType type;

  EntityInfo({
    required this.path,
    required this.name,
    required this.modified,
    required this.size,
    required this.type,
  });

  Map<String, dynamic> toJSON() {
    return {
      'path': path,
      'name': name,
      'modified': modified.toIso8601String(),
      'size': size,
      'type': type.name,
    };
  }
}
