import 'dart:async';

import 'package:async/async.dart';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// {@template sign_up_with_email_and_password_failure}
/// Thrown during the sign up process if a failure occurs.
/// {@endtemplate}
class SignUpWithEmailAndPasswordFailure implements Exception {
  /// {@macro sign_up_with_email_and_password_failure}
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_email_and_password_failure}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
/// {@endtemplate}
class LogInWithEmailAndPasswordFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-credential':
        return const LogInWithEmailAndPasswordFailure(
          'The credential received is malformed or has expired.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class LogInWithGoogleFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// Create an authentication message from a google_sign_in exception.
  ///
  /// Note: on Android, a missing or mismatched signing SHA-1 in the Firebase
  /// project surfaces as [GoogleSignInExceptionCode.canceled] (Credential
  /// Manager dismisses the picker), so the "cancelled" message also hints at
  /// configuration.
  factory LogInWithGoogleFailure.fromGoogleSignIn(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return const LogInWithGoogleFailure(
          'Sign in was cancelled. If you did not cancel, check that this '
          "build's signing SHA-1 is registered in the Firebase project.",
        );
      case GoogleSignInExceptionCode.interrupted:
        return const LogInWithGoogleFailure(
          'Sign in was interrupted. Please try again.',
        );
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return LogInWithGoogleFailure(
          'Google Sign-In is not configured correctly'
          '${e.description == null ? '' : ': ${e.description}'}.',
        );
      case GoogleSignInExceptionCode.uiUnavailable:
        return const LogInWithGoogleFailure(
          'Google Sign-In UI is unavailable on this device.',
        );
      case GoogleSignInExceptionCode.userMismatch:
        return const LogInWithGoogleFailure(
          'A different Google account was returned than requested.',
        );
      case GoogleSignInExceptionCode.unknownError:
        return LogInWithGoogleFailure(
          'Google Sign-In failed'
          '${e.description == null ? '' : ': ${e.description}'}.',
        );
    }
  }

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// Thrown when updating the display name fails.
class UpdateDisplayNameFailure implements Exception {
  const UpdateDisplayNameFailure([
    this.message = 'An unknown error occurred.',
  ]);

  final String message;
}

/// Thrown when sending a password reset email fails.
class ResetPasswordFailure implements Exception {
  const ResetPasswordFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Maps a Firebase error code onto a message the UI can show.
  factory ResetPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const ResetPasswordFailure(
            'Email is not valid or badly formatted.');
      case 'user-not-found':
        return const ResetPasswordFailure('No user found for that email.');
      default:
        return const ResetPasswordFailure();
    }
  }

  final String message;
}

/// Why deleting the account failed. [requiresRecentLogin] is the one the UI
/// must handle specially: Firebase refuses to delete a long-lived session.
enum DeleteAccountFailureReason { requiresRecentLogin, unknown }

/// Thrown when deleting the account fails.
class DeleteAccountFailure implements Exception {
  const DeleteAccountFailure([
    this.reason = DeleteAccountFailureReason.unknown,
    this.message,
  ]);

  factory DeleteAccountFailure.fromCode(String code, [String? message]) {
    return code == 'requires-recent-login'
        ? DeleteAccountFailure(
            DeleteAccountFailureReason.requiresRecentLogin, message)
        : DeleteAccountFailure(DeleteAccountFailureReason.unknown, message);
  }

  final DeleteAccountFailureReason reason;
  final String? message;
}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleSignInInitialization;

  /// google_sign_in 7 requires a single [GoogleSignIn.initialize] call before
  /// any other method. On Android the web OAuth client in google-services.json
  /// is picked up automatically as the serverClientId (needed for the ID token).
  Future<void> _ensureGoogleSignInInitialized() =>
      _googleSignInInitialization ??= _googleSignIn.initialize();

  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Profile updates (display name) do not trigger [authStateChanges], so the
  /// repository pushes the reloaded user onto this controller itself.
  final StreamController<User> _profileUpdates =
      StreamController<User>.broadcast();

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes, or when the profile is updated.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    final authChanges = _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
    return StreamGroup.merge([authChanges, _profileUpdates.stream]);
  }

  /// Releases the profile update controller. Only needed in tests; the app
  /// keeps a single repository for its whole lifetime.
  Future<void> dispose() => _profileUpdates.close();

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        await _ensureGoogleSignInInitialized();
        final googleUser = await _googleSignIn.authenticate();
        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          throw const LogInWithGoogleFailure(
            'Google Sign-In did not return an ID token.',
          );
        }
        // google_sign_in 7 no longer exposes an access token here; Firebase only
        // needs the ID token to build the credential.
        credential = firebase_auth.GoogleAuthProvider.credential(
          idToken: idToken,
        );
      }

      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } on GoogleSignInException catch (e) {
      throw LogInWithGoogleFailure.fromGoogleSignIn(e);
    } on LogInWithGoogleFailure {
      rethrow;
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Updates the display name and re-emits the user so the UI can show the
  /// new name without a new sign-in.
  ///
  /// Throws an [UpdateDisplayNameFailure] if an exception occurs.
  Future<void> updateDisplayName(String name) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) throw const UpdateDisplayNameFailure();
    try {
      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();
      final updated = _firebaseAuth.currentUser?.toUser ?? User.empty;
      _cache.write(key: userCacheKey, value: updated);
      _profileUpdates.add(updated);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw UpdateDisplayNameFailure(e.message ?? 'An unknown error occurred.');
    } catch (_) {
      throw const UpdateDisplayNameFailure();
    }
  }

  /// Sends a password reset email to [email].
  ///
  /// Throws a [ResetPasswordFailure] if an exception occurs.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ResetPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const ResetPasswordFailure();
    }
  }

  /// Deletes the current Firebase account. Local food data is untouched.
  ///
  /// Throws a [DeleteAccountFailure] if an exception occurs; the
  /// [DeleteAccountFailureReason.requiresRecentLogin] case must be surfaced to
  /// the user as "sign in again and retry".
  Future<void> deleteAccount() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) throw const DeleteAccountFailure();
    try {
      await firebaseUser.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw DeleteAccountFailure.fromCode(e.code, e.message);
    } catch (_) {
      throw const DeleteAccountFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      // Web signs in through the Firebase popup and never touches GoogleSignIn.
      if (!isWeb) await _ensureGoogleSignInInitialized();
      await Future.wait([
        _firebaseAuth.signOut(),
        if (!isWeb) _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  /// Maps a [firebase_auth.User] into a [User].
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
