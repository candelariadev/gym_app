# Notificaciones de rutinas — Flutter

## Flujo visible

1. El entrenador publica la rutina. La asignación continúa siendo online y sujeta
   a permisos/cuotas del servidor. Sólo una respuesta válida de asignación para
   ese cliente habilita la opción **Notificar al cliente**; un ID local no basta.
2. Cada cliente confirmado muestra su tarjeta, incluso si otro cliente del lote
   falla. Reintentar el lote omite las asignaciones ya confirmadas en esa pantalla.
   Un fallo al guardar la tarjeta de notificación no deshace la asignación.
3. Notificar exige confirmación explícita. Primero se persisten decisión, idioma
   y clave de idempotencia; después se solicita el envío por el BFF. Cerrar la
   pantalla o pulsar Finalizar no constituye consentimiento.
4. Sin conexión, la intención consentida queda guardada. Con sesión válida,
   sincroniza al reabrir, volver a primer plano y cada 15 segundos con la app activa.
   Reintenta errores transitorios con backoff/jitter acotado a aproximadamente
   cinco minutos. No promete sincronización con el proceso terminado.
5. Desde **Notificaciones** en ambos dashboards se configuran permisos del
   dispositivo. El entrenador ve además historial local, cuota y estados.

## Fronteras de arquitectura

- `gymsas_notifications`: dominio, puertos, composición y adaptador GraphQL con
  repositorio durable. Sus entidades no dependen de Firebase ni de widgets.
- `gymsas_firebase_messaging`: adaptador Android/iOS de `PushDevice`. Encapsula
  permisos, token, rotación y eventos; no decide cuándo notificar clientes.
- `gymsas_workouts`: `GetConfirmedWorkoutUseCase` valida una referencia push
  contra el repositorio remoto, sin fallback de caché. Después guarda la rutina
  validada por el puerto `ConfirmedWorkoutCachePort`, sin alterar sesiones/outbox.
- `lib/app`: composition root, navegación protegida y ciclo de vida de sesión.
- `lib/features/notifications`: controlador y presentación. Textos es/en desde
  `AppLocalizations`; componentes compartidos en `gymsas_design_system` con tema
  SaaS, estado accesible y loaders. No importa el SDK de Firebase.

La app sólo consume `gymsas-bff`: `notificationQuota`, `notification`,
`notifyRoutineReady`, `retryNotification`, `registerPushDevice` y
`unregisterPushDevice`. No conoce URLs internas, credenciales FCM de servidor
ni implementa reglas comerciales de cuotas.

## Offline first e integridad

El documento cifrado compartido por backend + tenant + usuario conserva una
sección `notifications` versión 1; no sustituye ni borra los datos de workouts.
Las escrituras usan `SerializedOfflineDocumentStore`. En nativo se usa
AES-256-GCM y escritura durable flush+rename, con clave protegida por el sistema.
Nunca se guardan tokens de sesión ni tokens FCM en la cola. El SDK administra su
propio almacenamiento del token; la app sólo lo mantiene en memoria al registrar.

La misma intención reutiliza su clave tras doble clic, respuesta perdida,
fallo al guardar ACK y reapertura. El servidor vuelve a comprobar permisos y
cuota: la cuota cacheada es informativa, no una reserva ni autorización offline.
Si se desconoce la política o está deshabilitada no se habilitan nuevas decisiones.
Una cuota antes descargada y habilitada permite guardar una decisión offline,
aunque al sincronizar pueda ser rechazada por el servidor.

Las respuestas tardías no modifican la cuenta activa si cambió el contexto.
401 pausa los envíos hasta reautenticar; rechazos de permisos, política, cuota
y conflictos conservan la intención y requieren revisión/reintento explícito.
Schemas desconocidos/corrupción no reinicializan datos. Se procesan lotes acotados
de cinco comandos y cinco consultas; el historial local retiene hasta 200 filas,
eliminando sólo filas antiguas no consentidas o terminales sin reintento pendiente.
Si todas están activas, se informa falta de capacidad sin borrar pendientes.
No hay recuperación de historial de notificaciones de otros dispositivos.

El reintento manual de un envío fallido conserva su ID. Se guarda `updatedAt`
original con su precisión y se reconcilia antes de repetir una respuesta perdida.
Un estado incierto exige advertir y confirmar el riesgo de duplicado: no se
reenvía automáticamente ni se promete exactamente una entrega del proveedor.

## Cuota y estados

