# error_handling_ease
**Ease the Error Handling with simple wrapper functions that takes care of all the logging, reporting, etc...**
# Solution this library offers

| **Problems**                                                                                                                                                                                                                                                         | **Solutions**                                                                                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Repeating the same code to Log and Record the error in Crash Reporting services like [Crashlytics](https://firebase.google.com/docs/crashlytics), [Sentry](https://sentry.io/welcome/) or [Instabug](https://www.instabug.com) whenever catching an Error/Exception. | Auto Logging and Recording the error with function wrapper and global configuration.                                                                             |
| Calling a function that could throw Exception without wrapping inside a [try-catch](https://dart.dev/language/error-handling) statement.                                                                                                                             | Returns the type [Either](https://pub.dev/packages/fpdart#either) from [fpDart](https://pub.dev/packages/fpdart) package that forces us to handle the Exception. |
| Handling some custom exception types of third-party packages like [FirebaseAuthException](https://firebase.google.com/docs/auth/flutter/errors), [DioException](https://pub.dev/packages/dio#dioexception) all over the code.                                        | With global configuration, custom types are handled all across the app with function wrapper.                                                                    |
| Manually converting all errors and exception in UI with simple message like "Sorry! Something went wrong."                                                                                                                                                           | With global configuration, we can configure the UI message for all Errors and Exception that doesn't have a custom message.                                      |
| Recording all exceptions inside the catch statement also records simple exceptions such as `UserNotRegistedException`,  `UserNotSignedInException`                                                                                                                   | We can configure what to do with the 2 types of Failure this package offers. EaseException and EaseError                                                         |
| Not so helpful **Parsing Error** log. `Argument type 'int' can't be assigned to the parameter type 'String'`                                                                                                                                                         | Global configurable parsing log like `Failed to parse User of id '12345'. unParsedData: {'id': '12345', ...}`                                                    |
| Accidental logging/reporting the same exception multiple times when using multi-layered architecture.                                                                                                                                                                | Logging/Reporting happens only once throughout the lifetime of the exception.                                                                                    |
| Custom Exception Message could get lost due to accidental transformation of exceptions in higher layers.                                                                                                                                                             | Preserves the original exception until the last layer.                                                                                                           |
## How to use?
### Step 1 - [Global Failure Configuration](#global%20configuration)
We need to configure how to handle
- [EaseException](#easeexception)
- [EaseError](#easeerror)
- Parsing Log for Parsing Errors
- Custom Error Parsing Logics
- Default Error Message to pass down to UI
### Step 2 - [Wrap functions with EaseEither methods](#EaseEither)
- Synchronous Function Wrapper - EaseEither.tryRun()
- Asynchronous Function Wrapper - EaseEither.tryRunAsync()
- Parsing Wrapper - EaseEither.tryParse()

> [!NOTE]
> These [EaseEither](#EaseEither) methods returns the type `Either<Failure, T>` which forces us to handle both success and failure case.
### Step 3 - Throwing EaseError or EaseException based if needed
```dart
// Example to throw EaseException
```

```dart
// Example to throw EaseError
```

> [!Tip]
> Create Custom EaseError and EaseException
>

## Failure
Failure is the object type returned from all the functions used in this library. EaseException and EaseError are the two subclasses that extends Failure class.

![](https://i.imgur.com/uYVbqHl.png)
### Exceptions vs Errors
**Exceptions** are intended to be expected. Which means they should be handled. eg: We can throw `UserNotSignedInException` if the user is not signed in, which is totally expected. We obviously would've handled this and would show `LogInPage` instead of `HomePage`. Since these kind of Failures are totally expected, we do not want them to be recorded in Crash reporting systems like Crashlytics, Sentry or Instabug.

On the other hand, **Errors** are unexpected failures happens because of several reasons. eg: `ParsingError` happens when the data is not matching with what we would expect. In this case, we often could not handle much. We could just show some error message to the user. However in this case, we definitely want this failure to be recorded in Crash reporting systems, so that we could eliminate the issue.

| **Exceptions**                                             | **Errors**                                                |
| ---------------------------------------------------------- | --------------------------------------------------------- |
| Exceptions are intended to be expected.                    | Errors are unexpected failure of code.                    |
| Would be handed in our code.                               | Cannot do much other than showing some error to the user. |
| Do not need to be recorded in the crash reporting service. | Should be recorded in the crash reporting service.        |
### EaseException
A subclass of Failure, intended to be thrown if the failure is expected.

eg: Once the user completes the authentication, we might need to check if the user is already registered with personal details. If we do not find user details associated with the userId, we need to show `OnboardingPage` to the user to get personal details. Since this is totally an expected failure, we do not want this failure to be registered in crash reporting service, since this failure will happen for all new users. This is a case where we want to throw EaseException.

```dart
class UserNotRegisteredException extends EaseException{  
  UserNotRegisteredException() : super('Please enter your details to continue.');  
}
```

```dart
/// Firestore code to fetch user doc
Future<User> fetchUserOfId(String userId) async {
	final userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();
					
	if(!userDoc.exists) throw UserNotRegisteredException(); // <-------
	
	return User.fromJson(userDoc.data()!);
}
```

// TODO: Show how it is logged in terminal
### EaseError
A subclass of Failure, intended to be throws in case of unexpected error.

```dart
Future<void> createUser(User newUser) async {
	try {
		...
	} catch(e, s) {
		throw EaseError('Failed to create user', e, s, infoParams: {'newUser': newUser});
		// TODO: Explain this
	}
}
```

eg: Student document inside Firestore `students` collection have a field called `schoolId` which points to `schools` collection. Let's say if the `schoolId` doesn't point to any school inside the `schools` collection. So either, id in `schoolId` field is wrong or for some reason, the school with id matches to `schoolId` got deleted. Logically neither of these cases should be happened. This failure must be recorded in the crash reporting system so that we could fix this in the backend. This is a case where we want to throw EaseError.

```dart
class DocNotFoundError<T> extends EaseError {  
  DocNotFoundError(this.docPath)  
      : super(  
          'Failed to fetch ${T.toString()} doc of path $docPath',  
          '${T.toString()} doc not found',  
          StackTrace.current,
          infoParams: {'docPath': docPath},  
        );  
  
  final String docPath;  
}
```

```dart
Future<School> fetchSchoolOfId(String schoolId) async {
	final doc = FirebaseFirestore.instance.collection('schools').doc(id);
	final schoolDoc = await doc.get();

	if(!schoolDoc.exists) throw DocNotFoundError<School>(doc.path); // <-------
	
	return School.fromJson(schoolDoc.data()!);
}
```

// TODO: Show how it is logged in terminal

### Either<Failure, T> Type


## Global Configuration
We need to configure the actions that are needed to be taken in case of EaseError and EaseException.
### ErrorActions
This determines what are the actions to be taken in case of [EaseError](#easeerror). Usually the actions could be logging the error in the console and reporting the error to the Crash Reporting Service. We gets
- e - Error object that was thrown
- s - StackTrace
- log - log Property of [EaseError](#easeerror)

```dart
Failure.configure(
	errorActions: (e, s, log, isFatal, infoParams) {
		
	}
)
```

```dart
import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:logger/logger.dart';

void main() {
Failure.configure(
	errorActions: (e, s, log, isFatal, infoParams) {
		// Logs the error in terminal
		Logger().e(log, error: error, stackTrace: stackTrace);
		// Records error to crash reporting service
		CrashReporter.recordError(e, s, log, infoParams: infoParams, fatal: isFatal);
	},
	exceptionActions: (message) => Logger().w(message);
	defaultErrorMessage: 'Sorry! Something went wrong.'
}
```

// TODO: Create a sample project and paste examples of Logger here
### Custom Error Parsers


## EaseEither
### Synchronous Function Wrapper - EaseEither.tryRun()

### Asynchronous Function Wrapper - EaseEither.tryRunAsync()

### Parsing Wrapper - EaseEither.tryParse()

















## Connect with me [@Bharath](https://linktr.ee/bharath.dev)

[![image](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-3.svg)](https://www.buymeacoffee.com/bharath213)