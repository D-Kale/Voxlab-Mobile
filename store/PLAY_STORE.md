# Publicar Voxlab en Google Play

Todo lo necesario para la ficha y la primera subida. Desarrollador: **Borealabs**.

## 1. Datos de la app

| Campo | Valor |
|---|---|
| ID del paquete | `com.borealabs.voxlab` (no se puede cambiar después de la primera subida) |
| Nombre | Voxlab |
| Versión | 1.0.0 (código 1), en `pubspec.yaml` → `version: 1.0.0+1` |
| SDK | mínimo 24 (Android 7), objetivo 36, compilación 37 |
| Permisos | Internet y micrófono |
| Categoría sugerida | Educación |

## 2. Firma

- La clave de subida está en `~/Documents/Voxlab-PlayStore/` (`voxlab-upload.jks` y `key.properties`, con la contraseña). **Hacé una copia de seguridad** (por ejemplo, en un gestor de contraseñas o un disco externo). Sin esta clave no podés publicar actualizaciones; si se pierde, Google permite pedir el cambio de la clave de subida, pero tarda días.
- `android/key.properties` (excluido de git) apunta a esa clave. En otra computadora, copiá ese archivo a `android/key.properties`.
- En Play Console, activá **Firma de apps de Google Play** (viene activada por defecto).

## 3. Generar el paquete

```sh
flutter build appbundle --release
```

Sale en `build/app/outputs/bundle/release/app-release.aab`. Antes de cada actualización, subí el número después del `+` en `pubspec.yaml` (por ejemplo, `1.0.1+2`).

## 4. Textos de la ficha (español)

**Nombre (30):** Voxlab: hablá en público

**Descripción breve (80):** Aprendé oratoria jugando: lecciones cortas, minijuegos y consejos con IA.

**Descripción completa:**

> ¿Te ponés nervioso al hablar en público? Voxlab es tu entrenador de oratoria de bolsillo: lecciones cortas, minijuegos y un coach con inteligencia artificial que escucha tu voz y te ayuda a mejorar.
>
> 🗺️ UN CAMINO PASO A PASO
> Avanzá por unidades: manejo de los nervios, respiración, voz, ritmo y pausas, lenguaje corporal, estructura del mensaje, historias e improvisación. Cada lección combina lectura, quiz, escritura y práctica en voz alta.
>
> 🎮 13 MINIJUEGOS
> Cazá muletillas, inflá el globo de Voxi con la respiración cuadrada, hacé llegar tu voz hasta la última fila, superá trabalenguas en modo turbo, armá discursos, contá historias con cartas al azar y girá la ruleta de improvisación del reto diario.
>
> 🤖 COACH CON IA
> Grabá tu voz y recibí tu ritmo, tus pausas, tus muletillas y un consejo concreto sobre lo que dijiste. Tus textos también reciben correcciones y sugerencias.
>
> 🔥 GAMIFICADO
> Ganá XP y estrellas, mantené tu racha y superá tus récords. Todo con Voxi, el loro que te acompaña.
>
> Basado en técnicas reales de oratoria: respiración diafragmática, proyección de la voz, la regla de tres, el método PREP, la pausa estratégica y el storytelling.

**Gráficos** (en `store/`):
- Ícono 512×512: `icon-512.png`
- Gráfico destacado 1024×500: `feature-graphic.png`
- Capturas de teléfono (1179×2358): `screenshots/1-mapa.png` a `4-juego.png`

## 5. Política de privacidad y eliminación de cuenta

Play exige una URL pública para cada una. Están listas en `store/legal/`:
- `privacidad.html`
- `eliminar-cuenta.html`

**Falta:** reemplazar `CONTACTO_EMAIL` por el correo de soporte de Borealabs y publicarlas. Por ejemplo, copiándolas a `web/` antes de `scripts/deploy_web.sh` quedan en:
- `https://tvoxlab.tech/app/privacidad.html`
- `https://tvoxlab.tech/app/eliminar-cuenta.html`

La app ya tiene **Perfil → Eliminar mi cuenta** (borra la cuenta y todos los datos en el servidor).

## 6. Formulario de seguridad de los datos (respuestas)

| Pregunta | Respuesta |
|---|---|
| ¿Recopila o comparte datos? | Sí |
| ¿Los datos se cifran en tránsito? | Sí (HTTPS) |
| ¿Los usuarios pueden pedir que se eliminen? | Sí (en la app y en la web) |
| **Información personal:** nombre, correo | Recopilados · Funcionalidad de la app, administración de la cuenta · Obligatorios |
| **Audio:** grabaciones de voz | Recopilados, procesados de forma efímera (no se guardan) · Funcionalidad de la app · Opcional (solo en ejercicios de voz) |
| **Actividad en la app:** progreso, contenido generado (textos) | Recopilados · Funcionalidad de la app · Obligatorio |
| **Información de la app y rendimiento:** registros de fallos | Recopilados · Análisis/diagnóstico |
| ¿Se comparten con terceros? | Sí: transcripciones y textos se envían a OpenRouter (proveedor de IA) para generar consejos, sin nombre ni correo |
| Publicidad | No |

## 7. Otros formularios de Play Console

- **Clasificación de contenido:** app educativa, sin violencia, sin contenido sexual, sin compras, sin interacción entre usuarios → todo público.
- **Público objetivo:** 13 años o más (si incluís menores de 13, Play exige cumplir la política de Familias).
- **Anuncios:** no contiene anuncios.
- **Acceso a la app:** requiere iniciar sesión. Creá una cuenta de prueba para la revisión de Google y cargala en "Acceso a la app".
- **Pruebas:** las cuentas personales nuevas deben hacer una prueba cerrada con al menos 12 testers durante 14 días antes de publicar en producción.
