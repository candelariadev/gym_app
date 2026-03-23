# gym_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# 🚀 SaaS Admin App (Flutter)

Aplicación Flutter basada en arquitectura **multitenant SaaS**, diseñada para escalar múltiples clientes (tenants) dentro de una sola base de código.

---

## 🧩 Características

- 🏢 Arquitectura **multitenant**
- 🌐 Soporte para múltiples entornos (dev, staging, prod)
- 🔐 Autenticación y manejo de sesiones
- 🎯 Resolución de tenant por login / configuración
- 🧱 Arquitectura modular (feature-based)
- ⚙️ Configuración centralizada
- 📱 Multiplataforma (Android, iOS, Web)

---

## 🏗️ Estructura del proyecto

```bash
lib/
│
├── app/              # Configuración global (router, app, bootstrap)
├── core/             # Configuración, utilidades, servicios base
├── features/         # Módulos por funcionalidad (auth, tenant, etc)
├── shared/           # Widgets y utilidades reutilizables
│
├── main_dev.dart
├── main_staging.dart
└── main_prod.dart