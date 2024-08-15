import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:fpdart/fpdart.dart';

extension EitherEase on Either {
  static Either<Failure, R> tryRun<R>(R Function() call, String failureLog,
          {Map<String, dynamic>? infoParams, String? message, bool isFatal = false}) =>
      Either.tryCatch(
          call,
          (e, s) => Failure.fromError(failureLog, e, s,
              infoParams: infoParams, message: message, isFatal: isFatal));

  static Future<Either<Failure, R>> tryRunAsync<R>(Future<R> Function() call, String failureLog,
          {Map<String, dynamic>? infoParams, String? message, bool isFatal = false}) =>
      TaskEither.tryCatch(
          call,
          (e, s) => Failure.fromError(failureLog, e, s,
              infoParams: infoParams, message: message, isFatal: isFatal)).run();

  static Either<ParsingError<R>, R> tryParse<R>(
          Map<String, dynamic> data, R Function(Map<String, dynamic> map) fromMap) =>
      Either.tryCatch(() => fromMap(data), (e, s) => ParsingError<R>(data, e, s));

  static List<Either<ParsingError<R>, R>> tryParseList<R>(
          List<Map<String, dynamic>> dataList, R Function(Map<String, dynamic> map) fromMap) =>
      dataList.map((data) => tryParse<R>(data, fromMap)).toList();
}
