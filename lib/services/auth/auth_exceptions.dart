//import 'package:firebase_auth/firebase_auth.dart';

//import '../../firebase_options.dart';

// login exception
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register exception
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// generic exception
class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}
