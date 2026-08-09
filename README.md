# Gym App

Aplicación Flutter multi-tenant conectada al BFF GraphQL de GymSAS. El contrato
de integración está alineado con la colección `Gymsas BFF` de Insomnia:

- endpoint: `POST /graphql`;
- login: `ownerId`, `user`, `password`;
- sesión: access token y refresh token;
- roles admitidos por la app: `TRAINER` y `ADVISED`;
- clientes, ejercicios y rutinas usan el access token como bearer token.

## Ejecutar contra el backend local

Android Emulator:

```bash
fvm flutter run \
  --dart-define=BFF_GRAPHQL_URL=http://10.0.2.2:8090/graphql \
  --dart-define=GYM_OWNER_ID=tenant_1
```

Para iOS Simulator usa `http://localhost:8090/graphql`. En ambientes reales la
URL debe ser HTTPS y ambos valores deben inyectarse desde la configuración del
entorno.

## Estructura

```text
lib/
├── app/                  # Composition root y navegación por sesión
├── core/                 # Configuración transversal propia de esta app
├── features/             # Presentación y adaptación visual de cada feature
└── l10n/                 # ARB y AppLocalizations generado

packages/
├── gymsas_api_client/    # Transporte GraphQL y excepciones técnicas
├── gymsas_auth/          # Módulo auth: domain/application/infrastructure
└── gymsas_design_system/ # Tema y componentes Atomic Design reutilizables
```

`gymsas_design_system` es un paquete Flutter independiente. No contiene textos
de negocio ni depende de las localizaciones de esta app; cada consumidor le
proporciona sus etiquetas traducidas.

`gymsas_api_client` concentra la ejecución HTTP/GraphQL, bearer tokens,
timeouts y errores técnicos. La app convierte esos errores a códigos de negocio
en su adaptador de autenticación; esto evita acoplar el cliente compartido a una
feature o a un idioma.

`gymsas_auth` es un paquete por bounded context. Internamente conserva
`domain`, `application` e `infrastructure`, pero expone una sola API pública y
un composition entry point (`AuthModule`). La app mantiene controladores,
páginas y localización en `features/auth/presentation`.

La aplicación usa navegación declarativa con rutas protegidas por el estado de
sesión. `GymApp` es propietario de `AppDependencies`; al desmontarse libera los
controllers, `AuthModule` y el cliente HTTP. Los errores GraphQL se clasifican
por `extensions.httpStatus`, no por el texto de `message`.

## Localización

Los textos visibles se mantienen en:

- `lib/l10n/app_es.arb`
- `lib/l10n/app_en.arb`

Después de modificar un ARB ejecuta:

```bash
fvm flutter gen-l10n
```

## Verificación

```bash
fvm flutter analyze
fvm flutter test

cd packages/gymsas_design_system
fvm flutter analyze
fvm flutter test

cd ../gymsas_api_client
dart analyze
dart test

cd ../gymsas_auth
fvm flutter analyze
fvm flutter test
```
