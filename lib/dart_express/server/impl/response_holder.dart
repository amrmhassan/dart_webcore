import 'dart:async';
import 'dart:io';

import 'dart:convert' as convert;

import 'package:mime/mime.dart';

import '../../serving_folder/files_serving.dart';
import '../../serving_folder/serving_result.dart';
import '../../utils/response_utils.dart';
import '../repo/passed_http_entity.dart';

class ResponseHolder extends PassedHttpEntity {
  final HttpRequest request;
  HttpResponse get response => request.response;

  ResponseHolder(this.request);
  bool closed = false;
  String? closeMessage;
  dynamic closeData;

  Future<ResponseHolder> close({String? closeMessage}) async {
    try {
      closeData = await response.close();
      closed = true;
      closeMessage = closeMessage;
    } catch (e) {
      //
    }
    return this;
  }

  ResponseHolder write(Object? object, {int? code}) {
    if (code != null) {
      response.statusCode = code;
    }
    response.write(object);
    return this;
  }

  ResponseHolder add(List<int> data) {
    response.headers.contentLength = data.length;
    response.add(data);
    return this;
  }

  ResponseHolder writeJson(dynamic obj, {int? code}) {
    response.headers.contentType = ContentType.json;
    return write(convert.json.encode(obj), code: code);
  }

  ResponseHolder writeHtml(String html, {int? code}) {
    response.headers.contentType = ContentType.html;
    return write(html, code: code);
  }

  ResponseHolder writeBinary(List<int> bytes) {
    response.headers.contentType = ContentType.binary;
    return add(bytes);
  }

  final ResponseUtils _responseUtils = ResponseUtils();

  Future<ResponseHolder> writeFile(String filePath) async {
    _responseUtils.sendChunkedFile(request, filePath);
    return this;
  }

  Future<ResponseHolder> streamMedia(String filePath) async {
    await _responseUtils.streamV2(request, filePath);
    return this;
  }

  // Future<String> receiveFile(
  //   /// the folder for saving the received file
  //   String saveFolderPath, {
  //   /// if null all file types are allowed
  //   List<String>? allowedTypes,

  //   /// if null there will be no size limit
  //   int? maxAllowedSize,
  // }) async {
  //   return _responseUtils.receiveFile(request, saveFolderPath);
  // }

  Future<ResponseHolder> addStream(Stream<List<int>> stream) async {
    await response.addStream(stream);
    return this;
  }

  //? original response properties
  late HttpHeaders headers = response.headers;
  // late bool bufferOutput = response.bufferOutput;
  // late HttpConnectionInfo? connectionInfo = response.connectionInfo;
  // late int contentLength = response.contentLength;
  // late List<Cookie> cookies = response.cookies;
  // late Duration? deadline = response.deadline;
  // late bool persistentConnection = response.persistentConnection;
  // late String reasonPhrase = response.reasonPhrase;
  // late int statusCode = response.statusCode;

  FutureOr<ResponseHolder> serveFolders(
    List<FolderHost> folders,

    /// this will be on the format alias/path-to-request-entity-file-or-folder
    String requestedEntityPath, {
    bool allowServingFoldersContent = false,

    /// if true the user can view the whole content of a sub folder
    /// /folder_alias/sub-folder  , this will return the whole sub-children of that sub-folder
    /// if false this will return null, so the user can only ask for a file either it was direct child of the folder_alias or a sub file
    bool allowViewingEntityPath = false,

    /// if true , then text based files like html, css, js or txt files will be viewed on the browser instead of downloading them
    /// if false all kind of files will be downloaded to the browser
    bool viewTextBasedFiles = true,

    /// if true, then if the user request to view a folder content and this folder contains a file named index.html or index.htm then this file will be viewed
    /// instead of viewing the folder content, this is useful if you are serving a html website
    /// viewTextBasedFiles must be true for this parameter to have effect
    /// allowServingFoldersContent must be true for this to take effect
    bool autoViewIndexTextFiles = true,

    /// these are the text files names which will be automatically viewed if their parent folder was requested
    List<String> autoViewIndexFilesNames = const [
      'index.html',
      'index.htm',
    ],
  }) async {
    if (autoViewIndexTextFiles) {
      _checkTextFilesNames(autoViewIndexFilesNames);
    }
    FileServing fileServing = FileServing(
      folders,
      allowServingSubFolders: allowServingFoldersContent,
      allowViewingEntityPath: allowViewingEntityPath,
    );

    var result = fileServing.serveResult(requestedEntityPath);
    if (result is FolderResult) {
      return _handlerAutoViewHtml(
        result,
        autoViewIndexHtml: autoViewIndexTextFiles,
        viewTextBasedFiles: viewTextBasedFiles,
        autoViewNames: autoViewIndexFilesNames,
      );
    } else if (result is FileResult) {
      // String? mimeType = lookupMimeType(result.result());

      // bool textBased = mimeType != null && mimeType.startsWith('text');
      return streamMedia(result.result());
      // if (viewTextBasedFiles && textBased) {
      // } else {
      //   return writeFile(result.result());
      // }
    }

    write(
      'file or folder not found',
      code: HttpStatus.notFound,
    );
    await response.close();
    return this;
  }

  void _checkTextFilesNames(List<String> names) {
    for (var name in names) {
      String? mime = lookupMimeType(name);
      if (mime == null) {
        throw Exception('please enter only text file name');
      }
      if (!mime.startsWith('text')) {
        throw Exception('please enter only text file name');
      }
    }
  }

  FutureOr<ResponseHolder> _handlerAutoViewHtml(
    FolderResult folderResult, {
    required bool autoViewIndexHtml,
    required bool viewTextBasedFiles,
    required List<String> autoViewNames,
  }) {
    if (!autoViewIndexHtml || !viewTextBasedFiles) {
      var res = folderResult.result().map((e) => e.toJSON()).toList();

      return writeJson(res);
    }

    String? indexHtmlPath = _getHtmlIndexFile(
      folderResult,
      autoViewNames: autoViewNames,
    );
    if (indexHtmlPath == null) {
      var res = folderResult.result().map((e) => e.toJSON()).toList();

      return writeJson(res);
    } else {
      return streamMedia(indexHtmlPath);
    }
  }

  String? _getHtmlIndexFile(
    FolderResult folderResult, {
    required List<String> autoViewNames,
  }) {
    var children = folderResult.result();

    for (var child in children) {
      if (child.type == StorageEntityType.file &&
          (_indexFileNamaMatches(child.name, autoViewNames))) {
        // here it is an index.html file and i want to view it
        String filePath =
            (folderResult.path + child.name).replaceAll('//', '/');

        return filePath;
      }
    }
    return null;
  }

  bool _indexFileNamaMatches(String fileName, List<String> allowedNames) {
    return allowedNames
        .any((element) => element.toLowerCase() == fileName.toLowerCase());
  }
}
