import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:fpdart/fpdart.dart';

typedef EaseEither<T> = Either<EaseFailure, T>;

/// Synchronous wrapper function to run any function. Returns type [Either<EaseFailure, R>],
/// which makes sure we handle both failure and success case whenever we use this function.
///
/// In case of an error, if the error object is already a [EaseFailure] type, it passes it over without tampering it.
/// Parses the error to [EaseFailure] object if matches with any [EaseFailure.errorParsers]
/// Returns [EaseError] as [EaseFailure] object if the above conditions are failed.
///
/// [call] - Synchronous function to be wrapped inside this function.
/// [failureLog], [infoParams] & [isFatal] - Exposed as [log], [infoParams] & [isFatal] field in [ErrorActions] which you've configured via [EaseFailure.configure(errorActions: ...)]
EaseEither<R> tryRun<R>(R Function() call, String failureLog,
        {Map<String, dynamic>? infoParams, String? uiMessage, bool isFatal = false}) =>
    Either.tryCatch(
        call,
        (e, s) => EaseFailure.fromError(failureLog, e, s,
            infoParams: infoParams, uiMessage: uiMessage, isFatal: isFatal));

/// Asynchronous wrapper function to run any function. Returns type [Future<Either<EaseFailure, R>>],
/// which makes sure we handle both failure and success case whenever we use this function.
///
/// In case of an error, if the error object is already a [EaseFailure] type, it passes it over without tampering it.
/// Parses the error to [EaseFailure] object if matches with any [EaseFailure.errorParsers]
/// Returns [EaseError] as [EaseFailure] object if the above conditions are failed.
///
/// [call] - Asynchronous function to be wrapped inside this function.
/// [failureLog], [infoParams] & [isFatal] - Exposed as [log], [infoParams] & [isFatal] field in [ErrorActions] which you've configured via [EaseFailure.configure(errorActions: ...)]
Future<EaseEither<R>> tryRunAsync<R>(Future<R> Function() call, String failureLog,
        {Map<String, dynamic>? infoParams, String? uiMessage, bool isFatal = false}) =>
    TaskEither.tryCatch(
        call,
        (e, s) => EaseFailure.fromError(failureLog, e, s,
            infoParams: infoParams, uiMessage: uiMessage, isFatal: isFatal)).run();

/// Used to try parsing an object from json format. Returns Either<ParsingError<R>, R> type,
/// which makes sure we handle both failure and success case whenever we use this function.
///
/// In case of an error, the [ParsingError] object holds lot more data than the usual error message we received from Dart.
/// 1. The log message is the one we configured via [EaseFailure.configure(parsingErrorLogCallback: (type, unParsedData) => ...)]
/// 2. It holds [unParsedData] field we can use if needed. Also we can even log the entire unParsedData to crash reporting service by configuring via [EaseFailure.configure(errorActions: ...)]
/// which is so much helpful for us to resolve the parsing issue from backend.
///
/// USAGE EXAMPLE: [EaseEither.tryParse<User>(jsonData, User.fromJson)]
Either<ParsingError<R>, R> tryParse<R>(
        Map<String, dynamic> data, R Function(Map<String, dynamic> map) fromMap) =>
    Either.tryCatch(() => fromMap(data), (e, s) => ParsingError<R>(data, e, s));

/// Used to try parsing list of objects from json format. Returns List<Either<ParsingError<R>, R>> type. This have some advantages
/// 1. Won't crash the whole app if one of many objects failed to parse.
/// 2. Logs failure of all non-parsable objects, where the usual dart parsing crashes on first parsing failure.
/// 3. Sometimes, we don't need failure objects. We might just need to show all successfully parsed objects.
/// Easy to do with [EaseEither.tryParseList<User>(allUserData, User.fromJson).rightsEither()] which returns [List<User>]
///
/// In case of an error, the [ParsingError] object holds lot more data than the usual error message we received from Dart.
/// 1. The log message is the one we configured via [EaseFailure.configure(parsingErrorLogCallback: (type, unParsedData) => ...)]
/// 2. It holds [unParsedData] field we can use if needed. Also we can even log the entire unParsedData to crash reporting service by configuring via [EaseFailure.configure(errorActions: ...)]
/// which is so much helpful for us to resolve the parsing issue from backend.
///
/// USAGE EXAMPLE: EaseEither.tryParseList<User>(allUserData, User.fromJson)
///
/// PRO TIP: Use [rightsEither()] with this function's return type to get just List<R>. Useful when we don't care about non-parsable data.
List<Either<ParsingError<R>, R>> tryParseList<R>(
        List<Map<String, dynamic>> dataList, R Function(Map<String, dynamic> map) fromMap) =>
    dataList.map((data) => tryParse<R>(data, fromMap)).toList();
