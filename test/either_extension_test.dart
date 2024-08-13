import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group(
    'Success cases',
    () {
      ErrorHandlingEase.initialize(
        (e, s, log, isFatal, infoParams) {},
        (message) {},
        parsingErrorMessageCallback: (type, unParsedData) => '',
      );

      final response = EitherEase.tryRun(() => 1 + 2, 'Failed to add');

      test('response should return Right value', () => expect(response.isRight(), true));

      test('response should be of type Right<Failure, int>',
          () => expect(response.runtimeType, Right<Failure, int>));

      test('response should have value of 3', () => expect(response.fold((l) => l, (r) => r), 3));
    },
  );

  group('Failure Case with Exception', () {
    ErrorHandlingEase.initialize(
      (e, s, log, isFatal, infoParams) {},
      (message) => print(message),
      parsingErrorMessageCallback: (type, unParsedData) =>
          'Failed to parse ${type.toString()} of id ${unParsedData['id']}',
    );

    final response =
        EitherEase.tryRun<int>(() => throw EaseException('User not signed In'), 'Failed to add');

    test('response should return Left value', () => expect(response.isLeft(), true));

    test('response should be of type Left<Failure, int>',
        () => expect(response.runtimeType, Left<Failure, int>));

    test('response should have Exception type EaseException',
        () => expect(response.fold((l) => l, (r) => r).runtimeType, EaseException));

    test('response should have Exception with uiMessage User not signed In',
        () => expect(response.fold((l) => l.message, (r) => r), 'User not signed In'));
  });

  group('Failure Case with Error', () {
    ErrorHandlingEase.initialize(
      (e, s, log, isFatal, infoParams) {
        print(log);
        print(e);
      },
      (message) => print(message),
      parsingErrorMessageCallback: (type, unParsedData) =>
          'Failed to parse ${type.toString()} of id ${unParsedData['id']}',
    );

    final response = EitherEase.tryRun<int>(
            // () => throw Error(), 'Failed to run',
        () => throw UnsupportedError('UnsupportedError message'), 'Failed to run',
        customErrorParsers: {UnsupportedError: (e, s) => CustomError(e, s)},
        message: 'Something went wrong',
        infoParams: {'param1': 'test1'});

    test('response should return Left value', () => expect(response.isLeft(), true));

    test('response should be of type Left<Failure, int>',
        () => expect(response.runtimeType, Left<Failure, int>));

    test('response should have Error type EaseError', () {
      final resultFailureType = response.fold((l) => l, (r) => r).runtimeType;
      print('resultFailureType - $resultFailureType');
      expect(resultFailureType, CustomError);
      // expect(resultFailureType, EaseError);
    });
  });
}

class CustomError extends EaseError {
  CustomError(Object e, StackTrace s) : super('Custom error', e, s);
}
