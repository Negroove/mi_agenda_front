import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode == null ? message : '$message ($statusCode)';
}

class ContactsApi {
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.trim().isEmpty) {
      throw const ApiException('No hay token de autenticacion guardado');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> create(Contact c) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/contacto/add');

    final res = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'nombre': c.nombre,
        'apellido': c.apellido,
        'telefono': c.telefono,
        'email': c.email,
      }),
    );

    debugPrint('ContactsApi.create url: $url');
    debugPrint('ContactsApi.create statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.create response body: ${res.body}');

    if (res.statusCode != 201) {
      throw ApiException(
        'Error al crear contacto: ${res.body}',
        res.statusCode,
      );
    }
  }

  Future<List<Contact>> getAll() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/contacto');

    try {
      final res = await http.get(
        url,
        headers: await _authHeaders(),
      );

      debugPrint('ContactsApi.getAll url: $url');
      debugPrint('ContactsApi.getAll statusCode: ${res.statusCode}');
      debugPrint('ContactsApi.getAll response body: ${res.body}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(
          'Error al obtener contactos: ${res.body}',
          res.statusCode,
        );
      }

      final decoded = jsonDecode(res.body);
      final data = _extractContactsList(decoded);

      return data.map(_contactFromJson).toList();
    } catch (e) {
      debugPrint('ContactsApi.getAll error: $e');
      rethrow;
    }
  }

  Future<void> update(Contact c) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/contacto/update/${c.id}');

    final res = await http.put(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'id': c.id,
        'nombre': c.nombre,
        'apellido': c.apellido,
        'telefono': c.telefono,
        'email': c.email,
      }),
    );

    debugPrint('ContactsApi.update url: $url');
    debugPrint('ContactsApi.update statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.update response body: ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'Error al actualizar contacto: ${res.body}',
        res.statusCode,
      );
    }
  }

  Future<void> delete(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/contacto/delete/$id');

    final res = await http.delete(
      url,
      headers: await _authHeaders(),
    );

    debugPrint('ContactsApi.delete url: $url');
    debugPrint('ContactsApi.delete statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.delete response body: ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'Error al eliminar contacto: ${res.body}',
        res.statusCode,
      );
    }
  }

  List<dynamic> _extractContactsList(dynamic decoded) {
    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      final wrappedList =
          decoded['data'] ?? decoded['contactos'] ?? decoded['contacts'];
      if (wrappedList is List) return wrappedList;
    }

    throw const ApiException('Respuesta inesperada al obtener contactos');
  }

  Contact _contactFromJson(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const ApiException('Contacto con formato inesperado');
    }

    return Contact(
      id: (value['id'] ?? value['contactoId'] ?? '').toString(),
      nombre: (value['nombre'] ?? '').toString(),
      apellido: (value['apellido'] ?? '').toString(),
      telefono: (value['telefono'] ?? '').toString(),
      email: (value['email'] ?? '').toString(),
      direccion: (value['direccion'] ?? '').toString(),
      fechaNacimiento: _parseDate(value['fechaNacimiento']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
