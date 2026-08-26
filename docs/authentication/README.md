# Autenticación y onboarding

GymSAS admite dos entradas: login tradicional para cuentas multi-tenant y
Google Sign-In para cuentas individuales. Firebase demuestra la identidad; el
BFF y los servicios internos resuelven autorización y sesión.

## Flujo con Google

```text
Flutter
  -> Firebase Google Sign-In
  -> Firebase ID token
  -> gymsas-bff (GraphQL)
  -> firebase-ms valida token y vincula identidad
  -> sesión existente o ONBOARDING_REQUIRED
```

La app depende del puerto `ExternalIdentityProvider`. La implementación actual
vive en `gymsas_firebase_auth`, de modo que Firebase no invade presentación ni
casos de uso.

## Onboarding individual

Una identidad nueva completa:

- rol `TRAINER` o `ADVISED`;
- nickname visible;
- contraseña requerida;
- datos de perfil específicos del rol.

El alta crea un usuario con plan `INDIVIDUAL`. Es una cuenta individual: utiliza
un `accountId` estable para suscripción y límites, pero no se asocia a un tenant
cliente. El nickname se muestra en la UI; `user` permanece como identificador
técnico.

Responsabilidades de almacenamiento:

| Datos | Servicio/colección |
| --- | --- |
| Proveedores, UID, autorización y actividad | `firebase-ms` / `firebase_identities` |
| Perfil, nickname y hash bcrypt | `gymsas-user` / `users` |
| Plan individual, suscripción y límites | `tenant-ms` / `subscriptions` |

La contraseña nunca se almacena en `firebase_identities` y nunca se conserva
en texto plano.

## Validación manual

1. Pulsa **Continuar con Google** y selecciona un correo verificado.
2. Para una identidad nueva, confirma que aparece el onboarding.
3. Selecciona `TRAINER` o `ADVISED` y completa el perfil.
4. Confirma la entrada al dashboard correspondiente y el nickname mostrado.
5. Cierra sesión y comprueba que se cierran la sesión GymSAS y Firebase.
6. Vuelve a iniciar sesión y verifica que ya no se solicita onboarding.

El login tradicional conserva `GYM_OWNER_ID` sólo para su flujo multi-tenant.

