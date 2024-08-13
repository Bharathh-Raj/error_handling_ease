import 'package:error_handling_ease/src/error_handling_ease_config.dart';
import 'package:flutter/foundation.dart';

import 'ease_error.dart';

abstract class Failure {
  final String _message;
  final String _log;

  Failure(this._log, {String? message})
      : _message = message ?? ErrorHandlingEase.defaultErrorMessage;

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
