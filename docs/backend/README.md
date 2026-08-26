# Integración con el backend

El único endpoint de negocio configurable en Flutter es el GraphQL del BFF.
Las llamadas internas utilizan adaptadores y credenciales service-to-service.

```text
gym_app -> gymsas-bff:8090/graphql
               -> firebase-ms:8091
               -> gymsas-user
               -> tenant-ms
               -> plans-ms
               -> payment-ms
```

## Variables locales del backend

En `microservicios/.env`, usa valores propios:

```dotenv
FIREBASE_PROJECT_ID=gymza-f1837
FIREBASE_CREDENTIALS_BASE64=service-account-json-codificado-en-base64
FIREBASE_INTERNAL_API_KEY=secreto-interno-fuerte
USER_INTERNAL_API_KEY=otro-secreto-interno-fuerte
TENANT_INTERNAL_API_KEY=otro-secreto-interno-fuerte

MERCADO_PAGO_ACCESS_TOKEN=TEST-tu-access-token
MERCADO_PAGO_WEBHOOK_SECRET=tu-secreto-de-webhook
```

No copies estos valores a `lib/.env`.

## Levantar servicios

```bash
cd ../microservicios
docker compose up -d --build
docker compose ps
docker compose logs -f firebase-ms gymsas-bff gymsas-user tenant-ms
```

Servicios requeridos para autenticación individual:

- `gymsas-bff`: entrada GraphQL y adaptación de contratos.
- `firebase-ms`: validación y vínculo de identidad.
- `gymsas-user`: perfil, nickname y hash de contraseña.
- `tenant-ms`: cuenta individual, suscripción y límites.
- `plans-ms`: catálogo y definición del plan `individual`.
- MongoDB local en el host y Redis administrado por Compose.

Para checkout se suma `payment-ms`, que encapsula la API privada del proveedor
y procesa webhooks idempotentes.

## Regla del BFF

No agregues clientes de `firebase-ms`, `payment-ms`, `plans-ms` ni otros
microservicios dentro de Flutter. Una capacidad nueva debe exponerse primero en
el esquema GraphQL y en un adaptador existente del BFF; después se consume desde
`gymsas_api_client` o el módulo correspondiente.
