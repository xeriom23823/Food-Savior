import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/app.dart';
import 'package:food_savior/pages/user_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/widgets/avatar.dart';
import 'package:mocktail/mocktail.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUser extends Mock implements User {}

void main() {
  const logoutButtonKey = Key('UserPage_logout_iconButton');
  group('UserPage', () {
    late AppBloc appBloc;
    late User user;

    setUp(() {
      appBloc = MockAppBloc();
      user = MockUser();
      when(() => user.email).thenReturn('test@gmail.com');
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
    });

    group('calls', () {
      testWidgets('AppLogoutRequested when logout is pressed', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: appBloc,
            child: const MaterialApp(home: UserPage()),
          ),
        );
        await tester.tap(find.byKey(logoutButtonKey));
        verify(() => appBloc.add(const AppLogoutRequested())).called(1);
      });
    });

    group('renders', () {
      testWidgets('avatar widget', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: appBloc,
            child: const MaterialApp(home: UserPage()),
          ),
        );
        expect(find.byType(Avatar), findsOneWidget);
      });

      testWidgets('email address', (tester) async {
        await tester.pumpWidget(
          BlocProvider.value(
            value: appBloc,
            child: const MaterialApp(home: UserPage()),
          ),
        );
        expect(find.text('test@gmail.com'), findsOneWidget);
      });

      testWidgets('name', (tester) async {
        when(() => user.name).thenReturn('Joe');
        await tester.pumpWidget(
          BlocProvider.value(
            value: appBloc,
            child: const MaterialApp(home: UserPage()),
          ),
        );
        expect(find.text('Joe'), findsOneWidget);
      });
    });
  });
}
