import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/contacts_provider.dart';
import 'screens/login_screen.dart';
import 'screens/contacts_screen.dart';
import 'data/contacts_db.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // proveedores de estados
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContactsProvider(ContactsDb())),
      ],
      // la app en si
      child: MaterialApp(
        title: 'Mi Agenda',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    // cargamos SharedPreferences e hidratamos isAuth
    Future.microtask(() async {
      await auth.init();
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // mientras lee prefs, mostramos loader
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // si ya estaba autenticado, va directo a Contactos
    final isAuth = context.watch<AuthProvider>().isAuth;
    return isAuth ? const ContactsScreen() : const LoginScreen();
  }
}
