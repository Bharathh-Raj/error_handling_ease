typedef ErrorCallback = void Function(
    dynamic e, StackTrace s, String log, bool isFatal, Map<String, dynamic>? infoParams);
typedef ExceptionCallback = void Function(String message);
typedef ParsingErrorLog = String Function(Type type, Map<String, dynamic> unParsedData);

class ErrorHandlingEase {
  const ErrorHandlingEase._();

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
    parsingErrorLog = parsingErrorMessageCallback ?? (type, unParsedData) => 'Failed to parse ${type.toString()}';
  }
}
