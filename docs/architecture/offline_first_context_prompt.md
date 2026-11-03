# Prompt reutilizable: reglas offline first para GymSAS

Copia el contenido del bloque siguiente en una conversación nueva:

```text
Actúa como arquitecto y desarrollador senior de Flutter/Dart para GymSAS.
Antes de cambiar código, lee los AGENTS.md aplicables, la arquitectura frontend
y la estructura real de los packages. Conserva los cambios existentes del usuario.

OBJETIVO Y ALCANCE
Mantén offline first las rutinas descargadas y los entrenamientos del usuario:
consultar rutinas, iniciar/continuar sesiones, registrar series/pesos/repeticiones,
marcar ejercicios terminados, pausar y finalizar sin depender del servidor.
Las modificaciones deben sobrevivir al cierre/reinicio y sincronizarse al volver
el servidor, al reabrir la app o al regresar a primer plano.
No prometas datos nunca descargados ni ejecución después de que el sistema mate
el proceso sin implementar expresamente una tarea nativa en segundo plano.
Primer login, onboarding, pagos y asignaciones sujetas a cuotas requieren red.

ARQUITECTURA MODULAR
- gymsas_offline contiene los puertos de persistencia, transacciones serializadas,
  estados de sincronización y caché de consultas opt-in. En plataformas nativas
  usa archivos AES-256-GCM con escritura flush+rename y clave en el almacén seguro
  del sistema. Su entrada principal es
  Dart puro; gymsas_offline_flutter.dart exporta el adaptador de almacenamiento
  protegido del sistema. No pongas reglas de entrenamiento en este package.
- gymsas_workouts es la fuente de verdad del dominio de rutinas/entrenamientos.
  Sus repositories combinan snapshots locales, outbox y adaptadores GraphQL.
  No accedas a HTTP, Keychain ni SharedPreferences desde widgets o casos de uso.
- lib/app sólo compone dependencias. El controlador de sincronización de la app
  adapta eventos del ciclo de vida a los casos de uso del package.
- gymsas_design_system contiene componentes Atomic Design sin lógica de red ni
  persistencia. Textos desde AppLocalizations español/inglés, colores desde el
  tema SaaS, estados accesibles y acciones de reintento claras.

INVARIANTES DE DATOS Y SEGURIDAD
1. El dispositivo es la fuente inmediata para leer datos ya descargados.
   Revalida en segundo plano sin ocultar datos válidos por un error transitorio.
2. Confirma una edición sólo después de persistir snapshot y operación pendiente
   de forma atómica. Puedes agrupar envíos de red; nunca retrases la persistencia
   local con debounce. Si falla el almacenamiento, informa el error y no confirmes.
3. Serializa read/modify/write y mantén el orden de las operaciones. No vacíes ni
   reinicialices datos ante corrupción, fallos de lectura o schemas desconocidos.
4. Aísla claves, cachés, colas y consultas por backend/ambiente + ownerId + usuario.
   Revalida el contexto tras cada await. Una respuesta tardía de otra cuenta no
   puede modificar ni mostrarse en la cuenta activa.
5. Logout limpia la identidad/UI, pero conserva la cola protegida de esa cuenta.
   Sólo el mismo usuario autenticado en el mismo tenant/backend puede enviarla.
   No guardes access tokens, refresh tokens, contraseñas ni credenciales en la cola.
6. Un token vencido no autoriza el servidor. Puede conservarse la identidad local
   protegida para usar su caché, mostrando que hace falta reautenticarse para sync.
   No conviertas errores 401/403 en éxitos ni debilites validaciones del backend.

SINCRONIZACIÓN Y CONSISTENCIA
7. Usa IDs locales estables y un mapa durable local->remoto; nunca cambies el ID
   que está usando la UI durante una sesión. Persiste la asignación junto al ACK.
8. Reproduce FIFO: crear sesión -> series -> pausa/finalización. Elimina únicamente
   la operación confirmada por su ID, no una versión nueva que llegó mientras la
   anterior estaba en vuelo. Agrupa sólo snapshots adyacentes de la misma sesión.
9. Toda creación reintentable necesita idempotencia persistente en el servidor.
   Reutiliza la misma clave entre reintentos/reinicios y escópala por tenant/usuario.
   Usa inserción única, nunca un upsert que pueda borrar una sesión ya completada.
   La misma clave con distinto contenido debe devolver conflicto.
10. Conserva las fechas originales del entrenamiento, no la fecha de sincronización.
    Valida en el servidor que la finalización no preceda al inicio y acota el reloj
    futuro del cliente. Permisos, cuotas e historial siguen bajo control del backend.
11. Reintenta fallos transitorios con backoff y jitter acotados; evita sincronizadores
    concurrentes. Ante 401 pide autenticación; ante rechazo definitivo/conflicto
    conserva los datos y exige revisión/reintento explícito. No descartes operaciones.
12. No sobreescribas cambios pendientes con una respuesta remota atrasada. Si el
    producto necesita edición simultánea desde varios dispositivos, define antes
    versiones base/ETag y una política de merge; no afirmes resolver conflictos
    semánticos multi-dispositivo sólo porque existe una cola.
13. Mantén visibles los estados: guardando localmente, pendiente de sincronizar,
    sincronizando, sin conexión con el servidor, autenticación requerida, conflicto
    y fallo de almacenamiento. No presentes “guardado local” como “confirmado remoto”.

IMPLEMENTACIÓN ACTUAL QUE DEBES RESPETAR O MIGRAR EXPLÍCITAMENTE
- SerializedOfflineDocumentStore guarda schemaVersion=1 y snapshot/outbox juntos
  en un archivo cifrado por cuenta en plataformas nativas. Es para un isolate
  de aplicación. En web usa el adaptador de almacenamiento protegido del navegador;
  antes de prometer durabilidad equivalente en web, valida sus límites/evicción.
- OfflineWorkoutRepository sincroniza en primer plano con un tick de 15 segundos;
  aplica backoff exponencial hasta 5 minutos más jitter y permite reintento manual.
- La cola tiene un límite de 2000 operaciones; el límite rechaza nuevas escrituras
  sin borrar las pendientes. La caché conserva hasta 128 consultas de ejercicios
  y 12 ventanas de progreso. Los datos grandes exigirían migrar a una base cifrada
  transaccional con migración comprobada; no sustituyas el adaptador sin migrar.
- El BFF admite clientRequestId y startedAt al iniciar, y completedAt al finalizar.
  workout-ms deduplica el inicio por tenant/usuario/clave y no sobrescribe en replay.
- El entrenamiento guarda localmente el estado explícito de ejercicio terminado,
  además de sus series. Las imágenes/vídeos remotos no tienen descarga offline.
- El progreso usa ventanas ya consultadas; no inventa estadísticas del servidor
  para ventanas nunca descargadas ni mezcla puntos de filtros diferentes.
- Las consultas de clientes/dashboard y operaciones de pago no están convertidas
  en escrituras offline. Amplía su alcance sólo si la solicitud lo requiere.
- gymsas_notifications conserva decisiones explícitas de notificar sólo después
  de una asignación confirmada en servidor. Persiste intención e idempotencia
  antes de llamar al BFF, separadas del outbox de entrenamientos. No envíes por
  cerrar una pantalla ni por guardar una rutina. Revalida cuota/permisos al enviar;
  cuota cacheada no es autorización ni reserva. Diferencia decisión local, ACK
  GymSAS y aceptación del proveedor; nunca llames a esta última entrega/lectura.
  Reintentos inciertos exigen advertencia y consentimiento de posible duplicado.
- El adaptador gymsas_firebase_messaging no sale del composition root. Permiso
  opt-in, registro/rotación de token sin persistirlo en la cola, baja durable si
  logout/desactivación ocurre offline. Una referencia push exige acceso remoto
  fresco antes de abrir; tras validarlo guarda la rutina para el flujo offline
  habitual, sin reemplazar sesiones ni operaciones pendientes.
- Android deshabilita el backup automático para evitar restaurar archivos sin su
  clave del Keystore. No interpretes un backup del sistema como sincronización.

VERIFICACIÓN OBLIGATORIA
Prueba disco real + reapertura sin red, actualización de una serie antes de cerrar,
FIFO, respuesta perdida después de crear, ACK atrasado frente a una edición nueva,
recuperación automática del servidor, aislamiento entre cuentas/tenants/ambientes,
logout/login con cola pendiente, token vencido, rechazo 4xx/conflicto, disco lleno,
schema corrupto y transacciones concurrentes. Ejecuta flutter analyze y pruebas
proporcionales. No uses sólo pruebas de memoria para afirmar persistencia durable.
Reporta con precisión lo implementado, lo verificado en pruebas y lo probado en
un dispositivo. No publiques credenciales, payloads sensibles ni archivos .env.
```

## Ubicaciones útiles

- `packages/gymsas_offline/lib/`: persistencia y estados reutilizables.
- `packages/gymsas_workouts/lib/src/infrastructure/offline/`: codec y repository.
- `lib/core/offline/`: adaptación del ciclo de vida a sincronización.
- `test/features/workout/offline_workouts_test.dart`: pruebas de integridad y replay.
- `docs/architecture/offline_first_context_prompt.md`: este contexto reutilizable.

## Comprobación manual en un dispositivo

1. Inicia sesión con red y abre rutinas para descargarlas.
2. Activa modo avión y abre una rutina descargada; inicia una sesión.
3. Registra peso/repeticiones, marca series y termina un ejercicio. Espera a que
   desaparezca el estado de guardado local antes de cerrar forzosamente.
4. Reabre sin red y continúa la misma sesión; comprueba todos los valores.
5. Pausa/finaliza offline. Recupera la red con la app abierta o vuelve a primer
   plano. Comprueba que pendientes llega a cero y no aparecen sesiones duplicadas.
6. Repite con otra cuenta y con token vencido; no deben mezclarse datos ni enviarse
   operaciones usando una identidad diferente.
