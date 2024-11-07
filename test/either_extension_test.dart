import 'dart:convert';

import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class UserNotRegisteredException extends EaseException{
  UserNotRegisteredException() : super('Please enter your details to continue.');
}

void main() {
  EaseFailure.configure(
    errorActions: (e, s, log, isFatal, infoParams) {
      print(log);
      print(e);
    },
    exceptionActions: (message) => print(message),
    parsingErrorLogCallback: (type, unParsedData) =>
        'Failed to parse ${type.toString()} of id ${unParsedData['id']}',
    customErrorParsers: {UnsupportedError: (e, s) => CustomError(e, s)},
  );

  group(
    'Success cases',
    () {
      final response = tryRun(() => 1 + 2, 'Failed to add');

      test('response should return Right value', () => expect(response.isRight(), true));

      test('response should be of type Right<EaseFailure, int>',
          () => expect(response.runtimeType, Right<EaseFailure, int>));

      test('response should have value of 3', () => expect(response.fold((l) => l, (r) => r), 3));
    },
  );

  group('EaseFailure Case with Exception', () {
    final response =
        tryRun<int>(() => throw EaseException('User not signed In'), 'Failed to add');

    test('response should return Left value', () => expect(response.isLeft(), true));

    test('response should be of type Left<EaseFailure, int>',
        () => expect(response.runtimeType, Left<EaseFailure, int>));

    test('response should have Exception type EaseException',
        () => expect(response.fold((l) => l, (r) => r).runtimeType, EaseException));

    test('response should have Exception with uiMessage User not signed In',
        () => expect(response.fold((l) => l.uiMessage, (r) => r), 'User not signed In'));
  });

  group('EaseFailure Case with Error', () {
    final response = tryRun<int>(
        // () => throw Error(), 'Failed to run',
        () => throw UnsupportedError('UnsupportedError message'),
        'Failed to run',
        uiMessage: 'Something went wrong',
        infoParams: {'param1': 'test1'});

    test('response should return Left value', () => expect(response.isLeft(), true));

    test('response should be of type Left<EaseFailure, int>',
        () => expect(response.runtimeType, Left<EaseFailure, int>));

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
