import 'package:logger/logger.dart';

class Log {
  Log._();

  static Logger instance = Logger(printer: PrettyPrinter());

  void v(String Function() message) {
    instance.v(message);
  }

  void d(String Function() message) {
    instance.d(message);
  }

  void i(String Function() message) {
    instance.i(message);
  }

  void w(String Function() message) {
    instance.w(message);
  }

  void e(
    String Function() message, {
    dynamic error,
    StackTrace stackTrace = StackTrace.empty,
  }) {
    instance.e(message, error, stackTrace);
  }
}
