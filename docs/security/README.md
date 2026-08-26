# Seguridad y configuración

## Clasificación de configuración

| Elemento | Ubicación | ¿Se versiona? |
| --- | --- | --- |
| `firebase_options.dart` | Flutter | Sí; configuración cliente pública |
| `google-services.json` | Android | Sí; configuración cliente pública |
| `GoogleService-Info.plist` | iOS | Sí; configuración cliente pública |
| Clave pública Mercado Pago | Flutter/env de CI | No es secreta, pero se inyecta por ambiente |
| Firebase service account | Backend/secret manager | No |
| Access Token Mercado Pago | Backend/secret manager | No |
| Secreto de webhook | Backend/secret manager | No |
| Claves internas entre servicios | Backend/secret manager | No |
| Keystore, `.p8`, `.p12`, `.pem`, `.key` | Almacén seguro/CI | No |

Las API keys de Firebase cliente identifican la aplicación; las reglas y la
validación del ID token protegen los recursos. Nunca deben confundirse con una
cuenta de servicio Firebase Admin.

## Reglas

- `lib/.env` es local y está ignorado por Git.
- No uses `--dart-define` para secretos: los valores compilados pueden extraerse
  del binario móvil.
- No imprimas tokens, contraseñas, datos de tarjeta ni payloads completos en logs.
- El backend valida issuer, audience, expiración y correo verificado del ID token.
- Los webhooks validan firma, toleran reintentos y usan idempotencia.
- Usa HTTPS fuera del desarrollo local.
- Producción debe obtener secretos desde CI o un secret manager.

## Antes de publicar

```bash
git status --short
git ls-files | rg '(^|/)(\.env|.*service-account.*\.json|.*\.jks|.*\.keystore|.*\.p8)$'
```

El segundo comando no debe listar credenciales. Si un secreto alguna vez llegó
al historial, ignorarlo después no lo elimina: revócalo, rótalo y limpia el
historial mediante un procedimiento controlado.

