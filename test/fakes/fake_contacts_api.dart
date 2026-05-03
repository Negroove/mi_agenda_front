import 'package:mi_agenda/data/contacts_api.dart';
import 'package:mi_agenda/models/contact.dart';

class FakeContactsApi extends ContactsApi {
  FakeContactsApi({
    List<Contact>? initialContacts,
    this.shouldFail = false,
  }) : contacts = List<Contact>.from(initialContacts ?? []);

  final List<Contact> contacts;
  bool shouldFail;

  @override
  Future<List<Contact>> getAll() async {
    _throwIfNeeded();
    return List<Contact>.from(contacts);
  }

  @override
  Future<void> create(Contact c) async {
    _throwIfNeeded();
    contacts.add(c);
  }

  @override
  Future<void> update(Contact c) async {
    _throwIfNeeded();
    final index = contacts.indexWhere((x) => x.id == c.id);
    if (index != -1) {
      contacts[index] = c;
    }
  }

  @override
  Future<void> delete(String id) async {
    _throwIfNeeded();
    contacts.removeWhere((c) => c.id == id);
  }

  void _throwIfNeeded() {
    if (shouldFail) {
      throw const ApiException('Error fake', 500);
    }
  }
}
