# gymsas_payments

Plugin interno del bounded context de pagos. La API pública no conoce Mercado
Pago, Stripe ni sus DTOs. Expone catálogo, creación de sesión y el puerto
`PaymentGateway`.

`PaymentsModule.mercadoPago` es el composition root actual. El cliente HTTP no
interpreta DTOs de Mercado Pago: delega esa traducción a su adaptador.

Un proveedor nuevo implementa `PaymentGateway` y su decoder de sesión. Puede
ensamblarse con `PaymentsModule.custom`, sin modificar dominio, caso de uso,
controlador ni pantalla. Los SDK nativos y sus platform channels viven dentro
del plugin, no en los runners de la aplicación.

El adaptador iOS usa Swift Package Manager y requiere Flutter 3.44 o posterior.
