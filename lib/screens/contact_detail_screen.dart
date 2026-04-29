import 'package:flutter/material.dart';
import 'package:mi_agenda/screens/widgets/contact_form_screen.dart';
import 'package:provider/provider.dart';
import '../providers/contacts_provider.dart';

class ContactDetailScreen extends StatelessWidget {
  final String contactId;

  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    final contact = context.watch<ContactsProvider>()
        .items
        .firstWhere((c) => c.id == contactId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${contact.nombre} ${contact.apellido}'),
        actions: [
          // EDITAR
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContactFormScreen(edit: contact),
                ),
              );

            },
          ),

          // ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar',
            onPressed: () => _confirmDelete(context, contact.id),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                contact.iniciales,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),

            Text('Teléfono: ${contact.telefono}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),

            Text('Email: ${contact.email}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),

            Text('Dirección: ${contact.direccion}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),

            if (contact.fechaNacimiento != null)
              Text(
                'Fecha de nacimiento: '
                '${contact.fechaNacimiento!.day}/'
                '${contact.fechaNacimiento!.month}/'
                '${contact.fechaNacimiento!.year}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

 void _confirmDelete(BuildContext context, String id) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Eliminar contacto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              '¿Seguro que deseas eliminar este contacto?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 26),

            // 🔵 BOTÓN ELIMINAR (MISMO COLOR DEL TEMA)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final contacts = context.read<ContactsProvider>();
                  final navigator = Navigator.of(context);

                  await contacts.delete(id);
                  navigator.pop();
                  navigator.pop();
                },
                child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 12),

            // ⚫ BOTÓN CANCELAR (NEGRO) — FULL WIDTH
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
