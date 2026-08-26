# GymSAS Flutter App

Aplicación móvil de GymSAS. Todo acceso al backend pasa por `gymsas-bff`
mediante GraphQL; la app no consume directamente los microservicios internos.

```text
Flutter -> gymsas-bff -> firebase-ms -> gymsas-user / tenant-ms
                      -> plans-ms / payment-ms
```

## Inicio rápido

```bash
fvm install stable
fvm use stable
fvm flutter pub get
fvm flutter run --dart-define-from-file=lib/.env
```

Antes de ejecutar la app, crea `lib/.env` siguiendo la guía de desarrollo y
configura Firebase si utilizarás el inicio de sesión con Google.

## Documentación por función

| Función | Documento | Contenido |
| --- | --- | --- |
| Desarrollo local | [docs/development/README.md](docs/development/README.md) | Requisitos, variables, instalación y ejecución |
| Firebase | [docs/firebase/README.md](docs/firebase/README.md) | Proyecto, FlutterFire, Android, iOS y Firebase Admin |
| Autenticación y onboarding | [docs/authentication/README.md](docs/authentication/README.md) | Google Sign-In, roles, sesión y alta individual |
| Checkout | [docs/checkout/README.md](docs/checkout/README.md) | Mercado Pago, responsabilidades y cambio de proveedor |
| Arquitectura | [docs/architecture/README.md](docs/architecture/README.md) | Capas, módulos, puertos y reglas de dependencia |
| Integración backend | [docs/backend/README.md](docs/backend/README.md) | BFF, microservicios, Docker y contratos internos |
| Seguridad y configuración | [docs/security/README.md](docs/security/README.md) | Secretos, archivos públicos, `.gitignore` y producción |
| Pruebas | [docs/testing/README.md](docs/testing/README.md) | Análisis, tests, builds y diagnóstico |
| Localización | [docs/localization/README.md](docs/localization/README.md) | ARB, generación y reglas de traducción |

## Identificadores de la aplicación

```text
Firebase project:       gymza-f1837
Android applicationId:  com.gymsas.app
iOS bundle ID:          com.gymsas.app
```

Estos valores deben coincidir con los registros Android e iOS de Firebase.
