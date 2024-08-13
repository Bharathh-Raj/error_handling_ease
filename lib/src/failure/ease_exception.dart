import 'package:error_handling_ease/src/failure/failure.dart';

class EaseException extends Failure {
  EaseException(super.uiMessage) : super(message: uiMessage) {
    Failure.onException(super.message);
  }

  @override
  String toString() => '⚠️ Exception - $runtimeType - $message';
}
