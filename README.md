# error_handling_ease
**Ease the Error Handling with simple wrapper functions that takes care of all the logging, reporting, etc...**
# Solution this library offers

| **Problems**                                                                                                                                                                                                                                                         | **Solutions**                                                                                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Repeating the same code to Log and Record the error in Crash Reporting services like [Crashlytics](https://firebase.google.com/docs/crashlytics), [Sentry](https://sentry.io/welcome/) or [Instabug](https://www.instabug.com) whenever catching an Error/Exception. | Auto Logging and Recording the error with function wrapper and global configuration.                                                                             |
| Calling a function that could throw Exception, without wrapping inside a [try-catch](https://dart.dev/language/error-handling) statement.                                                                                                                            | Returns the type [Either](https://pub.dev/packages/fpdart#either) from [fpDart](https://pub.dev/packages/fpdart) package that forces us to handle the Exception. |
| Handling some custom exception types of third-party packages like [FirebaseAuthException](https://firebase.google.com/docs/auth/flutter/errors), [DioException](https://pub.dev/packages/dio#dioexception) all over the code.                                        | With global configuration, custom types are handled all across the app with function wrapper.                                                                    |
| Manually converting all errors and exception in UI with simple message like "Sorry! Something went wrong."                                                                                                                                                           | With global configuration, we can configure the UI message for all Errors and Exception that doesn't have a custom message.                                      |
| Recording all exceptions inside the catch statement also records simple exceptions such as `UserNotRegistedException`,  `UserNotSignedInException`                                                                                                                   | We can configure what to do with the 2 types of Failure this package offers. EaseException and EaseError                                                         |
| Not so helpful **Parsing Error** log. `Argument type 'int' can't be assigned to the parameter type 'String'`                                                                                                                                                         | Global configurable parsing log like `Failed to parse User of id '12345'. unParsedData: {'id': '12345', ...}`                                                    |
| Accidental logging/reporting the same exception multiple times when using multi-layered architecture.                                                                                                                                                                | Logging/Reporting happens only once throughout the lifetime of the exception.                                                                                    |
| Custom Exception Message could get lost due to accidental transformation of exceptions in higher layers.                                                                                                                                                             | Preserves the original exception until the top layer.                                                                                                            |
# EaseFailure
EaseFailure is the object type returned from all the functions used in this library. EaseException and EaseError are the two subclasses that extends EaseFailure class.

![](https://i.imgur.com/uYVbqHl.png)
## Exceptions vs Errors
**Exceptions** are intended to be expected. Which means they should be handled. eg: We can throw `UserNotSignedInException` if the user is not signed in, which is totally expected. We obviously would've handled this and would show `LogInPage` instead of `HomePage`. Since these kind of Failures are totally expected, we do not want them to be recorded in Crash reporting systems like Crashlytics, Sentry or Instabug.

On the other hand, **Errors** are unexpected failures happens that should be avoided by the programmer. eg: `ParsingError` happens when the data is not matching with what we would expect. In this case, we often could not handle much. We could just show some error message to the user. However in this case, we definitely want this failure to be recorded in Crash reporting systems, so that we could eliminate the issue.

| **Exceptions**                                             | **Errors**                                                |
| ---------------------------------------------------------- | --------------------------------------------------------- |
| Exceptions are intended to be expected.                    | Errors are unexpected failure of code.                    |
| Would be handed in our code.                               | Cannot do much other than showing some error to the user. |
| Do not need to be recorded in the crash reporting service. | Should be recorded in the crash reporting service.        |
## EaseException
A subclass of EaseFailure, intended to be thrown if the failure is expected.

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
## EaseError
A subclass of EaseFailure, intended to be throws in case of unexpected error.

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
	final doc = FirebaseFirestore.instance.collection('schools').doc(schoolId);
	final schoolDoc = await doc.get();

	if(!schoolDoc.exists) throw DocNotFoundError<School>(doc.path); // <-------
	
	return School.fromJson(schoolDoc.data()!);
}
```
# How to use?
## Step 1 - [Global Failure Configuration](#global%20configuration)
We need to configure how to handle
## Step 2 - [Wrap functions with EaseEither methods](#EaseEither)
- Synchronous Function Wrapper - EaseEither.tryRun()
- Asynchronous Function Wrapper - EaseEither.tryRunAsync()
- Parsing Wrapper - EaseEither.tryParse()

> [!NOTE]
> These [EaseEither](#EaseEither) methods returns the type `Either<Failure, T>` which forces us to handle both success and failure case. [Learn more about the Either method in here](#Either%20Type).
## Step 3 - Throwing EaseError or EaseException if needed
### Example to throw EaseException
EaseException is thrown for the expected cases. Here if the user not signed in, obviously there will be no user data. We just need to notify the user the user to sign in. We don't want this case to be logged in our crash reporting system.
```dart
User getSignedInUser() {
	final currentUser = _getCurrentUser();
	if(currentUser == null) throw EaseException('Please sign in to continue');
	return currentUser;
}
```
### Example to throw EaseError
EaseError is thrown for the unexpected cases. Here if the url doesn't have any file, then we might need to fix this in the backend. So we need to report this issue to the crash reporting system.
```dart
Future<File> downloadFileOfUrl(String url) async {
	final file = await _downloadFile(url);
	if(file == null) throw EaseError('Failed to download file');
	return file;
}
```

> [!Tip]
> Create Custom EaseError and EaseException
>


# Global Configuration
We need to configure the actions that are needed to be taken in case of EaseError and EaseException.
- exceptionActions - configure how to handle expected cases - EaseException. Could be just a logic to log exception in terminal.
- errorActions - configure how to handle unexpected cases - EaseError. Could be logic to log error in terminal and error reporting service.
- defaultErrorMessage - configure default error message to be shown to users. Defaults to `'Sorry! Something went wrong'`.
- parsingErrorLogCallback - configure how to log parsing errors. Defaults to `'Failed to parse <Type>`.
- Custom Error Parsing Logics
- Default Error Message to pass down to UI
```dart
import 'package:error_handling_ease/error_handling_ease.dart';
import 'package:logger/logger.dart';

void main() {
EaseFailure.configure(
	exceptionActions: (message) => Logger().w(message);
	errorActions: (e, s, log, isFatal, infoParams) {
		Logger().e(log, error: error, stackTrace: stackTrace);
		CrashReporter.recordError(e, s, log, infoParams: infoParams, fatal: isFatal);
	},
	defaultErrorMessage: 'Something went wrong. Please try again!'
	parsingErrorLogCallback: (type, unParsedData) => 'Failed to parse ${type.toString()} of id ${unParsedData['id']}',
	customErrorParsers: {
	  FirebaseAuthException: (e, s) {  
	    final errorCodeMessageMap = <String, String>{  
	      'invalid-email': 'The email entered is invalid. Please check again!',
	      'wrong-password': 'Email or password is incorrect. Please check again!',  
	      'email-already-in-use': 'Email already in use. Please try signing in.',
	    };  
	    final message = errorCodeMessageMap[(e as FirebaseAuthException).code];  
	    if(message != null) return EaseException(message);  
	  
	    return EaseError('Firebase Auth Exception - ${e.code}', e, s);  
	  },  
	},
}
```
### errorActions
This determines what are the actions to take in case of [EaseError](#easeerror). Usually the actions could be logging the error in the console and reporting the error to the Crash Reporting Service.
- e - Error object that was thrown
- s - StackTrace
- log, infoParams, isFatal - [EaseError](#easeerror) properties - Useful for reporting in crash reporting service.
### exceptionActions
This determines what are the actins to take in case of EaseException. Usually we just want to log the exception to the console.
- uiMessage - Text to be shown in the UI.
### defaultErrorMessage (optional)
Error message to be shown to users by default. Defaults to `Sorry! Something went wrong`.
### parsingErrorLogCallback (optional)
This determines how we log parsing errors. Defaults to `Failed to parse <Type>`.
Remember ParsingError is a type of EaseError. The unParsedData is available inside infoParams.
If we know that all models have id field, Then we could log something like `'Failed to parse ${type.toString()} of id ${unParsedData['id']}'`
### customErrorParsers (optional)
We can configure how to handle some type of error throughout the app with this customErrorParsers. Let's say, we are using Firebase Authentication in our app. Firebase authentication throws `FirebaseAuthException`. Some issues are expected and we don't want to be recorded in our backend. In this case, we can handle it here. In the example above, we have handled 3 error codes. `invalid-email`, `wrong-password` and `email-already-in-use`. These 3 are expected and we don't want them to be logged in error reporting services. So we are returning `EaseException`. If the code doesn't match with any of these, we are returning `return EaseError('Firebase Auth Exception - ${e.code}', e, s)`. This records the issue if we have configured in [errorActions](#errorActions).

# Either Type
`Either` is a functional programming concept that is used to handle exceptions/errors. Instead of using `try-catch` which will not force us to handle failure case, this Either type forces us to handle both Success and Failure case that too in a type-safe declarative way.

The Either class have two subclasses: Left and Right. The Left subclass represents the EaseFailure case, often used to store an error message or an error object. The Right subclass represents the Success case, used to store the successful result.

For example, consider a function that performs a division operation. Instead of throwing an exception when dividing by zero, it can return an Either object. The Right subclass can contain the result of the division, while the Left subclass can contain an error message. This allows the caller to handle the error gracefully and decide how to proceed based on the result.

In summary, the Either class in functional programming is used to represent a value that can be one of two possibilities, typically used to handle and propagate errors in a type-safe and composable manner.

Learn more about this in [here](https://www.sandromaglione.com/articles/either-error-handling-functional-programming).
## How to handle Either type
Let's say this function of return type `Either<EaseFailure, User>` returns logged in user
```dart
Either<EaseFailure, User> getCurrentUser() {
	return EaseEither.tryRun(() {
		final currentUser = FirebaseAuth.instance.currentUser;
		if(currentUser == null) throw EaseException('Please login to continue'); 
		return currentUser;
	});
}
```
We need to show the home page for logged in user and login page for non-logged in user.
```dart
final userResult = getCurrentUser();

userResult.fold( // <-- Either.fold method forces us to handle both failure and success case
	(failure) => push(LoginPage()), // <-- Pushing Login Page in case of failure
	(user) => push(HomePage()),     // <-- Pushing Home Page in case of success
);
```
# EaseEither
## Synchronous Function Wrapper - EaseEither.tryRun()

```dart
void result() {
	final result1 = sumOfList([1, 2]);      
	print(result1 + 10);                    // <-- 13 will be printed

	final result2 = sumOfList([1, 'xys']);  // <-- Program stops here because of error
	print(result2 + 10);                    // <-- Cannot see this result          
}

double sumOfList(List list) {  
  return list.fold(0, (previousValue, e) => previousValue + e);  
}
```

```console
13         // <-- result1 + 10;

type 'String' is not a subtype of type 'num'
Stacktrace ...
```

```dart
void result() {
	final result1 = sumOfList([1, 2]);
	print(result1.fold((l) => 0, (r) => r + 10));   // 13 will be printed

	final result2 = sumOfList([1, 'xys']);
	print(result2.fold((l) => 0, (r) => r + 10));   // 0 will be printed
}

Either<EaseFailure, double> sumOfList(List list) {  
  return EaseEither.tryRun((){                      // <-- EaseEither.tryRun
    return list.fold(0, (previousValue, e) => previousValue + e);  
  }, 'Failed to find sum of list', infoParams: {'list': list});  
}
```

```console
13         // <-- result of success case ((l) => 0, (r) => r + 10)

Failed to find sum of list
type 'String' is not a subtype of type 'num'
{list: [1, xys]}
Stacktrace ...

0          // <-- result of failure case ((l) => 0, (r) => r + 10)
```

```dart
void main() {
	EaseFailure.configure(  
	  errorActions: (e, s, log, isFatal, infoParams) {  
	    print(log);           // <-- Failed to find sum of list
	    print(e);             // <-- type 'String' is not a subtype of type 'num'
	    print(infoParams);    // <-- {list: [1, xys]}
	    print(s);             // <-- Stacktrace ...
	  },
	  ...  
	);
}
```

![](https://i.imgur.com/1h7vB57.png)
## Asynchronous Function Wrapper - EaseEither.tryRunAsync()

```dart
Future<School> fetchSchoolOfId(String schoolId) async {
	final doc = FirebaseFirestore.instance.collection('schools').doc(id);
	final schoolDoc = await doc.get();

	if(!schoolDoc.exists) throw DocNotFoundError<School>(doc.path); // <-------
	
	return School.fromJson(schoolDoc.data()!);
}
```

```dart

```
## Parsing Wrapper - EaseEither.tryParse()

# Examples

```dart
void main() {
	EaseFailure.configure(  
	    errorActions: (e, s, log, isFatal, infoParams) {  
	      print('e -> $e');  
	      print('log -> $log');  
	      print('infoParams -> $infoParams');
	      print('isFatal -> $isFatal');
	    },
![](https://i.imgur.com/raB6E74.png)

	...
	);	
}
```

```dart
final firstNumber = getFirstNumber([]);   // <-- Passing an empty list to fail
	firstNumber.fold(
		(l) => print('l.uiMessage -> ${l.uiMessage}'), 
		(r) => print('r -> $r'),
	);

Either<EaseFailure, int> getFirstNumber(List<int> numbers) {
	return EaseEither.tryRun(
		() => numbers[0], // <-- Obviously it will fail, since the list is empty
		'Failed to get first number', // <-- log in case it fails
		infoParams: {'numbers': numbers},
		uiMessage: 'Something went wrong! Please try with different numbers',
		isFatal: true,
	);
}
```

```console
e -> RangeError (length): Invalid value: Valid value range is empty: 0
log -> Failed to get first number
infoParams -> {numbers: []}
isFatal -> true
l.uiMessage -> Something went wrong! Please try with different numbers
```















## Connect with me [@Bharath](https://linktr.ee/bharath.dev)

[![image](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-3.svg)](https://www.buymeacoffee.com/bharath213)
