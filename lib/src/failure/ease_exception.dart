import 'package:error_handling_ease/src/failure/failure.dart';

class EaseException extends EaseFailure {
  EaseException(String? uiMessage) : super(uiMessage: uiMessage) {
    EaseFailure.onException(super.uiMessage);
  }

  @override
  String toString() => '⚠️ Exception - $runtimeType - $uiMessage';
}
