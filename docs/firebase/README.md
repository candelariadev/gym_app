# Firebase: incorporación y ejecución local

Esta guía permite que un desarrollador nuevo clone GymSAS, obtenga los accesos
correctos y valide Google Sign-In sin depender de conocimiento verbal del
equipo.

Firebase sólo autentica la identidad externa. La autorización, el perfil, el
onboarding y la sesión de GymSAS pertenecen al BFF y a los microservicios.

## Datos del proyecto

```text
Firebase project ID:    gymza-f1837
Android applicationId: com.gymsas.app
iOS bundle ID:         com.gymsas.app
Proveedor:              Google
```

Los identificadores nativos deben coincidir exactamente con los registros de
Firebase.

## Qué acceso necesita el desarrollador

No todos los desarrolladores necesitan las mismas credenciales.

| Necesidad | Acceso requerido |
| --- | --- |
| Clonar y ejecutar Flutter con los archivos versionados | No requiere acceso IAM a Firebase |
| Consultar configuración y diagnosticar desde Firebase Console/CLI | `Firebase Develop Viewer` (`roles/firebase.developViewer`) |
| Consultar usuarios de Authentication | `Firebase Authentication Viewer` (`roles/firebaseauth.viewer`) si el rol anterior no cubre la necesidad |
| Administrar proveedor Google o usuarios | `Firebase Authentication Admin` (`roles/firebaseauth.admin`), sólo cuando sea parte de su función |
| Crear/eliminar apps o modificar su registro | Lo realiza el administrador del proyecto; no se entrega `Owner` para desarrollo cotidiano |
| Ejecutar `firebase-ms` localmente | Credenciales backend entregadas por un canal seguro; nunca las credenciales cliente de Flutter |

Para un desarrollador móvil habitual se recomienda acceso de sólo lectura
`Firebase Develop Viewer`. Si únicamente ejecutará la app y reportará errores,
puede trabajar sin ser miembro del proyecto.

### Tres accesos que no deben confundirse

1. **Miembro IAM del proyecto:** permite entrar a Firebase Console y usar el CLI
   según sus roles.
2. **Usuario de prueba OAuth:** permite autorizar Google Sign-In cuando la
   pantalla de consentimiento está en modo `Testing`. No concede acceso a la
   consola.
3. **Usuario de GymSAS:** se crea mediante el login/onboarding. No hace al correo
   miembro del proyecto Firebase.

En un OAuth publicado para audiencia externa no suele ser necesario registrar
cada correo como usuario de prueba. Si Google Auth Platform está en `Testing`,
el administrador sí debe agregar el correo en **Google Cloud Console -> Google
Auth Platform -> Audience -> Test users**.

## Checklist del administrador

Realiza esto antes o durante el primer día del desarrollador.

### 1. Recibir su cuenta

Solicita el correo de Google corporativo que utilizará para Firebase Console y
para probar Google Sign-In. No uses cuentas compartidas.

### 2. Dar acceso de sólo lectura

