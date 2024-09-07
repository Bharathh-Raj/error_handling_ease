import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class MyRangeError extends EaseError {
  MyRangeError(RangeError rangeError, StackTrace s) : super('Failed to access index', rangeError, s, infoParams: { 'Object Length': rangeError.end, 'Index Tried': rangeError.invalidValue});
}

void main() {
  Failure.configure(
      errorActions: (e, s, log, isFatal, infoParams) {
        print('e -> $e');
        print('log -> $log');          // <-- 'Failed to get first number'
        print('infoParams -> $infoParams');   // <-- {'numbers': []}
        print('isFatal -> $isFatal');      // <-- true
      },
    exceptionActions: (uiMessage) => print('uiMessage -> $uiMessage'),
    defaultErrorMessage: 'Sorry! Something went wrong',
    parsingErrorLogCallback: (type, unParsedData) => 'Failed to parse ${type.toString()} of id ${unParsedData['id']}',
    // customErrorParsers: {RangeError: (e, s) => MyRangeError(e as RangeError, s)}
  );

  test('Empty list test', () {
    final firstNumber = getFirstNumber([]);
    firstNumber.fold((l) => print('l.uiMessage -> ${l.uiMessage}'), (r) => print('r -> $r'),);
  },);
}

Either<Failure, int> getFirstNumber(List<int> numbers) {
  return EaseEither.tryRun(
        () => numbers[0], // <-- Obviously it will fail, since the list is empty
    'Failed to get first number', // <-- log in case it fails
    infoParams: {'numbers': numbers},
    uiMessage: 'Something went wrong! Please try with different list',
    isFatal: true,
  );
}