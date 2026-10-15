import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:voxlab/core/network/api_client.dart';
import 'package:voxlab/core/router/routes.dart';
import 'package:voxlab/data/local/local_progress_store.dart';
import 'package:voxlab/domain/models/user.dart';
import 'package:voxlab/domain/models/progress.dart';
import 'package:voxlab/domain/repositories/i_auth_repository.dart';
import 'package:voxlab/presentation/features/auth/register_screen.dart';
import 'package:voxlab/presentation/shared/widgets/chunky.dart';

import '../golden/golden_fonts.dart';
import 'package:voxlab/presentation/shared/providers/repository_providers.dart';

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.registerError});

  final Object? registerError;
  int registerCalls = 0;
  String? lastEmail;

  @override
  Future<User> register(String name, String email, String password) async {
    registerCalls++;
    lastEmail = email;
    if (registerError != null) throw registerError!;
    return User(
      id: 'u1',
      name: name,
      email: email,
      role: 'user',
      xp: 0,
      streakDays: 0,
    );
  }

  @override
  Future<User> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<User> getCurrentUser() => throw UnimplementedError();

  @override
  Future<User> updateProfile({String? name, String? avatarUrl}) =>
      throw UnimplementedError();

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  String? getToken() => null;
}

class _FakeLocalProgressStore extends LocalProgressStore {
  _FakeLocalProgressStore() : super.test();
  final Map<String, List<Progress>> _data = {};

  @override
  Future<List<Progress>> load(String userId) async {
    return _data[userId] ?? [];
  }

  @override
  Future<void> save(String userId, List<Progress> entries) async {
    _data[userId] = entries;
  }

  @override
  Future<void> clear(String userId) async {
    _data.remove(userId);
  }
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.register,
    routes: [
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (_, _) => const Scaffold(body: Text('MAP_OK')),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const Scaffold(body: Text('LOGIN_OK')),
      ),
    ],
  );
}

Future<void> _pumpRegisterScreen(
  WidgetTester tester,
  _FakeAuthRepository repo,
) async {
  useReducedMotion(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        localProgressStoreProvider.overrideWithValue(_FakeLocalProgressStore()),
      ],
      child: MaterialApp.router(routerConfig: _buildRouter()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Test User');
  await tester.enterText(fields.at(1), 'test@example.com');
  await tester.enterText(fields.at(2), 'secret123');
  await tester.enterText(fields.at(3), 'secret123');
}

void main() {
  testWidgets('successful register calls repository and navigates to map',
      (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repo);

    await _fillForm(tester);
    await tester.tap(find.widgetWithText(ChunkyButton, 'CREAR CUENTA'));
    await tester.pumpAndSettle();

    expect(repo.registerCalls, 1);
    expect(repo.lastEmail, 'test@example.com');
    expect(find.text('MAP_OK'), findsOneWidget);
  });

  testWidgets('register error shows friendly message and re-enables button',
      (tester) async {
    final repo = _FakeAuthRepository(
      registerError: ServerException(
        'Ese email ya está registrado. Probá iniciar sesión.',
      ),
    );
    await _pumpRegisterScreen(tester, repo);

    await _fillForm(tester);
    await tester.tap(find.widgetWithText(ChunkyButton, 'CREAR CUENTA'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ese email ya está registrado. Probá iniciar sesión.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ChunkyButton, 'CREAR CUENTA'), findsOneWidget);
    expect(find.text('MAP_OK'), findsNothing);
  });

  testWidgets('unexpected error never leaks raw debug text', (tester) async {
    final repo = _FakeAuthRepository(registerError: const FormatException());
    await _pumpRegisterScreen(tester, repo);

    await _fillForm(tester);
    await tester.tap(find.widgetWithText(ChunkyButton, 'CREAR CUENTA'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No pudimos procesar la respuesta del servidor. Intentá de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('FormatException'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('invalid email is rejected before calling repository',
      (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpRegisterScreen(tester, repo);

    await _fillForm(tester);
    // Enter invalid email
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'not-an-email');
    await tester.tap(find.widgetWithText(ChunkyButton, 'CREAR CUENTA'));
    await tester.pumpAndSettle();

    expect(find.text('Email inválido'), findsOneWidget);
    expect(repo.registerCalls, 0);
  });
}