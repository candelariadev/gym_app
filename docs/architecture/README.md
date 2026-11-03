# Arquitectura

La aplicación combina módulos por feature con paquetes reutilizables. Sigue
dependencias hacia adentro: presentación conoce casos de uso; los casos de uso
conocen puertos y dominio; Firebase, GraphQL y Mercado Pago son adaptadores.

## Flujo de dependencias

```text
features/presentation
        |
        v
application/use cases -> domain + ports
        ^
        |
infrastructure/adapters -> GraphQL, Firebase, SDK nativo
```

`lib/app` es el composition root: construye implementaciones y las entrega a
los módulos. No debe trasladarse esa construcción a widgets o entidades.

## Estructura

```text
lib/
├── app/                  # Composition root y navegación protegida
├── core/                 # Configuración transversal
├── features/             # Presentación y orquestación por feature
└── l10n/                 # Recursos de localización

packages/
├── gymsas_api_client/    # Transporte GraphQL, timeouts y errores
├── gymsas_auth/          # Dominio, puertos y casos de uso de autenticación
├── gymsas_firebase_auth/ # Adaptador Firebase/Google
├── gymsas_clients/
├── gymsas_dashboard/
├── gymsas_design_system/
├── gymsas_exercises/
├── gymsas_payments/      # Dominio de pago, puertos y adaptadores nativos
├── gymsas_offline/       # Persistencia cifrada y consultas locales opt-in
├── gymsas_workouts/      # Rutinas, sesiones y outbox offline
├── gymsas_notifications/ # Decisiones durables, cuota y seguimiento vía BFF
└── gymsas_firebase_messaging/ # Adaptador PushDevice Android/iOS
```

## Reglas

- La app sólo consume `gymsas-bff`; no conoce URLs ni claves internas de los MS.
- Modelos GraphQL, Firebase o Mercado Pago no salen de sus adaptadores.
- Un puerto expresa una capacidad del dominio, no la API de un proveedor.
- Request/response de transporte se separan de entidades y value objects.
- Cada feature conserva presentación, aplicación, dominio e infraestructura
  sólo cuando esas capas aportan una responsabilidad real.
- La navegación depende del estado de sesión, no directamente de Firebase.
- El diseño compartido vive en `gymsas_design_system`, no se duplica por feature.

## Límites importantes

`gymsas_auth` define `ExternalIdentityProvider`; `gymsas_firebase_auth` lo
implementa. `gymsas_payments` define `PaymentGateway`; Mercado Pago lo
implementa. Estas fronteras permiten sustituir proveedores sin reescribir el
flujo de negocio.

`gymsas_notifications` define `PushDevice`; `gymsas_firebase_messaging` lo
implementa. La asignación confirmada no implica consentimiento de notificación.
El historial y las decisiones consentidas son locales primero; permisos, cuotas
y apertura desde una referencia push se revalidan en servidor. Ver
[notificaciones](../notifications/README.md) y
[reglas offline first](offline_first_context_prompt.md).

