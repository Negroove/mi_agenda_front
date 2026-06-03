import 'package:flutter_test/flutter_test.dart';
import 'package:mi_agenda/models/contact.dart';
import 'package:mi_agenda/providers/contacts_provider.dart';

import 'fakes/fake_contacts_api.dart';

void main() {
  Contact contact({
    String id = '1',
    String nombre = 'Juan',
    String apellido = 'Perez',
    String telefono = '123',
    String email = 'juan@test.com',
  }) {
    return Contact(
      id: id,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      email: email,
    );
  }

  test('load() carga datos correctamente', () async {
    final api = FakeContactsApi(initialContacts: [
      contact(),
      contact(id: '2', nombre: 'Ana', email: 'ana@test.com'),
    ]);
    final provider = ContactsProvider(api: api);

    await provider.load();

    expect(provider.items.length, 2);
    expect(provider.items.first.nombre, 'Juan');
    expect(provider.isLoading, false);
    expect(provider.error, isNull);
  });

  test('add() agrega y recarga lista', () async {
    final api = FakeContactsApi(initialContacts: [contact()]);
    final provider = ContactsProvider(api: api);

    await provider.add(
      contact(id: '2', nombre: 'Ana', email: 'ana@test.com'),
    );

    expect(provider.items.length, 2);
    expect(provider.items.last.nombre, 'Ana');
    expect(provider.isLoading, false);
    expect(provider.error, isNull);
  });

  test('update() modifica un contacto', () async {
    final api = FakeContactsApi(initialContacts: [contact()]);
    final provider = ContactsProvider(api: api);

    await provider.update(
      contact(nombre: 'Juan editado', email: 'editado@test.com'),
    );

    expect(provider.items.length, 1);
    expect(provider.items.first.nombre, 'Juan editado');
    expect(provider.items.first.email, 'editado@test.com');
    expect(provider.error, isNull);
  });

  test('delete() elimina un contacto', () async {
    final api = FakeContactsApi(initialContacts: [
      contact(),
      contact(id: '2', nombre: 'Ana', email: 'ana@test.com'),
    ]);
    final provider = ContactsProvider(api: api);

    await provider.delete('1');

    expect(provider.items.length, 1);
    expect(provider.items.first.id, '2');
    expect(provider.error, isNull);
  });

  test('error se setea si falla API', () async {
    final api = FakeContactsApi(shouldFail: true);
    final provider = ContactsProvider(api: api);

    await provider.load();

    expect(provider.items, isEmpty);
    expect(provider.isLoading, false);
    expect(provider.error, isNotNull);
    expect(provider.error, contains('Error fake'));
  });
}