La UI muestra disponibles, reservadas, agotamiento, ilimitado, deshabilitado y
fecha de reinicio UTC. Señala explícitamente una cuota cacheada sin comprobar.
Tras solicitar/reintentar espera el ACK antes de actualizar la cuota, y consulta
cambios de estado con la app activa. El backend sigue siendo la autoridad.

| Estado | Significado |
| --- | --- |
| Rutina confirmada | Asignación en servidor; todavía sin consentimiento de envío |
| Decisión guardada | Intención durable local; falta ACK del servidor |
| Pendiente / procesando | Solicitud admitida por GymSAS; worker en curso |
| Aceptada por proveedor | FCM aceptó el envío; **no** acredita entrega ni lectura |
| Fallida | Fallo definitivo; no se modifica la rutina |
| Incierta | Resultado no concluyente; no hay reenvío automático |

Los planes del backend se mantienen deshabilitados para notificaciones hasta
aprobar política y cupos comerciales. Esta integración no activa límites,
no cambia suscripciones y no envía notificaciones reales durante sus pruebas.

## Dispositivo y navegación

No se solicita permiso automáticamente. El usuario activa la recepción desde
Notificaciones. Se registra un ID de instalación aleatorio estable con el token
actual, se procesa su rotación y se revalida permiso al volver a primer plano.
Desactivar/logout intenta desregistrar en servidor y borrar el token SDK. Si
no hay red, persiste una baja pendiente que se procesa al recuperar una sesión
válida de esa cuenta; la UI no presenta esa baja como confirmada en servidor.
Un mensaje ya aceptado por FCM no puede retractarse con este procedimiento.

El payload sólo se interpreta si contiene `type=routine_ready`, `routine_id` y
`notification_id` con IDs válidos; no se navega a URLs suministradas por la push.
El aviso en primer plano usa texto genérico localizado, nunca un cuerpo remoto.
Abrir desde push exige sesión de cliente y consulta fresca de acceso a la rutina.
Si está offline, venció la sesión, cambió la cuenta o ya no tiene acceso, muestra
un estado seguro con reintento, no abre otra rutina ni usa caché como autorización.
Las rutinas previamente descargadas siguen disponibles por el flujo normal offline.

Android declara `POST_NOTIFICATIONS` y auto-init FCM deshabilitado por defecto.
iOS declara `remote-notification`, auto-init deshabilitado y entitlement APNs
development en Debug / production en Profile y Release. Deben existir permisos
y perfiles de firma compatibles, capability Push Notifications y una clave APNs
válida en el proyecto Firebase. Nada de eso se aprovisiona desde este código.
Web y escritorio muestran push no compatible; no se añade un service worker web.

## Validación reproducible

```sh
.fvm/flutter_sdk/bin/flutter analyze
.fvm/flutter_sdk/bin/flutter test test packages/gymsas_notifications/test packages/gymsas_firebase_messaging/test packages/gymsas_design_system/test packages/gymsas_auth/test
(cd packages/gymsas_workouts && ../../.fvm/flutter_sdk/bin/dart test)
(cd packages/gymsas_api_client && ../../.fvm/flutter_sdk/bin/dart test)
.fvm/flutter_sdk/bin/flutter build apk --debug
python3 scripts/check_secrets.py --working-tree
```

Los packages Dart puros ejecutan sus tests desde su propio directorio para usar
sus dependencias de desarrollo. Validado el 2026-10-20: análisis sin incidencias,
143 pruebas aprobadas (135 Flutter + 3 workouts + 5 transporte), APK debug
compilado, plist/entitlements iOS válidos y revisión de secretos de los árboles
de trabajo frontend/backend sin hallazgos. Esto no audita de nuevo el historial
de Git ni acredita entrega en un dispositivo.

Las pruebas cubren consentimiento y loaders, español/inglés, asignación parcial,
disco cifrado real + reapertura, respuesta/ACK perdidos, idempotencia, scopes,
401/cuotas/conflictos, permisos, rotación, baja offline y apertura remota segura.
Para validar FCM de extremo a extremo aún se necesita un dispositivo/emulador
con Google Play Services, Firebase configurado y una política de prueba aprobada.
En iOS se necesita además APNs y firma compatibles. Una compilación o un test
simulado no prueba entrega push real.

Prueba manual autorizada: activar recepción en un cliente, publicar una rutina
desde el entrenador, confirmar Notificar, comprobar cuota/estado y abrir el aviso.
Repetir guardando la intención offline, reiniciando y recuperando conexión;
comprobar una única solicitud lógica y la rutina disponible offline tras validarla.
No activar cupos de producción ni usar credenciales reales en fixtures o Git.

Referencias oficiales: [configuración FCM para Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
y [recepción de mensajes](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages).
