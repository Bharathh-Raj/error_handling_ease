import 'package:error_handling_ease/src/failure/failure.dart';

class EaseException extends Failure {
  EaseException(String? uiMessage) : super(uiMessage: uiMessage) {
    Failure.onException(super.uiMessage);
  }

  @override
  String toString() => '⚠️ Exception - $runtimeType - $uiMessage';
}
