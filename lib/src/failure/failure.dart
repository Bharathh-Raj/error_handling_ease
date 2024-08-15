import 'ease_error.dart';

typedef ErrorCallback = void Function(
    dynamic e, StackTrace s, String log, bool isFatal, Map<String, dynamic>? infoParams);
typedef ExceptionCallback = void Function(String message);
typedef ParsingErrorLog = String Function(Type type, Map<String, dynamic> unParsedData);
typedef CustomErrorParser = Failure Function(Object e, StackTrace s);

abstract class Failure {
  final String message;

  Failure({String? message}) : message = message ?? defaultMessage;

  static late final ErrorCallback onError;
  static late final ExceptionCallback onException;
  static late final String defaultMessage;
  static late final ParsingErrorLog parsingErrorLog;
  static late final Map<Type, CustomErrorParser>? errorParsers;

  static void configure(ErrorCallback errorCallback, ExceptionCallback exceptionCallback,
      {String defaultErrorMessage = 'Sorry! Something went wrong.',
      ParsingErrorLog? parsingErrorLogCallback,
      Map<Type, CustomErrorParser>? customErrorParsers}) {
    onError = errorCallback;
    onException = exceptionCallback;
    defaultMessage = defaultErrorMessage;
    errorParsers = customErrorParsers;
    parsingErrorLog =
        parsingErrorLogCallback ?? (type, unParsedData) => 'Failed to parse ${type.toString()}';
  }

  factory Failure.fromError(
    String log,
    dynamic e,
    StackTrace s, {
    Map<String, dynamic>? infoParams,
    String? message,
    bool isFatal = false,
  }) {
    if (e is Failure) return e;
    final customParser = errorParsers?[e.runtimeType];
    if (customParser != null) return customParser(e, s);
    return EaseError(
      log,
      e,
      s,
      infoParams: infoParams,
      message: message,
      isFatal: isFatal,
    );
  }

  @override
  String toString() => message;
}
