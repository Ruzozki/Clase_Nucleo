# Traspaso de contexto — Clase Núcleo

> Al empezar una sesión nueva, di: **"lee Documentacion/TRASPASO.md"**.
> Actualizado: 9 de noviembre de 2026.

## El proyecto

App de apoyo para una clase homebrew de D&D 5e hecha en **Godot 4.4.1**
(GL Compatibility). Repositorio: <https://github.com/Ruzozki/Clase_Nucleo>.
El personaje (el **Núcleo**) lanza **1d100** y se transforma en una de
**100 criaturas**.

## Cómo trabajamos

- El usuario es **principiante** y escribe él mismo todo el código.
- Claude **no edita archivos del proyecto**. En cada paso da:
  1. el código completo del paso (bloque `gdscript`, con el estilo del proyecto:
	 tipado, comentarios `##`, sangría con Tab),
  2. la explicación **línea por línea** en lenguaje sencillo,
  3. una comprobación para saber que funciona.
- Pasos pequeños; **bloques de 10 pasos o más**. No se avanza hasta que el paso
  funcione.
- Los bloques antiguos de `PLAN.md` (divisas, dados, bloques de 10 del d100,
  paso 3 del bloque 7) quedan **aparcados**. El foco es el sistema nuevo.

## Reglas del juego decididas

**Fases (evoluciones)**
- Cada criatura tiene **4 fases**, cada una con nombre, imagen y estadísticas
  propias. Las estadísticas de cada fase las rellena el usuario a mano para
  equilibrar.
- Cada fase pide un **nivel mínimo del Núcleo**, distinto en cada criatura.
  Ejemplo, Latígia: fase 1 → nivel 1, fase 2 → nivel 3, fase 3 → nivel 7,
  fase 4 → nivel 14.
- Tras cada **descanso largo** se tira un d100 nuevo y la forma aparece
  **siempre en fase 1**. Las fases superiores solo se alcanzan gastando
  **PT (Puntos de Transformación)**.
- Se pueden **saltar fases** (de 1 a 3) si hay nivel y PT suficientes.
  *Pendiente de confirmar:* el salto cuesta la **suma** de las fases
  intermedias (recomendado) o solo la fase destino.
- El sistema de **niveles del Núcleo** todavía no existe.

**Habilidades (poderes de la criatura)**
- Cada habilidad pertenece a **una sola criatura** y a **una fase**.
- Identificador: `NNN-F-OO` → criatura (001–100), fase (1–4), orden (01–99).
  Ejemplo: `001-2-03`. El id se **calcula** a partir de los campos, no se
  escribe a mano.
- Se guardan en archivos aparte: `Recursos/Habilidades/001/001-1-01.tres`.
- Al alcanzar una fase se conservan las habilidades anteriores y se desbloquean
  las suyas. Lo desbloqueado **se calcula** (fase actual ≥ fase de la
  habilidad), no hace falta guardarlo.
- Sin límite de habilidades equipadas: toda habilidad desbloqueada se puede usar.
- Costes: aún no se sabe si se pagan con PT o con Mutación; la habilidad tendrá
  ambos campos (`coste_transformacion`, `coste_mutacion`) a 0.

**Mutación**
- Se acumula **al usar habilidades** (`mutacion_al_usar` en cada habilidad) y
  **al transformarse**.

**Salvaciones y pericias**
- «Pericias» = las *skills* de D&D (Sigilo, Percepción…). Se llaman así para no
  confundirlas con `Habilidad` (los poderes).
- Cada **fase** marca en qué salvaciones y pericias es competente.
- Valor = modificador del atributo + bono de competencia (si es competente).
  El bono saldrá del nivel del Núcleo; mientras tanto, **+2 provisional**.
- En pantalla serán **botones** que tiran un d20 y muestran el resultado.
- Posible ampliación futura: pericia doble (*expertise*).

## Diseño de datos

| Pieza | Dónde vive | Contenido |
|---|---|---|
| `Criatura` | `Recursos/Criaturas/Criatura_NNN.tres` | número, nombre, tipo, dificultad y **4 fases dentro** |
| `Fase` | Dentro del `.tres` de su criatura | número, nombre, imagen, nivel requerido, coste PT, estadísticas, competencias |
| `Habilidad` | `Recursos/Habilidades/NNN/NNN-F-OO.tres` | criatura, fase, orden, id, costes, mutación al usar |
| Reglas D&D | `Scripts/Reglas_DnD.gd` (nuevo) | abreviaturas, modificador, bono de competencia, 18 pericias con su atributo |
| Progreso | `user://progreso.json` | nivel del Núcleo, PT, mutación, criatura y fase actuales |

La fase **no** necesita un campo de criatura porque vive dentro de ella. La app
encuentra «fase 2 de la criatura 005» buscando primero la criatura
(`buscar_criatura(5)`) y luego su fase 2 (`obtener_fase(2)`, paso A10).

## Hoja de ruta

### Bloque A — Fases (12 pasos)

