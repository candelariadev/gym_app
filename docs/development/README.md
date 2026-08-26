# Desarrollo local

## Requisitos

- Git y [FVM](https://fvm.app/).
- Flutter `stable`; el proyecto requiere Dart `^3.10.4`.
- Android Studio y Android SDK para Android.
- Xcode 16 o posterior y Command Line Tools para iOS.
- Node.js y npm para las herramientas de Firebase.
- Docker Desktop para el backend local.

Comprueba el ambiente:

```bash
fvm --version
fvm flutter doctor -v
node --version
npm --version
java -version
```

## Instalar dependencias

Desde la raíz de `gym_app`:

```bash
fvm install stable
fvm use stable
fvm flutter clean
fvm flutter pub get
```

El `pubspec.yaml` raíz resuelve los paquetes de `packages/` mediante
dependencias `path`; no es necesario ejecutar `pub get` en cada paquete.

## Configuración local

Crea `lib/.env`. El archivo está ignorado por Git y se compila mediante
`--dart-define-from-file`:

```dotenv
# Android Emulator
BFF_GRAPHQL_URL=http://10.0.2.2:8090/graphql

# Sólo para el login tradicional multi-tenant
GYM_OWNER_ID=tenant_1

# Clave pública, nunca el Access Token
MERCADO_PAGO_PUBLIC_KEY=TEST-tu-public-key
```

Usa la URL correspondiente al destino:

| Destino | URL del BFF |
| --- | --- |
| Android Emulator | `http://10.0.2.2:8090/graphql` |
| iOS Simulator | `http://localhost:8090/graphql` |
| Dispositivo físico | `http://IP_LAN_DE_TU_EQUIPO:8090/graphql` |
| Ambiente remoto | URL pública HTTPS |

## Ejecutar

```bash
fvm flutter devices
fvm flutter run --dart-define-from-file=lib/.env
```

Después de modificar configuración nativa:

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter run --dart-define-from-file=lib/.env
```

Para levantar primero las APIs consulta la [guía del backend](../backend/README.md).

