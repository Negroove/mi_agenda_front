import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../data/contacts_api.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsApi _api;

  ContactsProvider({ContactsApi? api}) : _api = api ?? ContactsApi();

  bool _loaded = false;
  bool isLoading = false;
  String? error;

  final List<Contact> _contacts = [];

  List<Contact> get items => List.unmodifiable(_contacts);

  Future<void> load() async {
    if (_loaded) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final contactsFromApi = await _api.getAll();

      _contacts
        ..clear()
        ..addAll(contactsFromApi);

      _loaded = true;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Contact c) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _api.create(c);
      final contactsFromApi = await _api.getAll();

      _contacts
        ..clear()
        ..addAll(contactsFromApi);

      _loaded = true;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(Contact c) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _api.update(c);
      final contactsFromApi = await _api.getAll();

      _contacts
        ..clear()
        ..addAll(contactsFromApi);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _api.delete(id);
      final contactsFromApi = await _api.getAll();

      _contacts
        ..clear()
        ..addAll(contactsFromApi);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<Contact> searchBy(String query) {
    final q = normalize(query);

    return _contacts.where((c) {
      return normalize(c.nombre).contains(q) ||
          normalize(c.apellido).contains(q) ||
          normalize(c.telefono).contains(q) ||
          normalize(c.email).contains(q);
    }).toList();
  }
}
