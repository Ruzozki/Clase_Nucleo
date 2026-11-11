# Traspaso de contexto — Clase Núcleo

> Al empezar una sesión nueva, di: **"lee Documentacion/TRASPASO.md"**.
> Actualizado: 10 de noviembre de 2026.
> **Meta inmediata: versión jugable antes del 20 de noviembre de 2026**
> (primera sesión con el DM).

## El proyecto

App de apoyo para una clase homebrew de D&D 5e hecha en **Godot 4.4.1**
(GL Compatibility). Repositorio: <https://github.com/Ruzozki/Clase_Nucleo>.
El personaje (el **Núcleo**) paga PT para lanzar **1d100** y transformarse en
una de **100 criaturas**. Se quiere jugar como una partida normal de D&D.

## Cómo trabajamos

- El usuario es **principiante**, dispone de **pocas horas al día** y escribe
  él mismo todo el código.
- Claude **no edita archivos del proyecto**. En cada paso da:
  1. el código completo (bloque `gdscript`, estilo del proyecto: tipado,
	 comentarios `##`, sangría con Tab),
  2. la explicación **línea por línea** en lenguaje sencillo,
  3. una comprobación (código temporal en `_ready()` que luego se borra).
- Pasos pequeños. Para el plazo del 20, los bloques se **recortan a ~5 pasos**.
- Los números de equilibrio (porcentajes, turnos, costes) van en **datos
  editables**, no escritos dentro del código.
- El proyecto trata los avisos como errores: declarar tipos a mano cuando el
  valor viene de un `Variant`.

## Alcance para el 20 de noviembre

**Entra:** tirar el d100 (1 PT), ver la criatura con estadísticas, glosario de
habilidades y pasivas con tooltips, **botones de salvación y pericias con d20**,
PM con tramos y dado de mutación, mutaciones, modo combate con turnos,
sobrecalentamiento y reinicio, descansos corto y largo, y **guardar progreso**
(botón manual si falta tiempo).

**Sale (después del 20):** Hitos, base de datos de transformaciones, escala de
PT por nivel, fórmula de PG por descanso (provisional: mitad / todos, con
botones `+`/`-`), animaciones de mutación, fases superiores.

**Si falta tiempo, se recorta en este orden:** tooltips (ficha como texto fijo)
→ guardado automático (botón manual) → pericias (solo salvaciones).

## Las 10 criaturas de la sesión

Se limita el d100 a 1–10 (`Dados.UMBRAL_D100 = 10`). Cada criatura necesita:
estadísticas de fase 1, 2–3 habilidades (pasiva incluida) y **2 mutaciones**
(1 positiva y 1 negativa). Imagen y animación opcionales.

| Nº | Rol | Estado |
|---|---|---|
| 1 | Soporte | **Latígia** (ver abajo) |
| 2 | Daño | Sin diseñar |
| 3 | Tanque | Pasiva y 1 habilidad pensadas |
| 4 | Daño | Sin diseñar (la décima, colocada tras el primer tanque; confirmar) |
| 5 | Utilidad | Sin diseñar |
| 6 | Control | Sin diseñar |
| 7 | Tanque | Sin diseñar |
| 8 | Soporte | Sin diseñar |
| 9 | Daño | Sin diseñar |
| 10 | Caos | Sin diseñar |

Referencia provisional de equilibrio (nivel 1; Latígia: CA 13, PG 24):
tanque CA 15–17 / PG 32–40; daño CA 12–13 / PG 20–24; soporte CA 12–14 /
PG 22–26. Coste PM orientativo: tanque 1–3, daño 3–5, soporte 2–3,
utilidad 0–2, control 2–4.

### Latígia (nº 1, Soporte)
- **Adhesión Simbiótica (pasiva)**, `001-1-01`: pasiva de adherirse al aliado.
- **Adhesión Simbiótica (acción adicional)**, `001-1-02`: la usa para
  adherirse; ahí empieza su juego. Pasiva y habilidad comparten nombre.
- **Camisa de fuerza** (mutación **negativa**, 3 turnos): al inicio de cada
  turno del aliado adherido recibe 1d4 perforante (espinas). Recompensa: cada
  vez que recibe ese daño, el primer ataque de ese turno inflige 1d4
  perforante adicional (no se acumula; vale cualquier ataque).
- **Mutación positiva** (nombre por confirmar; propuesta "Abrazo de savia" o
  "Savia Donante"): al inicio de cada turno del aliado adherido recupera 1d4
  PG. Riesgo: Latígia queda expuesta, **mod CA −2** mientras dure. 3 turnos.

## Reglas decididas

### PT (Puntos de Transformación)
- Sirven para **tirar el d100** (**1 PT por transformación**) y, más adelante,
  para subir de fase. **Nunca** para pagar habilidades.
