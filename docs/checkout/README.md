# Checkout y pagos

La app consulta planes y crea sesiones de pago únicamente a través del BFF.
Mercado Pago es el proveedor actual, no una dependencia del dominio.

```text
Flutter -> gymsas-bff (GraphQL) -> payment-ms -> Mercado Pago
   |                                      ^
   +---- SDK nativo: tokenización --------+
```

## Configuración

Flutter recibe solamente la clave pública:

```dotenv
MERCADO_PAGO_PUBLIC_KEY=TEST-tu-public-key
```

El backend conserva las credenciales privadas:

```dotenv
MERCADO_PAGO_ACCESS_TOKEN=TEST-tu-access-token
MERCADO_PAGO_WEBHOOK_SECRET=tu-secreto-de-webhook
```

Configura en Mercado Pago una URL pública HTTPS:

```text
https://tu-dominio/webhooks/mercado-pago
```

Los datos de tarjeta se capturan y tokenizan en el SDK nativo. No deben
atravesar Dart, GraphQL ni almacenarse en GymSAS.

## Modularidad del proveedor

`gymsas_payments` expone el puerto `PaymentGateway`, modelos propios y casos de
uso. `MercadoPagoGateway` es un adaptador intercambiable.

Para integrar Stripe u otro proveedor:

1. Implementa `PaymentGateway` dentro de un adaptador nuevo.
2. Traduce allí los DTO y errores del proveedor.
3. Registra el adaptador en el composition root.
4. Conserva sin cambios presentación, aplicación y dominio.
5. Implementa el proveedor equivalente en `payment-ms` y selecciónalo mediante
   configuración.

El detalle interno del plugin está en
[`packages/gymsas_payments/README.md`](../../packages/gymsas_payments/README.md).

## Plataformas

- Android obtiene el SDK desde el repositorio Maven de Mercado Libre.
- iOS usa Swift Package Manager y requiere iOS 15 o posterior.

Si Gradle no resuelve el SDK, confirma este repositorio en
`android/build.gradle.kts`:

```kotlin
maven { url = uri("https://artifacts.mercadolibre.com/repository/android-releases") }
```

