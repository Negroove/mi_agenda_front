import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _usuarioCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _usuarioFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _usuarioFocus.dispose();
    _passFocus.dispose();
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateUsuario(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingrese su usuario';
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese su contrasena';
    return null;
  }

  void _goToPassword() => _passFocus.requestFocus();
  void _toggleObscure() => setState(() => _obscure = !_obscure);

  Future<void> _submit() async {
  FocusScope.of(context).unfocus();
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  final auth = context.read<AuthProvider>();
  final usuario = _usuarioCtrl.text.trim();
  final password = _passCtrl.text.trim();

  debugPrint('LoginForm.submit usuario: $usuario');
  debugPrint('LoginForm.submit password length: ${password.length}');

  final ok = await auth.login(usuario, password);

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
            'Usuario',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _usuarioCtrl,
            focusNode: _usuarioFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _goToPassword(),
            decoration: const InputDecoration(hintText: 'Ingrese usuario'),
            validator: _validateUsuario,
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
        ],
      ),
    );
  }
}
