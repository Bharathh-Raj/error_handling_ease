import '../../error_handling_ease.dart';

class EaseError extends EaseFailure {
  EaseError(
    this.log,
    this.e,
    this.s, {
    this.infoParams,
    this.isFatal = false,
    super.uiMessage,
  }) {
    EaseFailure.onError(e, s, log, isFatal, infoParams);
  }

  final dynamic e;
  final StackTrace s;
  final String log;
  final Map<String, dynamic>? infoParams;
  final bool isFatal;

  @override
  String toString() =>
  '''🚨${isFatal ? '🚨🚨Fatal' : ''} Error - $runtimeType - $log
  ${infoParams != null ? 'infoParams - ${infoParams.toString()}' : ''}
  ${s.toString()}''';
}

class ParsingError<T> extends EaseError {
  final Map<String, dynamic> unParsedData;

  ParsingError(this.unParsedData, dynamic e, StackTrace s, {String? uiMessage, bool? isFatal})
      : super(EaseFailure.parsingErrorLog(T.runtimeType, unParsedData), e, s,
            infoParams: unParsedData, uiMessage: uiMessage, isFatal: isFatal ?? false);
}