- El Núcleo empieza con **2 PT**. Descanso corto: recupera la mitad. Descanso
  largo: todos. Escala por nivel: **por definir** (referencia: Ki del Monje).
- La tirada tras un descanso largo es **opcional y gratis**.

### d100 de transformación
- Se tira un d100 de verdad; si el resultado supera el umbral
  (`Dados.UMBRAL_D100`, ahora 10), **se vuelve a tirar**. La animación muestra
  números de 1 a 100. Los Hitos del futuro harán subir el umbral.

### Habilidades y pasivas
- Cada una pertenece a **una criatura** y lleva una **fase** (de momento
  siempre 1). Las pasivas son habilidades con la bandera "Pasiva", en la misma
  lista.
- Id **calculado** `NNN-F-OO` (criatura, fase, orden). Archivos:
  `Recursos/Habilidades/001/001-1-01.tres`; el nombre del archivo debe ser su
  id y la carpeta la de su criatura.
- Campos de `Habilidad`: `criatura`, `fase`, `orden`, `tipos_accion`
  (banderas combinables: Acción, Acción adicional, Reacción, Pasiva),
  `coste_pm`, `alcance`, `duracion`, `tirada` (texto), `salvacion_atributo`
  y `salvacion_cd` (0 = CD del Núcleo, aún sin sistema), `nombre`,
  `descripcion`. Sin límite de usos ni recarga (se hablará con el DM).
- `coste_pm` es un número libre (0–25). Con 0 no acumula PM. **No hay regla
  automática por tipo**: una pasiva que necesita acción puede costar PM.
- En pantalla el botón muestra **nombre y coste PM**; al pasar el ratón sale
  una ficha con todos los datos (tooltip propio).

### PM (Puntos de Mutación)
- Usar una habilidad suma `coste_pm`. Tope **25**. Barra `Barra_PM`.
- Tramos (`EstadoNucleo.TRAMOS_RIESGO`, editable): 0–4 → 0 %, 5–9 → 5 %,
  10–14 → 15 %, 15–19 → 30 %, 20–24 → 50 %, 25 → 100 %.
- Tras usar una habilidad se tira el **dado de mutación** (otro d100,
  `Dados.tirar_dado_mutacion()`); muta si la tirada ≤ porcentaje.
- Solo acumula en estado **Transformado**. Al empezar la mutación los PM
  pasan a 0 y no suben mientras dure. Al transformarse de nuevo, vuelven a
  acumular. **Los descansos no reinician los PM.**

### Mutaciones
- Cada criatura tiene **2: 1 positiva y 1 negativa** (decisión para la sesión
  del 20; se ampliará). Al empezar la mutación se tira **1d2** para elegir.
- Una mutación (`Mutacion`): `nombre`, `tipo` (Positiva/Negativa), `riesgo`,
  `recompensa`, `imagen`, `duracion_turnos` (provisional 3) y modificadores
  de estadísticas (`mod_ca`, `mod_pg` y seis atributos).
- Las mutaciones podrán **cambiar pasivas, habilidades y estadísticas** según
  la criatura. Hoy se describe en texto; añadir/reemplazar habilidades de
  forma automática queda para después del 20.

### Estados del Núcleo
| Estado | Qué es | Cómo se sale |
|---|---|---|
| Núcleo | Forma base | d100 (1 PT) |
| Transformado | Criatura en fase 1 | Mutación, descanso corto o largo |
| Sobrecalentamiento | Es la mutación; 3 turnos o hasta descanso corto | Pasa a Reinicio |
| Reinicio | Vuelve a ser Núcleo, no puede transformarse | Fin del tiempo |

- Descanso corto con la criatura mutada → Reinicio. Duración del Reinicio:
  en combate pocos turnos (**por definir**, provisional 2); fuera de combate
  **por definir** (provisional: hasta el siguiente descanso).

### Combate
- Botón **Iniciar/Terminar combate**. Dentro: contador de turnos (tecla `.` y
  botón). La mutación y el Reinicio expiran por turnos.
- Si el combate termina con la criatura sobrecalentada, sigue así hasta
  **Descanso**.

### Descansos
- **Corto:** si estaba mutada, pasa a Reinicio; si no, vuelve a fase 1. PT:
  mitad. PG de la criatura: se recuperan (fórmula **por definir**).
- **Largo:** d100 opcional y gratis. Sin d100, vuelve a ser Núcleo. PT:
  todos. PG: se recuperan.

### Salvaciones y pericias
- Botones que tiran d20 + modificador + bono de competencia si la fase es
  competente (`Fase.valor_salvacion()` / `valor_pericia()`). Bono provisional
  **+2** hasta que exista el nivel del Núcleo.

### Hitos y base de datos de transformaciones (después del 20)
- Cada criatura obtenida se registra una sola vez. Los **Hitos** desbloquean
  bloques de 10 (nivel 2 → criaturas 1–10; luego, registrar las 10 del bloque
  anterior). El umbral del d100 saldrá de ahí.