| Paso | Qué | Estado |
|---|---|---|
| A1 | `Fase`: número, nombre, imagen | ✅ |
| A2 | `Fase`: nivel requerido y coste en PT | ✅ |
| A3 | `Fase`: grupo «Estadísticas» (CA, PG, velocidad) y subgrupo «Atributos» | ✅ |
| A4 | `Scripts/Reglas_DnD.gd` (`class_name ReglasDnD`): `ATRIBUTOS`, `BONO_COMPETENCIA_PROVISIONAL`, `modificador()`, `texto_modificador()`, `bono_competencia(nivel)` | ✅ |
| A5 | `ReglasDnD.PERICIAS` (Dictionary nombre → atributo), `atributo_de_pericia()`, `nombres_pericias()` | ✅ |
| A6 | `Fase`: grupo «Competencias», `salvaciones_competentes` (`@export_flags`) | ✅ |
| A7 | `Fase`: `pericias_competentes` (`@export_flags`, mismo orden que `PERICIAS`) | ✅ |
| A8 | `Fase`: `normalizar()`, `es_valida()`, `valor_atributo()`, `es_competente_salvacion()`, `es_competente_pericia()`, `valor_salvacion(atributo, bono)`, `valor_pericia(nombre, bono)` | ✅ |
| A9 | `Criatura`: `NUMERO_FASES = 4` y `@export var fases: Array[Fase]` | ✅ |
| A10 | `Criatura`: `obtener_fase(n)`, `problemas_fases()`; `normalizar()` limpia las fases; `cargar_criaturas()` avisa con `push_warning` | ✅ |
| A11 | Latígia: fases 1 y 2 creadas (faltan la 3 y la 4 → aviso amarillo esperado) | ✅ |
| A12 | `rellenar_estadisticas()` lee `obtener_fase(1)`; quitadas de `Criatura` las estadísticas antiguas (se queda `imagen`) | ✅ |

**Bloque A terminado.** Siguiente: Bloque B, paso B1.

### Bloque B — Catálogo de habilidades (≈8 pasos)
Campos criatura/fase/orden e id calculado; costes y mutación; carpeta
`Habilidades/NNN/`; cargador con comprobaciones (id duplicado, archivo ≠ id,
carpeta ≠ criatura, rangos); consulta «habilidades hasta la fase F»; retirar la
lista `habilidades` antigua de `Criatura`.

### Bloque C — Núcleo y evolución (≈8 pasos)
Estado del Núcleo (nivel, PT, mutación, criatura y fase actuales); fases
alcanzables; coste de un salto; evolucionar; descanso largo → fase 1; bono de
competencia según nivel; guardar y cargar `progreso.json`.

### Bloque D — Pantalla de transformación
- **Quitar el popup** `Ventana_Estadisticas`.
- `Panel_Imagen` en tres zonas: estadísticas abreviadas a la izquierda
  (CA, PG, VEL, FUE… con modificador y botón de salvación), imagen en el
  centro, las 18 pericias a la derecha como botones.
- Tirada de d20 + modificador al pulsar.
- Revisar aquí el tamaño de pantalla (ver abajo).

## Tamaño de pantalla

- Se queda en **1280×720 con Stretch `canvas_items`**: Godot ya amplía toda la
  interfaz al tamaño real de la ventana.
- Monitores del usuario: principal 1536×816 útiles (1920×1080 al 125 %),
  secundario 1920×1032.
- Si en el Bloque D falta espacio: lienzo 1920×1080, Mode **Maximized**, Aspect
  **expand**, un **Theme** en el nodo raíz para el tamaño de letra base, y
  ajustar `Columna_Izquierda` (280), `Panel_Habilidades` (340) e
  `Imagen_Criatura` (alto 200).

## Código ya escrito: `Recursos/Recursos_Fase.gd`

```gdscript
class_name Fase
extends Resource
## Una fase de evolución de una criatura.
##
## Cada criatura tiene 4 fases. Al tirar el d100 siempre aparece en la fase 1;
## las fases 2, 3 y 4 se alcanzan gastando PT si el Núcleo tiene nivel.


## Número de la fase, del 1 al 4.
@export_range(1, 4, 1) var numero: int = 1

## Nombre de esta evolución. Si está vacío, se usa el de la criatura.
@export var nombre: String = ""

## Imagen de esta evolución. Si está vacía, se usa la de la criatura.
@export var imagen: Texture2D

## Nivel mínimo del Núcleo para poder alcanzar esta fase.
@export_range(1, 20, 1) var nivel_requerido: int = 1

## Puntos de Transformación (PT) que cuesta evolucionar a esta fase.
## En la fase 1 debe ser 0, porque sale directamente con el d100.
@export_range(0, 999, 1) var coste_pt: int = 0

@export_group("Estadísticas")

## Clase de Armadura (CA) en esta fase.
@export_range(0, 99, 1) var ca: int = 10

## Puntos de Golpe (PG) máximos en esta fase.
@export_range(1, 9999, 1) var pg: int = 1

## Velocidad como texto libre, por ejemplo "9 m" o "9 m, volar 12 m".
@export var velocidad: String = "9 m"

@export_subgroup("Atributos")

## Fuerza (FUE).
@export_range(1, 30, 1) var fuerza: int = 10

## Destreza (DES).
@export_range(1, 30, 1) var destreza: int = 10

## Constitución (CON).
@export_range(1, 30, 1) var constitucion: int = 10

## Inteligencia (INT).
@export_range(1, 30, 1) var inteligencia: int = 10

## Sabiduría (SAB).
@export_range(1, 30, 1) var sabiduria: int = 10

## Carisma (CAR).
@export_range(1, 30, 1) var carisma: int = 10
```

## Datos útiles del código existente

- `Escenas/clase_nucleo.gd` (~1.480 líneas) controla toda la escena con rutas
  `@export_node_path`.
- `buscar_criatura(numero)` recorre la lista `criaturas`.
- `cargar_criaturas()` filtra por `.tres`; **fallará al exportar** porque los
  archivos pasan a ser `.tres.remap` (solo importa si se exporta la app).
- `Dados.MAXIMO_ACTUAL_D100 = 1` está así a propósito para probar Latígia.
- `Criatura_001.tres` (Latígia): CA 13, PG 24, 9 m, FUE 3, DES 15, CON 13,
  INT 8, SAB 16, CAR 10. Sin habilidades ni imagen.
- El proyecto trata los avisos como errores: declarar tipos a mano cuando el
  valor viene de un `Variant` (`var datos: Variant = ...`).