En [Firebase Console](https://console.firebase.google.com/):

1. Abre `gymza-f1837`.
2. Ve a **Configuración del proyecto -> Usuarios y permisos**.
3. Selecciona **Agregar miembro**.
4. Ingresa el correo del desarrollador.
5. Asigna `Firebase Develop Viewer`.
6. Guarda y espera unos minutos a que IAM propague el cambio.

Sólo un `Owner` o una identidad con permiso para modificar IAM puede asignar
roles. No asignes `Owner`, `Editor` o `Firebase Admin` sólo para que la persona
pueda ejecutar la app.

### 3. Confirmar Google Sign-In

En **Authentication -> Sign-in method** comprueba:

- proveedor Google habilitado;
- correo de soporte configurado;
- estado correcto de la pantalla de consentimiento OAuth;
- correo del desarrollador en `Test users` si OAuth continúa en `Testing`.

### 4. Registrar la huella Android del desarrollador

Cada equipo puede generar un certificado `debug` diferente. Pide al
desarrollador las líneas SHA-1 y SHA-256 obtenidas con `signingReport`.

En Firebase Console:

1. Ve a **Configuración del proyecto -> General -> Tus apps**.
2. Abre la aplicación Android `com.gymsas.app`.
3. Selecciona **Agregar huella digital**.
4. Registra SHA-1 y SHA-256.

El desarrollador no necesita recibir permisos de escritura sólo para esto; el
administrador puede registrar las huellas que le envíe. Cada keystore de release
también requiere sus propias huellas antes de distribuir una versión.

### 5. Entregar acceso backend sólo si corresponde

Si trabajará contra un BFF compartido, no necesita una cuenta de servicio.

Si levantará `firebase-ms` localmente, entrega las credenciales mediante el
secret manager del equipo o un canal cifrado y controlado. No envíes JSON de
service account por chat, correo ni commits. Consulta la sección
[Firebase Admin](#firebase-admin-para-backend-local).

## Checklist del desarrollador

### 1. Preparar Flutter

Desde la raíz de `gym_app`:

```bash
fvm install stable
fvm use stable
fvm flutter pub get
fvm flutter doctor -v
```

### 2. Comprobar la configuración recibida por Git

Estos archivos deben existir después de clonar:

```text
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
firebase.json
```

Son configuración cliente pública y se versionan. No contienen una cuenta de
servicio ni conceden acceso administrativo.

No ejecutes `flutterfire configure` durante la instalación normal: el proyecto
ya está configurado. Ese comando puede modificar archivos o registrar apps y se
reserva para cambios deliberados de plataforma o identificadores.

### 3. Verificar acceso a Firebase, si te lo asignaron

Firebase CLI requiere Node.js 18 o posterior.

```bash
node --version
npm install --global firebase-tools
firebase login
firebase login:list
firebase projects:list
firebase apps:list --project gymza-f1837
```

El proyecto `gymza-f1837` debe aparecer en los dos últimos comandos. Si no
aparece:

- confirma que iniciaste sesión con el correo agregado por el administrador;
- usa `firebase login:add` o `firebase login:use` si hay varias cuentas;
- espera unos minutos por la propagación de IAM;
- solicita que revisen tu membresía y rol.

No poder listar el proyecto no impide ejecutar Flutter con los archivos ya
versionados, pero sí impide diagnosticarlo desde Console/CLI.

### 4. Instalar FlutterFire CLI

Sólo es necesario para tareas que regeneran la integración:

```bash
dart pub global activate flutterfire_cli
flutterfire --version
```

Si el comando no está en el `PATH`:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### 5. Obtener las huellas Android

```bash
cd android
./gradlew signingReport
cd ..
```

Busca la variante `debug`, copia SHA-1 y SHA-256 y envíalas al administrador.
Después de que las registre, vuelve a ejecutar la app. Si el equipo descarga un
`google-services.json` actualizado, debe revisarse y compartirse mediante un PR,
no por mensajería privada.

En iOS no existe una huella equivalente por desarrollador. Para un iPhone
físico sí puede ser necesario acceso al equipo de Apple y a su firma, lo cual es
independiente de Firebase.

### 6. Crear configuración local de Flutter

Crea `lib/.env`:

```dotenv
# Android Emulator
BFF_GRAPHQL_URL=http://10.0.2.2:8090/graphql

# Sólo para login tradicional multi-tenant
GYM_OWNER_ID=tenant_1

# Sólo si validarás checkout
MERCADO_PAGO_PUBLIC_KEY=TEST-tu-public-key
```

Para iOS Simulator cambia el BFF a `http://localhost:8090/graphql`. Para un
dispositivo físico usa la IP LAN del equipo. `lib/.env` no se versiona.

### 7. Levantar dependencias

Puedes usar una de estas modalidades:

- **Backend compartido:** configura `BFF_GRAPHQL_URL` con su URL HTTPS; no
  necesitas secretos Firebase Admin.
- **Backend local:** configura las credenciales de `firebase-ms` como se indica
  más adelante y levanta el BFF y sus dependencias con Docker Compose.

Flutter nunca llama directamente a `firebase-ms`.

Para el backend local:

```bash
cd ../microservicios
docker compose up -d --build
docker compose ps
docker compose logs -f firebase-ms gymsas-bff
```

Espera a que `firebase-ms` y `gymsas-bff` aparezcan saludables. Comprueba:

```bash
curl --fail http://localhost:8091/health/ready
curl --fail http://localhost:8090/actuator/health
```

El Compose levanta también MongoDB, Redis y los servicios requeridos por el BFF.
Si una imagen no compila, corrige primero ese servicio; Flutter no puede validar
el flujo completo mientras el BFF no esté saludable.

### 8. Ejecutar

```bash
fvm flutter run --dart-define-from-file=lib/.env
```

La inicialización usa `DefaultFirebaseOptions.currentPlatform` desde
`lib/app/app_dependencies.dart`.

### 9. Prueba de aceptación

1. Abre el login y pulsa **Continuar con Google**.
2. Selecciona el correo autorizado para la prueba.
3. Para una identidad nueva, confirma que aparece el onboarding.
4. Completa rol, nickname, contraseña y perfil.
5. Confirma que abre el dashboard y muestra el nickname.
6. Cierra sesión y verifica que también se cierre la sesión Google/Firebase.
7. Inicia nuevamente y confirma que no se repita el onboarding.

## Regenerar la integración Firebase

Sólo hazlo al agregar una plataforma/producto, cambiar bundle ID/package name o
por una modificación aprobada de Firebase. Requiere permisos suficientes para
consultar o modificar las apps registradas.

```bash
flutterfire configure \
  --project=gymza-f1837 \
  --platforms=android,ios
```

Después:

```bash
git diff -- \
  firebase.json \
  lib/firebase_options.dart \
  android/app/google-services.json \
  ios/Runner/GoogleService-Info.plist
```

Revisa el diff antes de confirmar cambios. No aceptes la creación accidental de
otra app Firebase con identificadores distintos.

## Firebase Admin para backend local

Flutter entrega un Firebase ID token al BFF. `firebase-ms` valida firma, issuer,
audience y expiración con Firebase Admin antes de crear una sesión GymSAS.

Las variables pertenecen a `microservicios/.env`, no a `gym_app/lib/.env`:

```dotenv
FIREBASE_PROJECT_ID=gymza-f1837
FIREBASE_CREDENTIALS_BASE64=service-account-json-codificado-en-base64
FIREBASE_INTERNAL_API_KEY=secreto-interno-fuerte
```

En macOS, si el equipo utiliza el formato Base64:

```bash
base64 -i /ruta/segura/firebase-service-account.json | tr -d '\n'
```

Reglas obligatorias:

- no copies el JSON dentro de Flutter;
- no confirmes el JSON ni el Base64 en Git;
- no reutilices credenciales de producción para desarrollo;
- usa un secret manager o Application Default Credentials cuando el ambiente
  lo permita;
- revoca inmediatamente una credencial expuesta.

Con las variables cargadas, inicia los servicios con los comandos de
[Levantar dependencias](#7-levantar-dependencias). Si `firebase-ms` no alcanza
el estado saludable, revisa primero:

```bash
cd ../microservicios
docker compose logs firebase-ms
```

## Diagnóstico

### `Default FirebaseApp is not initialized`

Comprueba que existan los archivos cliente, que
`DefaultFirebaseOptions.currentPlatform` llegue al adaptador y después ejecuta:

```bash
fvm flutter clean
fvm flutter pub get
```

### Android: `ApiException: 10` o `DEVELOPER_ERROR`

El package name, cliente OAuth o SHA-1/SHA-256 no coincide. Confirma que el
administrador registró las huellas de tu equipo en `com.gymsas.app`.

### `Access blocked` o el correo no puede autorizar Google

Si OAuth está en `Testing`, solicita que agreguen ese correo en **Google Auth
Platform -> Audience -> Test users**. Esto es independiente del rol IAM.

### iOS no vuelve a la app

Comprueba que `GoogleService-Info.plist` pertenezca a `Runner`, que el bundle ID
sea `com.gymsas.app`, que `Info.plist` tenga `GIDClientID` y que URL Types incluya
el `REVERSED_CLIENT_ID`. El deployment target mínimo es iOS 15.

### `firebase-ms` rechaza el ID token

App y backend deben usar `gymza-f1837`. Revisa además reloj del sistema,
audience, issuer, expiración, proveedor `google.com` y correo verificado.

## Checklist final de incorporación

- [ ] El desarrollador clonó el repositorio y resolvió dependencias.
- [ ] Los cuatro archivos Firebase cliente existen.
- [ ] Su cuenta puede ver `gymza-f1837` si necesita Console/CLI.
- [ ] Su correo está en OAuth Test users cuando el proyecto está en `Testing`.
- [ ] SHA-1 y SHA-256 de su Android debug están registradas.
- [ ] `lib/.env` apunta al BFF correcto.
- [ ] Recibió secretos backend sólo si levantará `firebase-ms` localmente.
- [ ] Google Sign-In, onboarding, reingreso y logout funcionan.
- [ ] Ninguna credencial privada fue agregada al repositorio.

## Referencias oficiales

- [Administrar miembros del proyecto](https://support.google.com/firebase/answer/7000272?hl=es-419)
- [Roles IAM predefinidos de Firebase](https://firebase.google.com/docs/projects/iam/roles-predefined)
- [Roles por categoría, incluido Firebase Develop Viewer](https://firebase.google.com/docs/projects/iam/roles-predefined-category)
- [Roles de Firebase Authentication](https://firebase.google.com/docs/projects/iam/roles-predefined-product)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Configurar Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [Autenticación federada en Flutter](https://firebase.google.com/docs/auth/flutter/federated-auth)
- [Google Sign-In para iOS](https://developers.google.com/identity/sign-in/ios/start-integrating)
