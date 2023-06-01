// ignore_for_file: avoid_print

import 'package:logger/logger.dart';

class CustomLogger extends Logger {
  @override
  void log(Level level, message, [error, StackTrace? stackTrace]) {
    print(message);
  }
}

Logger dartExpressLogger = CustomLogger();
