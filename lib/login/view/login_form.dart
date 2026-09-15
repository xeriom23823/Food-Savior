import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/login/login.dart';
import 'package:food_savior/sign_up/sign_up.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/app_snack_bar.dart';
import 'package:food_savior/widgets/auth_scaffold.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';

/// 登入頁。錯誤訊息固定在表單上方，不用會蓋住按鈕的 SnackBar（design D8）。
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.resetStatus != current.resetStatus &&
          current.resetStatus == PasswordResetStatus.sent,
      listener: (context, state) {
        AppSnackBar.show(context, message: strings.resetPasswordSent);
        context.read<LoginCubit>().acknowledgePasswordReset();
      },
      child: AuthScaffold(
        title: strings.loginWelcome,
        children: [
          const _ErrorBanner(),
          _EmailInput(),
          const SizedBox(height: AppSpacing.md),
          _PasswordInput(),
          const SizedBox(height: AppSpacing.xs),
          const _ForgotPasswordButton(),
          const SizedBox(height: AppSpacing.md),
          _LoginButton(),
          const SizedBox(height: AppSpacing.md),
          _GoogleLoginButton(),
          const SizedBox(height: AppSpacing.lg),
          const _SignUpButton(),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.resetStatus != current.resetStatus,
      builder: (context, state) {
        final strings = S.of(context);
        final hasLoginError = state.status.isFailure;
        final hasResetError = state.resetStatus == PasswordResetStatus.failure;
        if (!hasLoginError && !hasResetError) return const SizedBox.shrink();

        final message = state.errorMessage ??
            (hasResetError
                ? strings.resetPasswordFailure
                : strings.logInFailure);
        return AuthErrorBanner(message: message);
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: S.of(context).email,
            errorText: state.email.displayError != null
                ? S.of(context).invalidEmail
                : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => context.read<LoginCubit>().logInWithCredentials(),
          decoration: InputDecoration(
            labelText: S.of(context).password,
            errorText: state.password.displayError != null
                ? S.of(context).invalidPassword
                : null,
          ),
        );
      },
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.resetStatus != current.resetStatus,
      builder: (context, state) {
        final sending = state.resetStatus == PasswordResetStatus.sending;
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            key: const Key('loginForm_forgotPassword_textButton'),
            onPressed:
                sending ? null : context.read<LoginCubit>().sendPasswordReset,
            child: Text(S.of(context).forgotPassword),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return FilledButton(
          key: const Key('loginForm_continue_raisedButton'),
          onPressed: state.isValid && !state.status.isInProgress
              ? () => context.read<LoginCubit>().logInWithCredentials()
              : null,
          child: state.status.isInProgress
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.of(context).logIn),
        );
      },
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      key: const Key('loginForm_googleLogin_raisedButton'),
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
      icon: const FaIcon(FontAwesomeIcons.google, size: 16),
      label: Text(S.of(context).signInWithGoogle),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          strings.noAccountYet,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        TextButton(
          key: const Key('loginForm_createAccount_flatButton'),
          onPressed: () => Navigator.of(context).push<void>(SignUpPage.route()),
          child: Text(strings.createAccount),
        ),
      ],
    );
  }
}
