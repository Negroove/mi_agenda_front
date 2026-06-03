import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/contact.dart';
import 'api_client.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode == null ? message : '$message ($statusCode)';
}

class ContactsApi {
  ContactsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<void> create(Contact c) async {
    final res = await _client.dio.post(
      '/api/contacto/add',
      data: {
        'nombre': c.nombre,
        'apellido': c.apellido,
        'telefono': c.telefono,
        'email': c.email,
      },
    );

    debugPrint('ContactsApi.create statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.create response body: ${res.data}');

    if (res.statusCode != 201) {
      throw ApiException(
        'Error al crear contacto: ${res.data}',
        res.statusCode,
      );
    }
  }

  Future<List<Contact>> getAll() async {
    try {
      final res = await _client.dio.get('/minimal/contactos');

      debugPrint('ContactsApi.getAll statusCode: ${res.statusCode}');
      debugPrint('ContactsApi.getAll response body: ${res.data}');

      if (!_isSuccess(res.statusCode)) {
        throw ApiException(
          'Error al obtener contactos: ${res.data}',
          res.statusCode,
        );
      }

      final decoded = _decodeResponse(res.data);
      final data = _extractContactsList(decoded);

      return data.map(_contactFromJson).toList();
    } on DioException catch (e) {
      debugPrint('ContactsApi.getAll error: ${e.message}');
      throw ApiException('Error al obtener contactos: ${e.message}');
    } catch (e) {
      debugPrint('ContactsApi.getAll error: $e');
      rethrow;
    }
  }

  Future<Contact> getById(String id) async {
    final res = await _client.dio.get('/api/contacto/$id');

    debugPrint('ContactsApi.getById statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.getById response body: ${res.data}');

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(
        'Error al obtener contacto: ${res.data}',
        res.statusCode,
      );
    }

    final decoded = _decodeResponse(res.data);
    return _contactFromJson(decoded);
  }

  Future<void> update(Contact c) async {
    final res = await _client.dio.put(
      '/api/contacto/edit/${c.id}',
      data: {
        'nombre': c.nombre,
        'apellido': c.apellido,
        'telefono': c.telefono,
        'email': c.email,
      },
    );

    debugPrint('ContactsApi.update statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.update response body: ${res.data}');

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(
        'Error al actualizar contacto: ${res.data}',
        res.statusCode,
      );
    }
  }

  Future<void> delete(String id) async {
    final res = await _client.dio.delete('/api/contacto/delete/$id');

    debugPrint('ContactsApi.delete statusCode: ${res.statusCode}');
    debugPrint('ContactsApi.delete response body: ${res.data}');

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(
        'Error al eliminar contacto: ${res.data}',
        res.statusCode,
      );
    }
  }

  bool _isSuccess(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  dynamic _decodeResponse(dynamic data) {
    if (data is String) return jsonDecode(data);
    return data;
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
    );
  }
}
