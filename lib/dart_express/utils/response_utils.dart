import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../constants/runtime_variables.dart';

//! this class needs some editing and testing as uploading file doesn't work very well
class ResponseUtils {
  void sendChunkedFile(HttpRequest req, String filePath) {
    File file = File(filePath);
    // check if file exists
    if (!file.existsSync()) {
      throw Exception('File $filePath doesn\'t exist');
    }
    String fileName =
        file.path.split('/').last; // Extract the filename from the file path
    String? mime = lookupMimeType(filePath);

    req.response.statusCode = HttpStatus.ok;
    req.response.headers
      ..contentType = ContentType.parse(mime ?? 'application/octet-stream')
      ..add('Content-Disposition',
          'attachment; filename=$fileName') // Set the Content-Disposition header
      ..add('Accept-Ranges', 'bytes');

    int fileLength = file.lengthSync();
    int start = 0;
    int end = fileLength - 1;

    String? range = req.headers.value('range');
    if (range != null) {
      List<String> parts = range.split('=');
      List<String> positions = parts[1].split('-');
      start = int.parse(positions[0]);
      end = positions.length < 2 || int.tryParse(positions[1]) == null
          ? fileLength - 1
          : int.parse(positions[1]);
      req.response.statusCode = HttpStatus.partialContent;
      req.response.headers
        ..contentLength = end - start + 1
        ..add('Content-Range', 'bytes $start-$end/$fileLength');
    } else {
      req.response.headers.contentLength = fileLength;
    }

    RandomAccessFile raf = file.openSync();
    raf.setPositionSync(start);
    Stream<List<int>> fileStream = Stream.value(raf.readSync(end - start + 1));
    req.response
        .addStream(fileStream
            .handleError((e) => throw Exception('Error reading file: $e')))
        .then((_) {
      raf.closeSync();
      req.response.close();
    });
  }

  void streamV2(HttpRequest req, String audioPath) {
    File file = File(audioPath);
    int length = file.lengthSync();

    // this formate 'bytes=0-' means that i want the bytes from the 0 to the end
    // so the end here means the end of the file
    // if it was 'bytes=0-1000' this means that i need the bytes from 0 to 1000
    String range = req.headers.value('range') ?? 'bytes=0-';
    List<String> parts = range.split('=');
    List<String> positions = parts[1].split('-');
    int start = int.parse(positions[0]);
    int end = positions.length < 2 || int.tryParse(positions[1]) == null
        ? length
        : int.parse(positions[1]);
    String? mime = lookupMimeType(audioPath);
    // print('Needed bytes from $start to $end');

    req.response.statusCode = HttpStatus.partialContent;
    req.response.headers
      ..contentType = ContentType.parse(mime ?? 'audio/mpeg')
      ..contentLength = end - start
      ..add('Accept-Ranges', 'bytes')
      ..add('Content-Range', 'bytes $start-$end/$length');
    file.openRead(start, end).pipe(req.response);
  }

  Future<String> receiveFile(HttpRequest request, String saveDirPath) async {
    Completer<String> filePathCompleter = Completer<String>();

    // Get the filename from the request headers or generate a unique filename
    var filename = request.headers.value('content-disposition');
    var headers = request.headers;
    var copiedHeaders = {};
    headers.forEach((name, values) {
      copiedHeaders[name] = values;
    });
    int length = request.headers.contentLength;
    if (filename != null) {
      var regex = RegExp(r'filename="(.*)"');
      var match = regex.firstMatch(filename);
      if (match != null) {
        filename = match.group(1);
      }
    } else {
      var now = DateTime.now().millisecondsSinceEpoch;
      filename = 'file_$now';
    }

    var saveDir = Directory(saveDirPath);
    if (!saveDir.existsSync()) {
      saveDir.createSync(recursive: true);
    }

    var savePath = path.join(saveDir.path, filename);
    var file = await File(savePath).open(mode: FileMode.write);

    var sub = request.listen(
      (List<int> chunk) async {
        await file.writeFrom(chunk);
        if (file.lengthSync() == length) {
          // Close the file and complete the method
          await file.close();
          filePathCompleter.complete(savePath);
        }
      },
      onError: (error) {
        dartExpressLogger.e(error);
        // Handle any errors that occur during the stream subscription
        filePathCompleter.completeError(error);
      },
      cancelOnError: true,
    );

    await sub.asFuture<void>();
    return filePathCompleter.future;
  }
}
