import 'package:flutter/foundation.dart';

import 'ease_error.dart';

typedef ErrorCallback = void Function(
    dynamic e, StackTrace s, String log, bool isFatal, Map<String, dynamic>? infoParams);
typedef ExceptionCallback = void Function(String message);
typedef ParsingErrorLog = String Function(Type type, Map<String, dynamic> unParsedData);

abstract class Failure {
  final String _message;
  final String _log;

  Failure(this._log, {String? message}) : _message = message ?? defaultErrorMessage;

  static late ErrorCallback onError;
  static late ExceptionCallback onException;
  static late String defaultErrorMessage;
  static late ParsingErrorLog parsingErrorLog;

  static void initialize(ErrorCallback errorCallback, ExceptionCallback exceptionCallback,
      {String defaultMessage = 'Sorry! Something went wrong.',
      ParsingErrorLog? parsingErrorMessageCallback}) {
    onError = errorCallback;
    onException = exceptionCallback;
    defaultErrorMessage = defaultMessage;
    parsingErrorLog =
        parsingErrorMessageCallback ?? (type, unParsedData) => 'Failed to parse ${type.toString()}';
  }

  factory Failure.fromError(
    dynamic e,
    StackTrace s,
    String log, {
    Map<String, dynamic>? infoParams,
    String? message,
    bool isFatal = false,
  }) {
    if (e is Failure) return e;
    return EaseError(
      log,
      e,
      s,
      infoParams: infoParams,
      message: message,
      isFatal: isFatal,
    );
  }

  String get message => _message;
  String get log => _log;

  @override
  String toString() => kDebugMode ? _log : _message;
}
