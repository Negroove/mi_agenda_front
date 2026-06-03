# Mi Agenda Front

Aplicacion Flutter para gestionar contactos consumiendo una Web API .NET 8 llamada `ContactosApi`.

La app usa `Dio` para comunicarse con el backend, con un cliente centralizado en `lib/data/api_client.dart` y autenticacion JWT mediante interceptor.

## Requisitos previos

- Flutter instalado.
- Emulador Android o dispositivo fisico.
- Backend .NET 8 levantado en la maquina local:

```text
http://localhost:5234
```

## URL de la API

Para Android Emulator, la app usa:

```text
http://10.0.2.2:5234
```

Esta URL apunta desde el emulador al `localhost` de la maquina donde corre el backend.

La configuracion se encuentra en:

```text
lib/data/api_config.dart
```

## Ejecucion

Instalar dependencias:

```bash
flutter pub get
```

Analizar el proyecto:

```bash
flutter analyze
```

Ejecutar la app:

```bash
flutter run
```

## Usuario de prueba

```text
Usuario: admin123
Password: 1234
```

## Funcionalidades

- Login.
- Registro.
- Listado de contactos.
- Detalle de contacto.
- Alta de contacto.
- Edicion de contacto.
- Eliminacion de contacto.

## API consumida

Autenticacion:

```text
POST /api/auth/login
POST /api/auth/register
```

Contactos:

```text
GET    /minimal/contactos
GET    /api/contacto/{id}
POST   /api/contacto/add
PUT    /api/contacto/edit/{id}
DELETE /api/contacto/delete/{id}
```

El listado usa `GET /minimal/contactos` porque la consigna del trabajo practico lo pide explicitamente. El resto del CRUD usa endpoints bajo `/api/contacto`.

## Autenticacion JWT

El token JWT se guarda en `SharedPreferences` con la clave:

```text
token
```

El interceptor de Dio agrega automaticamente en las requests protegidas:

```text
Authorization: Bearer <token>
Content-Type: application/json
```

## Modelo Contact

El modelo de contacto usado por Flutter contiene:

```text
id
nombre
apellido
email
telefono
avatarUrl
```

No se usa `direccion`.

No se usa `fechaNacimiento`.

La base de datos del backend tiene `fechaCreacion`, pero por ahora Flutter no la muestra, no la carga y no la edita.

## Notas importantes

- El backend debe estar corriendo antes de iniciar la app.
- `/minimal/contactos` esta protegido con JWT y rol Admin.
- Para probar en un dispositivo fisico, cambiar la URL base por la IP de la maquina donde corre la API.
