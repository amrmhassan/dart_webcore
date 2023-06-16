import 'dart:io';
import 'package:mime/mime.dart';

class ResponseUtils {
  void sendChunkedFile(HttpRequest req, String filePath) {
    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File $filePath doesn\'t exist');
    }

    String fileName = file.path.split('/').last;
    String? mime = lookupMimeType(filePath);

    req.response.statusCode = HttpStatus.ok;
    req.response.headers
      ..contentType = ContentType.parse(mime ?? 'application/octet-stream')
      ..add('Content-Disposition', 'attachment; filename=$fileName')
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

      await raf.close();
    } else {
      req.response.headers
        ..contentType = ContentType.parse(mime ?? 'audio/mpeg')
        ..contentLength = length;
      await file.openRead().pipe(req.response);
    }

    await req.response.close();
  }
}
