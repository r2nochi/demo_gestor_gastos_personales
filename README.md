# Saldo

> Tu dinero, claro como el agua.

Saldo es un **gestor de gastos e ingresos** para Android, escrito en **Flutter** y diseñado para funcionar 100% offline, con privacidad por defecto. Inspirado en apps tradicionales del rubro, pero con identidad y experiencia propias: Material 3, modo oscuro nativo, microinteracciones, bottom navigation moderna y FAB central para añadir transacciones rápidas.

## Características

- Registro rápido de **gastos** e **ingresos** con monto, categoría, cuenta, fecha y comentario.
- **Categorías** personalizables (40+ íconos y 20 colores) separadas por tipo.
- **Cuentas múltiples**: principal, ahorros, tarjeta, efectivo…
- **Dashboard** con donut chart, totales por periodo y desglose por categoría.
- **Gráficos** comparativos ingresos vs gastos (día/semana/mes) + balance acumulado.
- **Filtros** por día, semana, mes, año y período personalizado.
- **Búsqueda** global por categoría, nota o monto.
- **Pagos habituales** (recurrentes diarios, semanales, mensuales y anuales) con procesamiento automático.
- **Recordatorios** con notificaciones locales programadas.
- **PIN** opcional al abrir la app.
- **Exportar** a JSON (respaldo completo) y CSV.
- **Multi-moneda**: PEN, USD, EUR, MXN, COP, ARS, CLP.
- **Modo oscuro** automático según el sistema.
- Onboarding de 3 pasos al primer arranque.

## Stack

| Capa | Tecnología |
|---|---|
| UI | Flutter 3 (Material 3) |
| Estado | Provider |
| Persistencia | sqflite (SQLite local) |
| Charts | fl_chart |
| Notificaciones | flutter_local_notifications + timezone |
| Tipografía | google_fonts (Inter) |

## Estructura

```
lib/
├── core/           Constantes, theming, formatters, catálogo de íconos
├── data/           DB + repositorios + seed
├── models/         Account, Category, Recurring, Reminder, Txn
├── providers/      ChangeNotifier por dominio
├── screens/        UI agrupada por feature
├── services/       Notificaciones locales y respaldos
└── widgets/        Componentes reutilizables (donut, period selector, etc.)
```

## Cómo correrlo en desarrollo

1. Asegúrate de tener Flutter 3.19+ y un Android SDK configurado.
2. Desde `saldo/` ejecuta:

   ```bash
   flutter pub get
   flutter run
   ```

## Generar el AAB para Play Store

1. Crea (o reutiliza) una keystore:

   ```bash
   keytool -genkey -v -keystore ~/saldo-release.jks \
       -keyalg RSA -keysize 2048 -validity 10000 \
       -alias saldo
   ```

2. Crea `android/key.properties` (no se sube al repo):

   ```properties
   storePassword=********
   keyPassword=********
   keyAlias=saldo
   storeFile=/ruta/absoluta/saldo-release.jks
   ```

3. Genera el AAB firmado:

   ```bash
   flutter build appbundle --release
   ```

   El artefacto queda en `build/app/outputs/bundle/release/app-release.aab`.

4. Sube el AAB a [Play Console](https://play.google.com/console/) y completa la ficha de la app.

### Notas para Play Store

- `applicationId`: `com.saldo.app`
- `minSdk` 23 (Android 6.0+), `targetSdk` 34.
- La app **no** solicita permisos peligrosos; solo `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM` y `RECEIVE_BOOT_COMPLETED` para programar recordatorios y pagos habituales.
- Sin tracking, sin red. 100% offline.

## Datos & privacidad

- Toda la información se guarda en una base SQLite local (`saldo.db`) en almacenamiento privado de la app.
- El usuario puede exportar manualmente respaldos JSON/CSV y compartirlos por su canal preferido.
- Hay un botón en Ajustes para borrar todos los datos.

## Roadmap corto

- Importar respaldo JSON desde la UI.
- Adjuntar foto al detalle de una transacción.
- Etiquetas/tags por transacción (modelo ya soporta el campo).
- Widget de Android para añadir gasto sin abrir la app.

---

© 2025 Saldo. Hecho con cariño en Flutter.
