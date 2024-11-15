import 'package:error_handling_ease/error_handling_ease.dart';

typedef ErrorActions = void Function(
    dynamic e, StackTrace s, String log, bool isFatal, Map<String, dynamic>? infoParams);
typedef ExceptionActions = void Function(String uiMessage);
typedef ParsingErrorLog = String Function(Type type, Map<String, dynamic> unParsedData);
typedef CustomErrorParser = EaseFailure Function(dynamic e, StackTrace s);

abstract class EaseFailure {
  /// Message to be shown to the user. By default it holds [defaultMessage].
  /// Can we overridden when throwing an [EaseError].
  final String uiMessage;

  EaseFailure({String? uiMessage}) : uiMessage = uiMessage ?? defaultMessage;

  /// Actions to take whenever [EaseError] was thrown
  /// Usually we will log the error in console and report the error in Crash Reporting Service.
  static late final ErrorActions onError;

  /// Actions to take whenever [EaseException] was thrown
  /// Usually we will log the error in console.
  static late final ExceptionActions onException;

  /// Default error message accessed from [uiMessage] field.
  /// Which can be overridden when throwing an [EaseError].
  static late final String defaultMessage;

  /// Default parsing error log. Quite useful to log with its type along with id for example.
  /// eg: parsingErrorLog: (type, unParsedData) => 'Failed to parse ${type.toString()} with id ${unParsedData['id']}'
  static late final ParsingErrorLog parsingErrorLog;

  /// We can control the errors and exceptions thrown in our code base. However we use lot of third-party packages.
  /// eg: firebase_auth package throws exception of type [FirebaseAuthException] and dio package throws exception of type [DioException].
  ///
  /// By wrapping the third-party package code with [EaseEither.tryRun] or [EaseEither.tryRunAsync],
  /// All these third-party exceptions and errors will be converted into [EaseError].
  /// However it cannot preserve its error message, the error message is replaced with [failureLog] argument of [EaseEither.tryRun] or [EaseEither.tryRunAsync].
  ///
  /// With this field, we can parse those third party errors or exceptions into [EaseError] or [EaseException] by using [EaseEither.tryRun] or [EaseEither.tryRunAsync].
  /// eg: EaseFailure.configure(customErrorParsers: {FirebaseAuthException: (e, s) => EaseException(e.message), DioException: (e, s) => EaseError(e.message, e, s, infoParams: {'path': dioError.requestOptions.path,...})})
  ///
  /// PRO TIP: We can create a custom exceptions or error by extending [EaseException] or [EaseError].
  /// Then we can write something like EaseFailure.configure(customErrorParsers: {DioError: (e, s) => MyDioError(e as DioError)})
  static late final Map<Type, CustomErrorParser>? errorParsers;

  /// [errorActions] - Actions to take whenever [EaseError] was thrown
  /// Usually we will log the error in console and report the error in Crash Reporting Service.
  ///
  /// [exceptionActions] - Actions to take whenever [EaseException] was thrown
  /// Usually we will log the error in console.
  ///
  /// [defaultErrorMessage] - Default error message accessed from [uiMessage] field.
  /// Which can be overridden when throwing an [EaseError].
  ///
  /// [parsingErrorLogCallback] - Default parsing error log. Quite useful to log with its type along with id for example.
  /// eg: parsingErrorLog: (type, unParsedData) => 'Failed to parse ${type.toString()} with id ${unParsedData['id']}'
  ///
  /// [customErrorParsers] - We can control the errors and exceptions thrown in our code base. However we use lot of third-party packages.
  /// eg: firebase_auth package throws exception of type [FirebaseAuthException] and dio package throws exception of type [DioException].
  ///
  /// By wrapping the third-party package code with [EaseEither.tryRun] or [EaseEither.tryRunAsync],
  /// All these third-party exceptions and errors will be converted into [EaseError].
  /// However it cannot preserve its error message, the error message is replaced with [failureLog] argument of [EaseEither.tryRun] or [EaseEither.tryRunAsync].
  ///
  /// With this field, we can parse those third party errors or exceptions into [EaseError] or [EaseException] by using [EaseEither.tryRun] or [EaseEither.tryRunAsync].
  /// eg: EaseFailure.configure(customErrorParsers: {FirebaseAuthException: (e, s) => EaseException(e.message), DioException: (e, s) => EaseError(e.message, e, s, infoParams: {'path': dioError.requestOptions.path,...})})
  ///
  /// PRO TIP: We can create a custom exceptions or error by extending [EaseException] or [EaseError].
  /// Then we can write something like EaseFailure.configure(customErrorParsers: {DioError: (e, s) => MyDioError(e as DioError)})
  static void configure({
    required ErrorActions errorActions,
    required ExceptionActions exceptionActions,
    String defaultErrorMessage = 'Sorry! Something went wrong',
    ParsingErrorLog? parsingErrorLogCallback,
    Map<Type, CustomErrorParser>? customErrorParsers,
  }) {
    onError = errorActions;
    onException = exceptionActions;
    defaultMessage = defaultErrorMessage;
    errorParsers = customErrorParsers;
    parsingErrorLog =
        parsingErrorLogCallback ?? (type, unParsedData) => 'Failed to parse ${type.toString()}';
  }

  /// This must be thrown inside the catch statement of [try-catch].
  /// This make sure to return the same error object if it is already a [EaseFailure] object.
  /// This also compares the error with all [errorParsers] to parse the error into EaseFailure object.
  /// Returns [EaseError] if the above conditions are failed.
  factory EaseFailure.fromError(
    String log,
    dynamic e,
    StackTrace s, {
    Map<String, dynamic>? infoParams,
    String? uiMessage,
    bool isFatal = false,
  }) {
    if (e is EaseFailure) return e;

    final customParser = errorParsers?[e.runtimeType];
    if (customParser != null) return customParser(e, s);

    return EaseError(
      log,
      e,
      s,
      infoParams: infoParams,
      uiMessage: uiMessage,
      isFatal: isFatal,
    );
  }

  @override
  String toString() => uiMessage;
}
