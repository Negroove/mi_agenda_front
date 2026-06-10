import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_agenda/providers/auth_provider.dart';
import 'package:mi_agenda/screens/widgets/login_form.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildLoginForm() {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MaterialApp(
        home: Scaffold(
          body: LoginForm(),
        ),
      ),
    );
  }

  testWidgets('LoginForm renderiza inputs y boton login', (tester) async {
    await tester.pumpWidget(buildLoginForm());

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contrasena'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });

  testWidgets('LoginForm muestra validaciones basicas', (tester) async {
    await tester.pumpWidget(buildLoginForm());

    await tester.tap(find.text('Iniciar sesion'));
    await tester.pump();

    expect(find.text('Ingrese su email'), findsOneWidget);
    expect(find.text('Ingrese su contrasena'), findsOneWidget);
  });
}
