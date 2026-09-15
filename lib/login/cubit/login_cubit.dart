import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  /// 寄出重設密碼信。Email 欄位無效時不寄，直接把錯誤標在欄位上。
  Future<void> sendPasswordReset() async {
    final email = Email.dirty(state.email.value);
    if (email.isNotValid) {
      emit(state.copyWith(
        email: email,
        resetStatus: PasswordResetStatus.failure,
        errorMessage: null,
      ));
      return;
    }

    emit(state.copyWith(resetStatus: PasswordResetStatus.sending));
    try {
      await _authenticationRepository.sendPasswordResetEmail(email.value);
      emit(state.copyWith(resetStatus: PasswordResetStatus.sent));
    } on ResetPasswordFailure catch (e) {
      emit(state.copyWith(
        resetStatus: PasswordResetStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(resetStatus: PasswordResetStatus.failure));
    }
  }

  /// 使用者看過回饋後把狀態收回，避免重建時又跳一次。
  void acknowledgePasswordReset() =>
      emit(state.copyWith(resetStatus: PasswordResetStatus.idle));

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
