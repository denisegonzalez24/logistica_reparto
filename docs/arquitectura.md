# Arquitectura de la app Flutter

## Objetivo

Este documento resume la arquitectura elegida para la aplicación de logística de reparto, la forma en que se adaptó MVVM a Flutter y qué se implementó hasta ahora para el login con Firebase Authentication.

## Resumen general

La aplicación fue pensada para reproducir en Flutter una app nativa Android ya existente, manteniendo una estructura clara por responsabilidades.

La idea principal es separar:

- la interfaz de usuario,
- la lógica de estado y validación,
- el acceso a datos y servicios externos,
- y la navegación entre pantallas.

Eso permite que el proyecto crezca sin que toda la lógica termine concentrada en un solo archivo.

## Patrón de diseño usado

El patrón base es **MVVM**:

- **Model**: representa datos del dominio, por ejemplo usuarios, camiones, clientes o rutas.
- **View**: muestra la interfaz y captura interacción del usuario.
- **ViewModel**: contiene el estado de la pantalla, la lógica de presentación y las acciones que dispara la UI.

En Flutter, MVVM no se implementa de forma idéntica a Android nativo. En este proyecto, la adaptación se apoya en `Provider` para exponer el estado del ViewModel a la interfaz.

### Equivalencia en este proyecto

- `LoginScreen` -> View contenedora de la pantalla.
- `LoginForm` -> View de interacción del login.
- `AuthProvider` -> ViewModel del login.
- `AuthRepository` -> capa de acceso a Firebase Authentication.
- `AuthGate` -> pantalla de decisión que resuelve si el usuario entra al login o a la app.

## Qué es un widget

En Flutter, un **widget** es la unidad básica de construcción de la interfaz.

Todo en pantalla se arma con widgets:

- textos,
- botones,
- campos de formulario,
- contenedores,
- pantallas completas,
- layouts,
- indicadores de carga.

Un widget puede ser muy pequeño o muy grande. Por ejemplo:

- un `Text` es un widget,
- un `ElevatedButton` es un widget,
- una pantalla completa como `LoginScreen` también es un widget.

## Por qué se usan widgets separados

Separamos widgets cuando eso mejora la organización del proyecto y no agrega complejidad innecesaria.

### Beneficios

- La pantalla principal queda más limpia.
- El formulario se puede reutilizar o modificar sin tocar toda la pantalla.
- La lógica visual queda separada de la lógica de estado.
- Es más fácil mantener el código cuando el proyecto crece.

### Regla práctica

No conviene crear widgets por cada detalle mínimo si no aportan valor real. En este proyecto la separación se usa solo donde hay una responsabilidad clara.

## Estado y navegación

La sesión del usuario se resuelve con Firebase Authentication.

La aplicación escucha el estado de autenticación con `authStateChanges()` y decide qué pantalla mostrar:

- si hay usuario autenticado, entra a la app,
- si no hay usuario, muestra el login.

Eso permite que el usuario permanezca logueado al volver a abrir la app sin tener que iniciar sesión otra vez.

## Estructura del login implementado

El login quedó organizado así:

```text
LoginScreen
↓
LoginForm
↓
AuthProvider
↓
AuthRepository
↓
FirebaseAuth
```

### Responsabilidad de cada capa

#### LoginScreen

- arma el layout general de la pantalla,
- contiene el formulario,
- no contiene lógica de autenticación.

#### LoginForm

- captura email y contraseña,
- valida el formulario,
- dispara la acción de login,
- muestra loading y errores básicos.

#### AuthProvider

- administra el estado de la vista,
- expone `isLoading` y `errorMessage`,
- ejecuta la acción de login,
- ejecuta logout cuando corresponde.

#### AuthRepository

- se comunica directamente con FirebaseAuth,
- realiza `signInWithEmailAndPassword`,
- expone `authStateChanges()`,
- hace `signOut()`.

#### AuthGate

- escucha si hay sesión activa,
- redirige a login o a la app principal,
- mantiene `main.dart` lo más limpio posible.

## Qué se implementó en Firebase

Hasta ahora la integración con Firebase incluye:

- `firebase_core` para inicializar Firebase,
- `firebase_auth` para autenticación,
- `cloud_firestore` como base para el resto del proyecto,
- configuración generada con FlutterFire (`firebase_options.dart`).

### Firebase Authentication

El login se implementó usando la autenticación nativa de Firebase, no una colección personalizada de usuarios en Firestore.

Eso significa que:

- el correo y la contraseña se validan contra Firebase Auth,
- la sesión persiste automáticamente,
- el estado de sesión se puede escuchar con `authStateChanges()`.

### Firestore

Aunque el login no depende de Firestore, la app lo tendrá disponible para el resto del flujo:

- camiones,
- rutas,
- clientes,
- registros de visitas,
- estado de la ruta,
- datos del recorrido.

## Limpieza de `main.dart`

`main.dart` quedó como punto de arranque de la aplicación.

Su responsabilidad es:

- inicializar Flutter,
- inicializar Firebase,
- registrar providers,
- cargar el `MaterialApp`,
- abrir `AuthGate` como pantalla raíz.

La idea es evitar que `main.dart` acumule lógica de negocio o navegación.

## Criterio de organización usado

La organización del proyecto sigue esta idea:

- **screens**: pantallas o contenedores de UI,
- **widgets**: piezas visuales reutilizables o con responsabilidad propia,
- **providers**: estado y acciones de la vista,
- **repositories**: acceso a servicios externos y datos,
- **models**: estructuras de datos del dominio.

## Decisiones recomendadas para el resto de la app

Para mantener el proyecto consistente, conviene seguir estas reglas:

- usar MVVM como base general,
- dejar la UI lo más declarativa posible,
- evitar meter lógica de Firebase dentro de widgets,
- poner validación y estado en el ViewModel,
- poner acceso a Firestore, Auth, GPS o Gemini en repositories o services,
- separar widgets solo si aportan reutilización o claridad.

## Próximos módulos esperados

Después del login, los próximos bloques de la app probablemente sean:

- selección de camión,
- captura de foto de hoja de ruta,
- análisis con Gemini,
- edición de clientes,
- inicio de ruta,
- mapa y geolocalización,
- registro de visitas,
- notificaciones,
- cierre de ruta.

Cada uno de esos módulos puede seguir la misma lógica de separación por responsabilidad.

## Conclusión

La implementación actual sigue una versión práctica de MVVM adaptada a Flutter.

No se está usando Bloc. `Provider` se utiliza como mecanismo para exponer el estado del ViewModel, mientras que Firebase Authentication maneja la sesión persistente del usuario.

El resultado es una base ordenada, fácil de mantener y lista para escalar al resto de la aplicación.
