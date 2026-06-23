# ⏱️ Hours & Income Tracker

**Aplicación móvil para el registro de horas de trabajo y cálculo automático de ingresos estimados.**

Diseñada para freelances, autónomos y trabajadores por horas que necesitan llevar un control preciso de su jornada laboral y visualizar sus ganancias en tiempo real.

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características Principales](#-características-principales)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
- [Estructura de Directorios](#-estructura-de-directorios)
- [Modelo de Datos y Persistencia](#-modelo-de-datos-y-persistencia)
- [Tecnologías y Dependencias](#-tecnologías-y-dependencias)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Ejecución](#-instalación-y-ejecución)
- [Roadmap](#-roadmap)
- [Licencia](#-licencia)

---

## 🎯 Descripción

**Hours & Income Tracker** es una aplicación multiplataforma desarrollada en Flutter que permite al usuario:

1. **Registrar las horas trabajadas cada día** con precisión de cuartos de hora (0.25h).
2. **Calcular automáticamente los ingresos estimados** a partir de una tarifa por hora configurable.
3. **Visualizar el progreso mensual** hacia un objetivo de horas personalizable.
4. **Añadir notas diarias opcionales** a cualquier jornada (ausencias, festivos, incidencias, etc.).
5. **Recibir recordatorios diarios** para no olvidar registrar la jornada.

La interfaz utiliza un diseño oscuro premium con estética glassmorphic, animaciones fluidas y tipografía profesional (Plus Jakarta Sans vía Google Fonts).

---

## ✨ Características Principales

| Característica | Descripción |
|---|---|
| 🕐 **Registro flexible de horas** | Incrementos de 0.25h (cuartos de hora), slider interactivo y presets rápidos (0, 4, 8, 10, 12h). |
| 📝 **Notas diarias opcionales** | Campo de texto libre asociado a cada día para registrar motivos de ausencia, comentarios o incidencias. |
| 💰 **Cálculo de ingresos en tiempo real** | Multiplicación automática de horas × tarifa por hora con animación de contador. |
| 📊 **Progreso mensual visual** | Anillo de progreso circular que muestra el avance respecto al objetivo de horas del mes. |
| 📅 **Calendario interactivo** | Vista mensual completa con indicadores de color por día trabajado e indicador naranja para días con notas. |
| 🔔 **Recordatorios locales** | Notificaciones diarias configurables para recordar el registro de horas. |
| 💱 **Multi-divisa** | Soporte para €, $, £, ¥ y ₩. |
| 🎨 **Diseño premium dark mode** | Glassmorphism, gradientes, micro-animaciones y tipografía Plus Jakarta Sans. |

---

## 🏗️ Arquitectura del Proyecto

La aplicación sigue una arquitectura **limpia y reactiva**, organizada en tres capas bien diferenciadas:

```
┌─────────────────────────────────────────────────┐
│                   UI Layer                      │
│  (Screens, Widgets, Theme)                      │
│                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Home    │ │ Calendar │ │    Settings      │ │
│  │  Screen  │ │  Screen  │ │     Screen       │ │
│  └────┬─────┘ └────┬─────┘ └───────┬──────────┘ │
│       │            │               │            │
│  ┌────┴────┐  ┌────┴────┐  ┌───────┴──────────┐ │
│  │ Hours   │  │ Glass   │  │ Animated Counter │ │
│  │ Picker  │  │  Card   │  │                  │ │
│  └─────────┘  └─────────┘  └──────────────────┘ │
└───────────────────┬─────────────────────────────┘
                    │  context.watch / context.read
┌───────────────────┴─────────────────────────────┐
│              State Management Layer             │
│          (Provider + ChangeNotifier)             │
│                                                 │
│  ┌─────────────────────────────────────────────┐ │
│  │              AppState                       │ │
│  │                                             │ │
│  │  • Horas por día (Map<String, double>)      │ │
│  │  • Notas por día (Map<String, String>)      │ │
│  │  • Tarifa, divisa, objetivo, recordatorios  │ │
│  │  • Cálculos derivados (totales, progreso)   │ │
│  └──────────────┬──────────────────────────────┘ │
└─────────────────┼───────────────────────────────┘
                  │  async read/write
┌─────────────────┴───────────────────────────────┐
│               Services Layer                    │
│  (Persistencia local + Notificaciones)          │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────────┐ │
│  │ StorageService   │  │ NotificationService  │ │
│  │ (SharedPrefs)    │  │ (Local Notifications)│ │
│  └──────────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Patrón de gestión de estado

Se utiliza **Provider** (`ChangeNotifierProvider<AppState>`) como solución de gestión de estado reactivo. Cada vez que el usuario modifica horas, notas o configuración, `AppState` persiste los cambios en `StorageService` y llama a `notifyListeners()`, lo que provoca la reconstrucción automática de los widgets suscritos.

---

## 📁 Estructura de Directorios

```
lib/
├── main.dart                          # Punto de entrada, inicialización de servicios y navegación principal
├── providers/
│   └── app_state.dart                 # Estado reactivo global (ChangeNotifier)
├── services/
│   ├── storage_service.dart           # Capa de persistencia local (SharedPreferences)
│   └── notification_service.dart      # Gestión de notificaciones locales programadas
└── ui/
    ├── theme.dart                     # Sistema de diseño: colores, gradientes, tipografía, tema Material 3
    ├── screens/
    │   ├── home_screen.dart           # Dashboard principal: saludo, ganancias, progreso, registro del día
    │   ├── calendar_screen.dart       # Calendario mensual interactivo con edición de horas y notas
    │   ├── edit_hours_sheet.dart      # Bottom sheet para editar horas y notas de un día concreto
    │   └── settings_screen.dart       # Configuración: tarifa, divisa, objetivo, recordatorios, reset
    └── widgets/
        ├── hours_picker.dart          # Selector de horas reutilizable (stepper + slider + presets)
        ├── glass_card.dart            # Contenedor glassmorphic reutilizable
        └── animated_counter.dart      # Contador animado de ganancias
```

---

## 🗄️ Modelo de Datos y Persistencia

La aplicación utiliza **`SharedPreferences`** como mecanismo de almacenamiento local. No se utiliza una base de datos relacional ni NoSQL; los datos se serializan directamente en pares clave-valor del almacenamiento nativo del dispositivo.

### Esquema de datos persistidos

| Clave | Tipo | Valor por defecto | Descripción |
|---|---|---|---|
| `hourly_rate` | `double` | `15.0` | Tarifa por hora del usuario |
| `currency` | `String` | `€` | Símbolo de la divisa seleccionada |
| `target_hours` | `double` | `160.0` | Objetivo mensual de horas |
| `work_entries` | `String` (JSON) | `{}` | Mapa `{ "YYYY-MM-DD": hours }` serializado |
| `day_notes` | `String` (JSON) | `{}` | Mapa `{ "YYYY-MM-DD": "nota" }` serializado |
| `reminder_enabled` | `bool` | `false` | Si las notificaciones diarias están activas |
| `reminder_time` | `String` | `20:00` | Hora de envío del recordatorio (formato HH:mm) |

### Formato de serialización JSON

**Entradas de horas (`work_entries`)**:
```json
{
  "2026-06-01": 8.0,
  "2026-06-02": 7.25,
  "2026-06-03": 4.5
}
```

**Notas diarias (`day_notes`)**:
```json
{
  "2026-06-03": "Salí antes por cita médica",
  "2026-06-15": "Festivo - no laborable"
}
```

> **Nota sobre la elección de SharedPreferences**: Se optó por este mecanismo por su simplicidad y porque el volumen de datos es reducido (como máximo ~365 entradas de horas y ~365 notas por año). Para escenarios con mayor volumen de datos o consultas complejas, se recomendaría migrar a SQLite (vía `sqflite`) o Hive.

---

## 🛠️ Tecnologías y Dependencias

| Paquete | Versión | Propósito |
|---|---|---|
| **Flutter SDK** | `^3.12.2` | Framework de desarrollo multiplataforma |
| `provider` | `^6.1.2` | Gestión de estado reactivo (ChangeNotifier + Consumer) |
| `shared_preferences` | `^2.2.3` | Almacenamiento local clave-valor (persistencia) |
| `flutter_local_notifications` | `^17.1.2` | Notificaciones locales programadas |
| `timezone` | `^0.9.2` | Gestión de zonas horarias para notificaciones |
| `flutter_timezone` | `^5.1.0` | Detección automática de la zona horaria del dispositivo |
| `intl` | `^0.19.0` | Internacionalización y formateo de fechas en español |
| `google_fonts` | `^6.2.1` | Tipografía Plus Jakarta Sans desde Google Fonts |
| `cupertino_icons` | `^1.0.8` | Iconos de estilo iOS |

### Herramientas de desarrollo

| Paquete | Propósito |
|---|---|
| `flutter_lints` | Reglas de linting recomendadas |
| `flutter_launcher_icons` | Generación automatizada del icono de la app |

---

## 📦 Requisitos Previos

- **Flutter SDK** `>= 3.12.2` ([Guía de instalación](https://docs.flutter.dev/get-started/install))
- **Dart SDK** `>= 3.12.2` (incluido con Flutter)
- **Android Studio** o **VS Code** con extensiones de Flutter/Dart
- **Dispositivo Android/iOS** o emulador configurado

---

## 🚀 Instalación y Ejecución

```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd flutter_test_app_my

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo desarrollo
flutter run

# 4. Compilar APK de release (opcional)
flutter build apk --release

# 5. Compilar App Bundle para Google Play (opcional)
flutter build appbundle --release
```

### Generar icono de la aplicación

```bash
dart run flutter_launcher_icons
```

