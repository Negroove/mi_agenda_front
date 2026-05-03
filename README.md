# mi_agenda

Aplicacion Flutter para gestionar contactos usando Provider, autenticacion JWT y una API REST en .NET.

## Descripcion

**mi_agenda** permite iniciar sesion, listar, buscar, crear, editar y eliminar contactos contra un backend real. La app usa `Provider` para manejar estado, `http` para consumir la API, `shared_preferences` para guardar el JWT y pantallas Flutter simples para el flujo de contactos.

## Funcionalidades

### Autenticacion

- Login contra `POST /api/auth/login`.
- Persistencia del JWT con `SharedPreferences`.
- Envio automatico del token en requests protegidos.
- Validacion basica de JWT guardado.
- Logout desde la pantalla de contactos.

### Contactos

- Listado desde `GET /api/contacto`.
- Creacion con `POST /api/contacto/add`.
- Edicion con `PUT /api/contacto/update/{id}`.
- Eliminacion con `DELETE /api/contacto/delete/{id}`.
- Recarga de lista desde backend despues de crear, editar o eliminar.
- Busqueda local en tiempo real por nombre, apellido, telefono o email.
- Vista de detalle por `contactId`.
- Avatar generado con iniciales.

### Estado y errores

`ContactsProvider` maneja:

- `items`: lista actual de contactos.
- `isLoading`: estado de carga para operaciones async.
- `error`: mensaje de error cuando falla la API.

Las llamadas a la API usan `ApiException` para incluir mensaje y `statusCode`.

### Tests

La app incluye tests automaticos sin Mockito ni librerias externas:

- Tests unitarios de `ContactsProvider`.
- `FakeContactsApi` para simular GET, POST, PUT, DELETE y errores.
- Widget tests basicos para `LoginForm`.

## API

La URL base se configura en:

```dart
lib/data/api_config.dart
```

Para emulador Android se usa:

```dart
static const String baseUrl = 'http://10.0.2.2:5234';
```

Endpoints usados:

```text
POST   /api/auth/login
GET    /api/contacto
POST   /api/contacto/add
PUT    /api/contacto/update/{id}
DELETE /api/contacto/delete/{id}
```

Los endpoints de contactos envian:

```text
Authorization: Bearer <token>
Content-Type: application/json
```

## Estructura del proyecto

```text
lib/
|-- app_theme.dart
|-- main.dart
|-- models/
|   `-- contact.dart
|-- data/
|   |-- api_config.dart
|   |-- auth_api.dart
|   |-- contacts_api.dart
|   `-- contacts_db.dart
|-- providers/
|   |-- auth_provider.dart
|   `-- contacts_provider.dart
`-- screens/
    |-- login_screen.dart
    |-- contacts_screen.dart
    |-- contact_detail_screen.dart
    `-- widgets/
        |-- contact_form_screen.dart
        `-- login_form.dart

test/
|-- contacts_provider_test.dart
|-- login_form_test.dart
`-- fakes/
    `-- fake_contacts_api.dart
```

## Dependencias principales

- `provider`
- `http`
- `shared_preferences`
- `intl`
- `flutter_test`

`sqflite` y `path` siguen instalados por compatibilidad con codigo local previo, aunque el flujo principal actual usa la API REST.

## Primeros pasos

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar la app:

```bash
flutter run
```

Ejecutar tests:

```bash
flutter test
```

## Notas de desarrollo

- Si se corre en emulador Android, `10.0.2.2` apunta al localhost de la maquina host.
- Android tiene habilitado `INTERNET` y trafico HTTP cleartext para desarrollo local.
- Para probar contra un dispositivo fisico, cambiar `baseUrl` por la IP de la maquina donde corre la API.
