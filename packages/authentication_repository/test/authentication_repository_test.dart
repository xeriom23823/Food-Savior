import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseUser firebaseUser;
  late AuthenticationRepository repository;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    firebaseUser = MockFirebaseUser();

    when(() => firebaseUser.uid).thenReturn('uid-1');
    when(() => firebaseUser.email).thenReturn('a@b.c');
    when(() => firebaseUser.photoURL).thenReturn(null);
    when(() => firebaseUser.displayName).thenReturn(null);
    when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
    when(() => firebaseAuth.authStateChanges())
        .thenAnswer((_) => Stream<firebase_auth.User?>.value(firebaseUser));

    repository = AuthenticationRepository(
      cache: CacheClient(),
      firebaseAuth: firebaseAuth,
    );
  });

  tearDown(() => repository.dispose());

  group('更新顯示名稱', () {
    test('更新後重新載入，並在 user 串流上再發射一次', () async {
      // reload() 之後 currentUser 會換成帶新名字的那一個，模擬 Firebase 的行為。
      final reloaded = MockFirebaseUser();
      when(() => reloaded.uid).thenReturn('uid-1');
      when(() => reloaded.email).thenReturn('a@b.c');
      when(() => reloaded.photoURL).thenReturn(null);
      when(() => reloaded.displayName).thenReturn('小明');

      firebase_auth.User? current = firebaseUser;
      when(() => firebaseAuth.currentUser).thenAnswer((_) => current);
      when(() => firebaseUser.updateDisplayName(any()))
          .thenAnswer((_) async {});
      when(() => firebaseUser.reload()).thenAnswer((_) async {
        current = reloaded;
      });

      final names = <String?>[];
      final subscription =
          repository.user.listen((user) => names.add(user.name));
      await Future<void>.delayed(Duration.zero);

      await repository.updateDisplayName('小明');
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(names, [null, '小明']);
      verify(() => firebaseUser.updateDisplayName('小明')).called(1);
      verify(() => firebaseUser.reload()).called(1);
    });

    test('沒有登入使用者時丟出 UpdateDisplayNameFailure', () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      expect(
        () => repository.updateDisplayName('小明'),
        throwsA(isA<UpdateDisplayNameFailure>()),
      );
    });
  });

  group('重設密碼', () {
    test('寄出成功', () async {
      when(() =>
              firebaseAuth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async {});

      await repository.sendPasswordResetEmail('a@b.c');

      verify(() => firebaseAuth.sendPasswordResetEmail(email: 'a@b.c'))
          .called(1);
    });

    test('invalid-email 轉成可讀訊息', () async {
      when(() =>
              firebaseAuth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenThrow(
              firebase_auth.FirebaseAuthException(code: 'invalid-email'));

      await expectLater(
        repository.sendPasswordResetEmail('nope'),
        throwsA(
          isA<ResetPasswordFailure>().having(
            (failure) => failure.message,
            'message',
            contains('not valid'),
          ),
        ),
      );
    });
  });

  group('刪除帳號', () {
    test('刪除成功', () async {
      when(() => firebaseUser.delete()).thenAnswer((_) async {});

      await repository.deleteAccount();

      verify(() => firebaseUser.delete()).called(1);
    });

    test('requires-recent-login 對應到專屬原因', () async {
      when(() => firebaseUser.delete()).thenThrow(
        firebase_auth.FirebaseAuthException(code: 'requires-recent-login'),
      );

      await expectLater(
        repository.deleteAccount(),
        throwsA(
          isA<DeleteAccountFailure>().having(
            (failure) => failure.reason,
            'reason',
            DeleteAccountFailureReason.requiresRecentLogin,
          ),
        ),
      );
    });

    test('其他錯誤歸類為 unknown', () async {
      when(() => firebaseUser.delete())
          .thenThrow(firebase_auth.FirebaseAuthException(code: 'network'));

      await expectLater(
        repository.deleteAccount(),
        throwsA(
          isA<DeleteAccountFailure>().having(
            (failure) => failure.reason,
            'reason',
            DeleteAccountFailureReason.unknown,
          ),
        ),
      );
    });
  });

  group('user 串流', () {
    test('登入狀態改變仍會發射（改造後沒有壞掉）', () async {
      final emitted = <User>[];
      final subscription = repository.user.listen(emitted.add);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(emitted, hasLength(1));
      expect(emitted.single.id, 'uid-1');
      expect(repository.currentUser.id, 'uid-1');
    });
  });
}
