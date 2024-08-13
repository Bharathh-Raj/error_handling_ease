import '../../error_handling_ease.dart';

class EaseError extends Failure {
  EaseError(
    super.log,
    this.e,
    this.s, {
    this.infoParams,
    this.isFatal = false,
    super.message,
  }) {
    ErrorHandlingEase.onError(e, s, log, isFatal, infoParams);
  }

  final dynamic e;
  final StackTrace s;
  final Map<String, dynamic>? infoParams;
  final bool isFatal;

  @override
  String toString() => '''
      🚨${isFatal ? '🚨🚨Fatal' : ''} Error - $runtimeType
      ${infoParams != null ? 'infoParams - ${infoParams.toString()}' : ''}
      ${s.toString()}
      ''';
}

class ParsingError<T> extends EaseError {
  final Map<String, dynamic> unParsedData;

  ParsingError(this.unParsedData, dynamic e, StackTrace s, {String? message, bool? isFatal})
      : super(ErrorHandlingEase.parsingErrorLog(T.runtimeType, unParsedData), e, s,
            infoParams: unParsedData, message: message, isFatal: isFatal ?? false);
}
