import 'package:flutter/material.dart';
import 'package:mi_agenda/models/contact.dart';
import 'package:mi_agenda/providers/contacts_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


class ContactFormScreen extends StatefulWidget {
  final Contact? edit; // 👈 NUEVO — Si viene un contacto, es edición

  const ContactFormScreen({super.key, this.edit});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // controladores
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    // Si es modo edición, precargo los datos en los campos
    final c = widget.edit;
    if (c != null) {
      _nombreCtrl.text = c.nombre;
      _apellidoCtrl.text = c.apellido;
      _telCtrl.text = c.telefono;
      _emailCtrl.text = c.email;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // --- Validadores simples ---
  String? _req(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'Ingrese $campo' : null;

  String? _validEmail(String? v) {
    if (_req(v, 'el email') != null) return 'Ingrese el email';
    if (!(v!.contains('@') && v.contains('.'))) return 'Email inválido';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // ---------------------------
    // MODO CREAR
    // ---------------------------
    if (widget.edit == null) {
      final contact = Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      await context.read<ContactsProvider>().add(contact);
    } else {
      // ---------------------------
      // MODO EDITAR
      // ---------------------------
      final updated = Contact(
        id: widget.edit!.id,
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      await context.read<ContactsProvider>().update(updated);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit == null ? 'Nuevo contacto' : 'Editar contacto'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Nombre
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _req(v, 'el nombre'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'\-]"),
                    ),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
                const SizedBox(height: 12),

                // Apellido
                TextFormField(
                  controller: _apellidoCtrl,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _req(v, 'el apellido'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'\-]"),
                    ),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
                const SizedBox(height: 12),

                // Teléfono
                TextFormField(
                  controller: _telCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _req(v, 'el teléfono'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9+\s\-]")),
                    LengthLimitingTextInputFormatter(18),
                  ],
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validEmail,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                    LengthLimitingTextInputFormatter(60),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
