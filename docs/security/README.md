# Seguridad y configuración

## Clasificación de configuración

| Elemento | Ubicación | ¿Se versiona? |
| --- | --- | --- |
| `firebase_options.dart` | Flutter | No; se mantiene local por política del proyecto |
| `google-services.json` | Android | No; se mantiene local por política del proyecto |
| `GoogleService-Info.plist` | iOS | No; se mantiene local por política del proyecto |
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

El repositorio incluye controles locales en `.githooks/`. En cada clon, instala
Gitleaks y activa los controles:

```bash
brew install gitleaks
git config --local core.hooksPath .githooks
chmod +x .githooks/pre-commit .githooks/pre-push
python3 scripts/check_secrets.py --working-tree
python3 scripts/check_secrets.py --staged
python3 scripts/check_secrets.py --history
```

El commit revisa el índice completo, incluyendo archivos parcialmente preparados.
El push revisa el historial de las referencias que se enviarán. Los controles
bloquean la operación si falta el escáner o falla la revisión. Sólo muestran rutas
y tipos de hallazgo. No uses `--no-verify` para publicar.

La revisión cubre los candidatos de este repositorio; los archivos locales
ignorados no se publican y no se copian al escaneo. Las plantillas `.env.example`
se revisan también y deben dejar vacíos los valores secretos.

```bash
git status --short
git ls-files | rg '(^|/)(\.env|.*service-account.*\.json|.*\.jks|.*\.keystore|.*\.p8)$'
```

El segundo comando no debe listar credenciales. Si un secreto alguna vez llegó
al historial, ignorarlo después no lo elimina: revócalo, rótalo y limpia el
historial mediante un procedimiento controlado.

