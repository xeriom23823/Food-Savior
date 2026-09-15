import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/sign_up/sign_up.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/auth_scaffold.dart';
import 'package:formz/formz.dart';

/// 註冊頁。與登入頁共用外殼與錯誤區塊，成功後回到登入狀態流程。
class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isSuccess) Navigator.of(context).pop();
      },
      child: AuthScaffold(
        title: S.of(context).signUpWelcome,
        showBack: true,
        children: [
          const _ErrorBanner(),
          _EmailInput(),
          const SizedBox(height: AppSpacing.md),
          _PasswordInput(),
          const SizedBox(height: AppSpacing.md),
          _ConfirmPasswordInput(),
          const SizedBox(height: AppSpacing.lg),
          _SignUpButton(),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (!state.status.isFailure) return const SizedBox.shrink();
        return AuthErrorBanner(
          message: state.errorMessage ?? S.of(context).signUpFailure,
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_emailInput_textField'),
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
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
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<SignUpCubit>().passwordChanged(password),
          obscureText: true,
          textInputAction: TextInputAction.next,
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

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_confirmedPasswordInput_textField'),
          onChanged: (confirmPassword) => context
              .read<SignUpCubit>()
              .confirmedPasswordChanged(confirmPassword),
          obscureText: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: S.of(context).confirmPassword,
            errorText: state.confirmedPassword.displayError != null
                ? S.of(context).passwordsDoNotMatch
                : null,
          ),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        return FilledButton(
          key: const Key('signUpForm_continue_raisedButton'),
          onPressed: state.isValid && !state.status.isInProgress
              ? () => context.read<SignUpCubit>().signUpFormSubmitted()
              : null,
          child: state.status.isInProgress
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.of(context).signUp),
        );
      },
    );
  }
}
