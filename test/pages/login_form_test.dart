import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/login/login.dart';
import 'package:food_savior/widgets/auth_scaffold.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/widget_test_helper.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late MockAuthenticationRepository repository;

  setUp(() => repository = MockAuthenticationRepository());

  Future<void> pumpForm(
    WidgetTester tester, {
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(wrapForTest(
      RepositoryProvider<AuthenticationRepository>.value(
        value: repository,
        child: BlocProvider(
          create: (_) => LoginCubit(repository),
          child: const LoginForm(),
        ),
      ),
      locale: locale,
      brightness: brightness,
    ));
    await tester.pump();
  }

  testWidgets('渲染標題、兩個欄位與三個動作', (tester) async {
    await pumpForm(tester);

    expect(find.text('歡迎回來'), findsOneWidget);
    expect(find.text('電子郵件'), findsOneWidget);
    expect(find.text('密碼'), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('使用 Google 登入'), findsOneWidget);
    expect(find.text('忘記密碼？'), findsOneWidget);
    expect(find.text('建立帳號'), findsOneWidget);
  });

  testWidgets('登入失敗時錯誤顯示在表單上方的固定區塊，不是 SnackBar', (tester) async {
    when(() => repository.logInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const LogInWithEmailAndPasswordFailure('帳號或密碼不正確'));

    await pumpForm(tester);
    await tester.enterText(
      find.byKey(const Key('loginForm_emailInput_textField')),
      'a@b.c',
    );
    await tester.enterText(
      find.byKey(const Key('loginForm_passwordInput_textField')),
      'Passw0rd1',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('loginForm_continue_raisedButton')));
    // 送出是 async，要多推一幀才會看到失敗狀態。
    await tester.pump();
    await tester.pump();

    expect(find.byType(AuthErrorBanner), findsOneWidget);
    expect(find.text('帳號或密碼不正確'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Email 無效時按忘記密碼不寄信', (tester) async {
    await pumpForm(tester);
    await tester.enterText(
      find.byKey(const Key('loginForm_emailInput_textField')),
      'not-an-email',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('loginForm_forgotPassword_textButton')),
    );
    await tester.pump();

    verifyNever(() => repository.sendPasswordResetEmail(any()));
    expect(find.text('無效的電子郵件'), findsWidgets);
  });

  testWidgets('寄出重設信後顯示成功回饋', (tester) async {
    when(() => repository.sendPasswordResetEmail(any()))
        .thenAnswer((_) async {});

    await pumpForm(tester);
    await tester.enterText(
      find.byKey(const Key('loginForm_emailInput_textField')),
      'a@b.c',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('loginForm_forgotPassword_textButton')),
    );
    await tester.pump();
    await tester.pump();

    verify(() => repository.sendPasswordResetEmail('a@b.c')).called(1);
    expect(find.text('重設密碼的信已寄出，請到信箱查看'), findsOneWidget);
  });

  testWidgets('英文語系與深色主題都能渲染', (tester) async {
    await pumpForm(
      tester,
      locale: const Locale('en', 'US'),
      brightness: Brightness.dark,
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
