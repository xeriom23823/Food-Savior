import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/login/login.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late MockAuthenticationRepository repository;

  setUp(() => repository = MockAuthenticationRepository());

  group('重設密碼', () {
    blocTest<LoginCubit, LoginState>(
      'Email 無效時不寄信，狀態為 failure',
      build: () => LoginCubit(repository),
      act: (cubit) {
        cubit.emailChanged('not-an-email');
        return cubit.sendPasswordReset();
      },
      verify: (cubit) {
        expect(cubit.state.resetStatus, PasswordResetStatus.failure);
        verifyNever(() => repository.sendPasswordResetEmail(any()));
      },
    );

    blocTest<LoginCubit, LoginState>(
      '寄出成功後狀態為 sent',
      setUp: () {
        when(() => repository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {});
      },
      build: () => LoginCubit(repository),
      act: (cubit) {
        cubit.emailChanged('a@b.c');
        return cubit.sendPasswordReset();
      },
      verify: (cubit) {
        expect(cubit.state.resetStatus, PasswordResetStatus.sent);
        verify(() => repository.sendPasswordResetEmail('a@b.c')).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      '寄信失敗時帶出錯誤訊息',
      setUp: () {
        when(() => repository.sendPasswordResetEmail(any()))
            .thenThrow(const ResetPasswordFailure('沒有這個帳號'));
      },
      build: () => LoginCubit(repository),
      act: (cubit) {
        cubit.emailChanged('a@b.c');
        return cubit.sendPasswordReset();
      },
      verify: (cubit) {
        expect(cubit.state.resetStatus, PasswordResetStatus.failure);
        expect(cubit.state.errorMessage, '沒有這個帳號');
      },
    );

    blocTest<LoginCubit, LoginState>(
      '回饋看過之後狀態收回 idle，不會再跳一次',
      setUp: () {
        when(() => repository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {});
      },
      build: () => LoginCubit(repository),
      act: (cubit) async {
        cubit.emailChanged('a@b.c');
        await cubit.sendPasswordReset();
        cubit.acknowledgePasswordReset();
      },
      verify: (cubit) {
        expect(cubit.state.resetStatus, PasswordResetStatus.idle);
      },
    );
  });
}