## Diseño de datos

| Pieza | Dónde vive | Contenido |
|---|---|---|
| `Criatura` | `Recursos/Criaturas/Criatura_NNN.tres` | número, nombre, tipo, dificultad, imagen, 4 `fases`, 2 `mutaciones`; `obtener_fase`, `obtener_mutacion`, `problemas_fases`, `problemas_mutaciones` |
| `Fase` | Dentro del `.tres` de su criatura | número, nombre, imagen, nivel requerido, coste PT, estadísticas, competencias |
| `Habilidad` | `Recursos/Habilidades/NNN/NNN-F-OO.tres` | ver arriba; `obtener_id`, `tiene_tipo`, `es_pasiva`, `texto_tipos_accion`, `acumula_pm`, `texto_coste`, `tiene_salvacion`, `texto_salvacion` |
| `Mutacion` | `Recursos/Recursos_Mutacion.gd`, dentro de su criatura | ver arriba; `es_positiva`, `texto_modificadores` |
| `EstadoNucleo` | `Scripts/Estado_Nucleo.gd` (`RefCounted`) | `estado`, `pt`, `pm`, `criatura_actual`, `mutacion_actual`, `turnos_restantes`; `sumar_pm`, `probabilidad_mutacion`, `muta_con_tirada`, `transformar_en`, `empezar_mutacion` |
| `Dados` | `Scripts/Dados.gd` | `tirar`, `tirar_d100` (con `UMBRAL_D100`), `tirar_dado_mutacion` |
| Reglas D&D | `Scripts/Reglas_DnD.gd` | atributos, modificador, bono de competencia, 18 pericias |
| Progreso | `user://progreso.json` (pendiente) | nivel, PT, PM, estado, criatura actual |

En `clase_nucleo.gd`: `nucleo: EstadoNucleo`, `catalogo_habilidades`,
`cargar_habilidades()` (comprueba id, archivo y carpeta), `habilidades_de(
numero_criatura, fase_maxima)` y `rellenar_puntos()` (conecta `Barra_PM`,
`Barra_PT` y `valor_pt`). La tirada del d100 llama a `nucleo.transformar_en()`
pero **todavía no cobra el PT**.

## Hoja de ruta

| Bloque | Tema | Estado |
|---|---|---|
| A (antiguo) | Fases: `Fase` y `Criatura` con 4 fases | ✅ |
| 1 | Habilidades (campos, id, tipos, coste PM, alcance, duración, tirada, salvación, cargador, glosario de Latígia, `habilidades_de`) | ✅ |
| 2 | Mutaciones (`Mutacion`, imagen, duración, modificadores, 2 por criatura, sorteo d2, Latígia) | ✅ |
| 3 | Estados del Núcleo y PM | ✅ pasos 1–5. **Paso 6 pendiente**: botón de habilidad → suma PM → dado de mutación → mutar (d2) |
| 4 | Modo combate (5 pasos) | Pendiente |
| 5 | Descansos (5 pasos) | Pendiente |
| 6 | Botones de salvación y pericias con d20 (5 pasos) | Pendiente |
| 7 | Tooltips y guardar progreso (5 pasos) | Pendiente |
| 8 | Cobrar 1 PT en el d100 | Pendiente (pequeño) |
| Después del 20 | Núcleo y PT por nivel, base de datos, Hitos, fases superiores, mutaciones que cambian habilidades | Aparcado |

## Calendario hacia el 20 de noviembre

| Días | Código | Contenido |
|---|---|---|
| 10–11 nov | Cerrar Bloque 3 (paso 6) | Criaturas 2–4 |
| 12–13 nov | Modo combate | Criaturas 5–7 |
| 14–15 nov | Descansos | Criaturas 8–10 |
| 16 nov | Salvaciones y pericias | Retoques de criaturas |
| 17 nov | Tooltips y guardar | — |
| 18–19 nov | Pruebas y equilibrio | Retoques |
| 20 nov | Margen, sin programar | — |

## Datos útiles del código existente

- `Escenas/clase_nucleo.gd` controla toda la escena con rutas
  `@export_node_path`. Ya existen `Barra_PM`, `Barra_PT` y `valor_pt`.
- `cargar_criaturas()` filtra por `.tres`; fallará al exportar (`.tres.remap`).
- Avisos amarillos esperados: «Criatura 1: la posición 2/3 está vacía»
  (fases 3 y 4 sin crear).
- La etiqueta «duplicada» del d100 se activa a menudo con solo 10 números.

## Pendientes por decidir

- Nombre de la mutación positiva de Latígia.
- Duración del Reinicio (en combate y fuera).
- Cómo escalan los PT por nivel y la fórmula de PG por descanso.
- Si la décima criatura (daño) va en el nº 4 u otro.iant = ...`).
