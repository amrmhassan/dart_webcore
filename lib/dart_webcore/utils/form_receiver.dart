// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_webcore/dart_webcore/server/impl/request_holder.dart';
import 'package:dart_webcore/dart_webcore/utils/string_utils.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

/// this class is responsible for handling receiving files streams from the http request and save them locally
class FormReceiver {
  final RequestHolder holder;
  final String _saveFolderPath;
  final bool _acceptFormFiles;

  const FormReceiver(
    this.holder, {
    bool? acceptFormFiles,
    String? saveFolderPath,
  })  : _saveFolderPath = saveFolderPath ?? 'tmpUploaded',
        _acceptFormFiles = acceptFormFiles ?? true;

  Future<String> _savePartToFile(
    Stream<List<int>> part,
    String contentType,
  ) async {
    if (!_acceptFormFiles) {
      throw Exception('files aren\'t accepted in this form');
    }
    final completer = Completer<String>();
    List<String> parts = contentType.split('/');
    late String fileExtension;
    if (parts.length != 2) {
      fileExtension = '';
    } else {
      fileExtension = '.${parts[1]}';
    }
    String fileName = const Uuid().v4();
    String filePath = '${_saveFolderPath.strip('/')}/$fileName$fileExtension';
    File file = File(filePath);
    file.createSync(recursive: true);
    var raf = await file.open(mode: FileMode.write);

    part.listen(
      (data) {
        raf.writeFromSync(data);
      },
      onDone: () {
        raf.closeSync();
        completer.complete(filePath);
      },
      onError: (error) => completer.completeError(error),
      cancelOnError: true,
    );

    return completer.future;
  }

  Future<List<FormResult>> receiveFormData() async {
    final contentType = holder.headers.contentType;
    List<FormResult> form = [];

    var transformer =
        MimeMultipartTransformer(contentType!.parameters['boundary']!);
    final parts = await transformer.bind(holder.request).toList();
    for (var part in parts) {
      var broadCast = part.asBroadcastStream();
      final disposition = part.headers['content-disposition'];
      String? name = _getDispositionKey(disposition);
      var contentType = part.headers['content-type'] ?? '';
      if (contentType.startsWith('text')) {
        // this is a text
        var res = await utf8.decoder.bind(part).join();
        FormResult result = FormResult(
          key: name ?? 'noKey',
          value: res,
          contentType: contentType,
        );
        form.add(result);
      } else {
        // this should be a stream of a file
        var filePath = await _savePartToFile(broadCast, contentType);
        FormResult result = FormResult(
          key: name ?? 'file',
          value: filePath,
          contentType: contentType,
        );
        form.add(result);
      }
    }

    return form;
  }

  Future<File> receiveBinaryFile() async {
    var completer = Completer<File>();
    final contentType = holder.headers.contentType?.mimeType ?? '';
    String? fileName = _getFileName();
    if (fileName == null) {
      List<String> parts = contentType.split('/');
      late String fileExtension;
      if (parts.length != 2) {
        fileExtension = '';
      } else {
        fileExtension = '.${parts[1]}';
      }
      String name = const Uuid().v4();
      fileName = '$name$fileExtension';
    }
    String filePath = '${_saveFolderPath.strip('/')}/$fileName';

    File file = File(filePath);
    if (file.existsSync()) {
      throw Exception('file already exist');
    }
    file.createSync(recursive: true);
    var raf = await file.open(mode: FileMode.write);

    holder.request.listen((event) {
      raf.writeFromSync(event);
    }).onDone(() {
      raf.closeSync();
      completer.complete(file);
    });

    return completer.future;
  }

  String? _getFileName() {
    String? attachment = holder.headers.value('content-disposition');
    return _getFileNameFromContentDisposition(attachment);
  }

  int? _getFileSize() {
    int? size = int.tryParse(
        holder.headers.value(HttpHeaders.contentLengthHeader).toString());
    return size;
  }

  String? _getFileNameFromContentDisposition(String? contentDisposition) {
    if (contentDisposition != null) {
      final fileNameMatch = RegExp('filename[^;=\n]*=((["\']).*?\\2|[^;\n]*)')
          .firstMatch(contentDisposition);
      if (fileNameMatch != null) {
        return fileNameMatch.group(1)?.replaceAll('"', '');
      }
    }
    return null;
  }

  String? _getDispositionKey(String? disposition) {
    if (disposition != null) {
      final fileNameMatch = RegExp('name[^;=\n]*=((["\']).*?\\2|[^;\n]*)')
          .firstMatch(disposition);
      if (fileNameMatch != null) {
        return fileNameMatch.group(1)?.replaceAll('"', '');
      }
    }
    return null;
  }
}

class FormResult {
  final String key;
  final dynamic value;
  final String contentType;

  const FormResult({
    required this.key,
    required this.value,
    required this.contentType,
  });
}
