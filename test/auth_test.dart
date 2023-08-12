import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/auth_user.dart';
import 'package:first_app/services/auth/auth_provider.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockProvider();

    test("Provider should not be initialized in the beginning", () {
      expect(provider.isInitialized, false);
    });

    test("Unable to log out before initialization", () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test("Should be able to initialize", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("Should be able to initialize in less than 2 seconds", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test("Create user should delegate to login function", () async {
      final badEmail = provider.createUser(
        email: "nouser@test.com",
        password: "any",
      );

      expect(badEmail, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassword = provider.createUser(
        email: "anyemail@test.com",
        password: "wrong_password",
      );

      expect(badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: "anyemail@test.com",
        password: "anyPassword",
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Send email verification", () async {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(email: "email", password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockProvider implements AuthProvider {
  AuthUser? _user;

  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == "nouser@test.com") throw UserNotFoundAuthException();
    if (password == "wrong_password") throw WrongPasswordAuthException();

    await Future.delayed(const Duration(seconds: 1));
    var user = const AuthUser(isEmailVerified: false, email: "a");
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    } else {
      _user = const AuthUser(isEmailVerified: true, email: "a");
    }
    ;
  }
}
