import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  // used to set up the authentication services
  Future<void> initialize();

  // get currently authenticated user
  // if null means there is no authenticated user
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}
