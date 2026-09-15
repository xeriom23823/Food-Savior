part of 'login_cubit.dart';

/// 重設密碼是登入頁的次要動作，狀態跟登入本身分開，
/// 否則「信寄出去了」會被誤判成「登入成功」。
enum PasswordResetStatus { idle, sending, sent, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.resetStatus = PasswordResetStatus.idle,
  });

  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;
  final PasswordResetStatus resetStatus;

  @override
  List<Object?> get props =>
      [email, password, status, isValid, errorMessage, resetStatus];

  LoginState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    PasswordResetStatus? resetStatus,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      resetStatus: resetStatus ?? this.resetStatus,
    );
  }
}
