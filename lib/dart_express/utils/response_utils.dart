import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';
// import 'package:path/path.dart' as path;

// import '../constants/runtime_variables.dart';

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
        .then((_) async {
      raf.closeSync();
      await req.response.close();
    });
  }

  Future<void> streamV2(HttpRequest req, String audioPath) async {
    File file = File(audioPath);
    int length = file.lengthSync();
    String? mime = lookupMimeType(audioPath);

    String? rangeHeader = req.headers.value(HttpHeaders.rangeHeader);
    if (rangeHeader != null) {
      var rangeBytes = rangeHeader.replaceFirst('bytes=', '').split('-');
      int start = int.parse(rangeBytes[0]);
      int end = rangeBytes[1].isEmpty ? length - 1 : int.parse(rangeBytes[1]);

      req.response.statusCode = HttpStatus.partialContent;
      req.response.headers
        ..contentType = ContentType.parse(mime ?? 'audio/mpeg')
        ..add('Accept-Ranges', 'bytes')
        ..add('Content-Range', 'bytes $start-$end/$length')
        ..contentLength = end - start;

      var raf = file.openSync();
      await raf.setPosition(start);
      await file.openRead(start, end).pipe(req.response);
      // Stream.fromIterable(raf.readSync(count));

      // var chunkSize = 64 * 1024 * 1024; // 64KB, you can adjust this as needed
      // var bytesLeft = end - start + 1;
      // while (bytesLeft > 0) {
      //   var chunk = await raf.read(min(chunkSize, bytesLeft));
      //   req.response.add(chunk);
      //   bytesLeft -= chunk.length;
      // }

      await raf.close();
    } else {
      req.response.headers
        ..contentType = ContentType.parse(mime ?? 'audio/mpeg')
        ..contentLength = length;
      await file.openRead().pipe(req.response);
    }

    await req.response.close();
  }

  // Future<String> receiveFile(HttpRequest request, String saveDirPath) async {
  //   Completer<String> filePathCompleter = Completer<String>();

  //   // Get the filename from the request headers or generate a unique filename
  //   var filename = request.headers.value('content-disposition');
  //   var headers = request.headers;
  //   var copiedHeaders = {};
  //   headers.forEach((name, values) {
  //     copiedHeaders[name] = values;
  //   });
  //   int length = request.headers.contentLength;
  //   if (filename != null) {
  //     var regex = RegExp(r'filename="(.*)"');
  //     var match = regex.firstMatch(filename);
  //     if (match != null) {
  //       filename = match.group(1);
  //     }
  //   } else {
  //     var now = DateTime.now().millisecondsSinceEpoch;
  //     filename = 'file_$now';
  //   }

  //   var saveDir = Directory(saveDirPath);
  //   if (!saveDir.existsSync()) {
  //     saveDir.createSync(recursive: true);
  //   }

  //   var savePath = path.join(saveDir.path, filename);
  //   var file = await File(savePath).open(mode: FileMode.write);

  //   var sub = request.listen(
  //     (List<int> chunk) async {
  //       await file.writeFrom(chunk);
  //       if (file.lengthSync() == length) {
  //         // Close the file and complete the method
  //         await file.close();
  //         filePathCompleter.complete(savePath);
  //       }
  //     },
  //     onError: (error) {
  //       dartExpressLogger.e(error);
  //       // Handle any errors that occur during the stream subscription
  //       filePathCompleter.completeError(error);
  //     },
  //     cancelOnError: true,
  //   );

  //   await sub.asFuture<void>();
  //   return filePathCompleter.future;
  // }

  // Future sendFileToView(HttpRequest req, String filePath) async {
  //   File file = File(filePath);
  //   // check if file exists
  //   if (!file.existsSync()) {
  //     throw Exception('File $filePath doesn\'t exist');
  //   }

  //   var mimeType = lookupMimeType(filePath).toString();
  //   req.response.headers.contentType = ContentType.parse(mimeType);
  //   await file.openRead().pipe(req.response);
  //   await req.response.close();
  // }
}
