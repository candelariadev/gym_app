# Localización

Los textos visibles se administran en archivos ARB bajo `lib/l10n`. No agregues
cadenas de interfaz directamente en widgets o adaptadores.

## Flujo

1. Agrega la clave y el texto base al ARB principal.
2. Agrega la misma clave a cada idioma soportado.
3. Conserva placeholders y metadatos con el mismo nombre y tipo.
4. Genera las clases de localización.
5. Ejecuta análisis y pruebas.

```bash
fvm flutter gen-l10n
fvm flutter analyze
fvm flutter test
```

## Convenciones

- Usa nombres semánticos por función, no por posición visual.
- Reutiliza una clave sólo cuando el significado sea idéntico.
- No traduzcas roles, estados o códigos del backend en la capa de transporte;
  conviértelos a texto localizado en presentación.
- Usa placeholders para nombres, montos y fechas.
- Formatea moneda y fechas según locale; no concatentes símbolos manualmente.
- Incluye estados de error, accesibilidad y textos de botones en los ARB.

