import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../register_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailFocus.dispose();
    _passFocus.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingrese su email';
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese su contrasena';
    return null;
  }

  void _goToPassword() => _passFocus.requestFocus();
  void _toggleObscure() => setState(() => _obscure = !_obscure);

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    debugPrint('LoginForm.submit email: $email');
    debugPrint('LoginForm.submit password length: ${password.length}');

    final ok = await auth.login(email, password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales invalidas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Email',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _goToPassword(),
            decoration: const InputDecoration(hintText: 'Ingrese email'),
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          const Text(
            'Contrasena',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passCtrl,
            focusNode: _passFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: 'Ingrese password',
              suffixIcon: IconButton(
                onPressed: _toggleObscure,
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: _validatePass,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Iniciar sesion'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading ? null : _goToRegister,
            child: const Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }
}
