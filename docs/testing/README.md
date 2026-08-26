# Pruebas y verificación

## Validación base

Ejecuta desde la raíz:

```bash
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug --dart-define-from-file=lib/.env
```

En macOS también puedes validar el simulador iOS:

```bash
fvm flutter build ios --simulator --no-codesign \
  --dart-define-from-file=lib/.env
```

## Paquetes

```bash
cd packages/gymsas_auth
fvm flutter test

cd ../gymsas_firebase_auth
fvm flutter analyze

cd ../gymsas_payments
fvm flutter test
```

Agrega pruebas al módulo que posee la responsabilidad:

- dominio: reglas y value objects;
- aplicación: casos de uso con puertos falsos;
- infraestructura: mapeo, errores y contratos;
- presentación: estados, navegación y widgets;
- integración: GraphQL y platform channels críticos.

## Diagnóstico frecuente

- Android no alcanza el BFF: usa `10.0.2.2`, no `localhost`.
- Dispositivo físico no alcanza el BFF: usa la IP LAN y revisa el firewall.
- `firebase-ms` rechaza el token: app y backend deben usar `gymza-f1837`.
- Google Android devuelve error 10: revisa package name y SHA-1/SHA-256.
- Google iOS no vuelve a la app: revisa bundle ID y `REVERSED_CLIENT_ID`.
- Un build Gradle falla con un JDK muy nuevo: utiliza el JDK compatible que
  reporta `fvm flutter doctor -v`, preferentemente Java 21 para este proyecto.

No sustituyas tests con una compilación exitosa: el build valida ensamblado,
mientras que los tests validan comportamiento.

