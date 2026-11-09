# Plan del proyecto — Clase Núcleo

## Qué es este proyecto

Aplicación de apoyo para una **clase homebrew de Dungeons & Dragons**: un
constructo que, al lanzar **1d100**, se transforma en una de **100 criaturas**,
cada una con sus propias estadísticas y habilidades.

La aplicación crecerá por **bloques de 5 pasos**. Cada paso incluye una
explicación corta, el código y una forma de comprobarlo. No se pasa al
siguiente paso hasta que el anterior funcione.

## Cómo trabajamos

- **1 bloque = 5 pasos pequeños.**
- En cada paso: objetivo → explicación → código → comprobación.
- Al terminar un paso se marca la casilla aquí.
- Si algo falla, se lee el error, se entiende y se corrige. Los errores son
  parte del aprendizaje.
- El código nuevo lleva comentarios y documentación con `##` (Godot los
  muestra en el Inspector al pasar el ratón).

## Documentación del código

La explicación bloque por bloque de cada script está en
[`CODIGO.md`](./CODIGO.md).

## Hoja de ruta

| Bloque | Tema | Estado |
|--------|------|--------|
| 1 | Modelo de datos y creación de objetos | Completado ✅ |
| 2 | Categorías, búsqueda y filtros | Completado ✅ |
| 3 | Editar, eliminar y persistencia (JSON) | Completado ✅ |
| 4 | Divisas y cambio de moneda | En pausa ⏸ (pasos 3-5) |
| 5 | Dados y tiradas | En pausa ⏸ (pasos 4-5) |
| 6 | Transformaciones: bloques de 10 | En pausa ⏸ (pasos 2-5) |
| 7 | Criaturas: modelo y base de datos | Casi completo (falta paso 3) |
| 8 | Habilidades interactivas y puntos | Pendiente |
| 9 | UI de Transformaciones compacta | Casi completo (falta paso 5) |

---

# Bloque 1 — Modelo de datos y creación de objetos ✅

**Meta:** poder crear un objeto desde la ventana "Nuevo Objeto", guardarlo en
memoria y verlo aparecer en la lista y en el panel de detalle.

- [x] Paso 1 — Crear la clase `Objeto` ✅
- [x] Paso 2 — Asignar las rutas del Inspector y arreglar la ventana ✅
- [x] Paso 3 — Conectar el botón Guardar y validar ✅
- [x] Paso 4 — Construir y almacenar el objeto ✅
- [x] Paso 5 — Mostrar en la lista y en el detalle ✅

### Paso 1. Crear la clase `Objeto`

- **Objetivo:** tener un molde de datos para representar cualquier objeto.
- **Explicación:** en Godot, `Resource` es un contenedor de datos reutilizable
  (no es un nodo y no se dibuja en pantalla). Con `class_name Objeto` podremos
  escribir `var mi_objeto: Objeto` en cualquier script del proyecto.
- **Archivo:** `Recursos/Recursos_Objeto.gd`
- **Propiedades:** `nombre`, `categoria`, `cantidad`, `costo`, `descripcion`,
  más la constante `CATEGORIAS`.
- **Comprobación:** el script no da errores y `Objeto` aparece en el buscador
  de clases de Godot (Ctrl+Shift+O o el botón "+" → Create New → Resource).

### Paso 2. Asignar las rutas del Inspector

- **Objetivo:** que `cargar_referencias()` encuentre todos los nodos.
- **Explicación:** el script pide las referencias mediante `@export_node_path`.
  Esas rutas están vacías en la escena, por eso aparecen `push_error` al
  ejecutar. Se asignan en la escena (Inspector del nodo raíz
  `Clase_Nucleo`), que es exactamente lo mismo que guardarlas en el `.tscn`.
- **Extra:** el `MarginContainer` dentro de `Ventana_Objeto` debe ocupar todo
  el `Window` (anclajes a pantalla completa); si no, el formulario queda
  pegado arriba a la izquierda.
- **Comprobación:** al ejecutar (F5) no sale ningún error en la consola y el
  botón "Nuevo Objeto" abre la ventana centrada.

### Paso 3. Conectar el botón Guardar y validar

- **Objetivo:** que "Guardar Objeto" haga algo y no se guarden objetos vacíos.
- **Explicación:** las señales se conectan con `pressed.connect(...)`. Hay que
  comprobar que el nombre no esté vacío y avisar al usuario si falta.
- **Comprobación:** con el nombre vacío se muestra un aviso; con texto válido
  los datos aparecen en Output (la ventana se cerrará en el Paso 4).

### Paso 4. Construir y almacenar el objeto

- **Objetivo:** convertir los campos del formulario en un `Objeto` real.
- **Explicación:** `Objeto.new()` crea una instancia; después se rellenan sus
  propiedades. La lista `var objetos: Array[Objeto] = []` guarda todos los
  objetos en memoria mientras la app está abierta.
- **Comprobación:** al guardar, la ventana se cierra y el formulario queda
  limpio para el siguiente objeto.

### Paso 5. Mostrar en la lista y en el detalle

- **Objetivo:** ver los objetos guardados y sus datos.
- **Explicación:** `ItemList` muestra textos simples; para saber a qué objeto
  corresponde cada fila se usa `set_item_metadata`. Al seleccionar una fila
  (`item_selected`), se actualizan las etiquetas del panel de detalle.
- **Comprobación:** se crean dos objetos, aparecen en la lista y al hacer clic
  en cada uno se ven sus datos en el panel derecho.

---

# Bloque 2 — Categorías, búsqueda y filtros ✅

**Meta:** clasificar los objetos por categoría y poder encontrarlos rápido en
la lista.

- [x] Paso 1 — Definir las categorías en el modelo ✅
- [x] Paso 2 — Elegir categoría al crear un objeto ✅
- [x] Paso 3 — Cargar el filtro de categorías ✅
- [x] Paso 4 — Búsqueda en vivo por nombre y descripción ✅
- [x] Paso 5 — Combinar búsqueda + filtro y estado vacío ✅

### Paso 1. Definir las categorías en el modelo

- **Objetivo:** tener una única lista de categorías válidas.
- **Explicación:** una constante `CATEGORIAS` en `Objeto.gd` evita repetir
  textos y asegura que el formulario y el filtro usen las mismas.
- **Comprobación:** `Objeto.CATEGORIAS` existe y contiene 6 categorías.

### Paso 2. Elegir categoría al crear un objeto

- **Objetivo:** que el usuario elija la categoría en la ventana "Nuevo Objeto".
- **Explicación:** se añade un `OptionButton` al formulario, se rellena con
  `Objeto.CATEGORIAS` y su valor se guarda en `nuevo_objeto.categoria`.
- **Comprobación:** al crear un objeto con otra categoría, el detalle la muestra.

### Paso 3. Cargar el filtro de categorías

- **Objetivo:** poblar el desplegable "Categoría" de la pantalla de objetos.
- **Explicación:** el `OptionButton` del filtro se llena con "Todas" más
  `Objeto.CATEGORIAS`.
- **Comprobación:** el desplegable muestra "Todas" y las 6 categorías.

### Paso 4. Búsqueda en vivo

- **Objetivo:** filtrar la lista mientras se escribe.
- **Explicación:** la señal `text_changed` del buscador vuelve a llamar a
  `actualizar_lista_objetos()`, que compara el texto con nombre y descripción
  (sin distinguir mayúsculas).
- **Comprobación:** al escribir, la lista se reduce al instante.

### Paso 5. Combinar búsqueda + filtro y estado vacío

- **Objetivo:** que búsqueda y categoría funcionen a la vez y avisar si no hay
  resultados.
- **Explicación:** `actualizar_lista_objetos()` aplica las dos condiciones; si
  no queda nada, añade una fila desactivada "Sin resultados".
- **Comprobación:** con una búsqueda y una categoría que no coinciden, aparece
  "Sin resultados" y el detalle queda vacío.

### Extra. Campo "Costo"

Fuera del plan original, añadido a petición.

- **Objetivo:** guardar cuánto cuesta cada objeto.
- **Explicación:** `Costo` **no** es una categoría: es un dato numérico. Se
  añadió como `costo: int` en el molde, un `SpinBox` en el formulario y una
  etiqueta en el detalle.
- **Comprobación:** al crear un objeto con costo 50, el detalle muestra
  `Costo: 50 oro`.

> Nota: si algún día se implementa el Bloque 4 (divisas), `costo` debería pasar
> a guardarse en **unidades de referencia** en vez de "oro", para que un mismo
> objeto valga lo mismo en todas las ciudades.

---

# Bloque 3 — Editar, eliminar y persistencia ✅

**Meta:** poder modificar y borrar objetos, y que el inventario sobreviva al
cerrar la aplicación.

- [x] Paso 1 — Seleccionar un objeto y activar los botones de acción ✅
- [x] Paso 2 — Editar: abrir el formulario con los datos y guardar los cambios ✅
- [x] Paso 3 — Eliminar con confirmación ✅
- [x] Paso 4 — Guardar el inventario en un archivo JSON ✅
- [x] Paso 5 — Cargar el inventario al arrancar ✅

### Paso 1. Seleccionar un objeto y activar los botones de acción

- **Objetivo:** recordar qué objeto está seleccionado y habilitar "Editar" y
  "Eliminar" solo cuando haya uno.
- **Explicación:** se guarda la referencia del `Objeto` (no el índice de la
  fila, porque la lista se filtra y los índices cambian). Los botones empiezan
  desactivados con `disabled = true`.
- **Comprobación:** al abrir la app los dos botones están apagados; al
  seleccionar una fila se encienden; al filtrar y perder la selección se
  apagan otra vez.
- **Extra:** el botón Eliminar tenía un salto de línea invisible en su texto
  (`"Eliminar\n"`); se quitó para que el texto quede centrado.

### Paso 2. Editar: abrir el formulario con los datos y guardar los cambios

- **Objetivo:** reutilizar la ventana "Nuevo Objeto" para modificar uno
  existente.
- **Explicación:** una variable `objeto_en_edicion` distingue crear de editar.
  Si es `null`, "Guardar" añade; si no, modifica el objeto existente. El título
  de la ventana cambia para que el usuario sepa en qué modo está.
- **Funciones nuevas:** `cargar_formulario_objeto()`,
  `seleccionar_categoria()` y `aplicar_formulario_a_objeto()`.
- **Comprobación:** al editar un objeto, el formulario aparece relleno; al
  guardar, la fila cambia de datos y no se duplica.
- **Error de la sesión:** al reemplazar `_on_boton_guardar_objeto_pressed()`
  quedó pegado el cuerpo antiguo dentro de `_on_boton_editar_objeto_pressed()`,
  que usaba la variable local `nombre_limpio` → *"Identifier not declared in
  the current scope"*. Lección: una variable local solo existe en su función.

### Paso 3. Eliminar con confirmación

- **Objetivo:** borrar un objeto sin riesgo de pulsar por error.
- **Explicación:** se usa un `ConfirmationDialog` (parecido al
  `AcceptDialog`), que tiene botones "Aceptar" y "Cancelar". Se crea por código
  en `crear_dialogo_confirmacion()` y se guarda la "víctima" en
  `objeto_a_eliminar`; el borrado real ocurre en la señal `confirmed`.
- **Comprobación:** al cancelar no pasa nada; al aceptar, el objeto desaparece
  de la lista y el detalle se limpia.

### Paso 4. Guardar el inventario en un archivo JSON

- **Objetivo:** escribir los objetos en `user://inventario.json`.
- **Explicación:** cada `Objeto` se convierte en un `Dictionary` con sus
  campos; la lista de diccionarios se serializa con `JSON.stringify`.
  Se usa `user://`, que en Windows vive en
  `%APPDATA%\Godot\app_userdata\Clase_Núcleo\inventario.json`.
- **Cuándo se guarda:** después de crear, editar y eliminar. Así no depende de
  que la app se cierre correctamente.
- **Comprobación:** tras guardar, el archivo existe y contiene texto legible.

### Paso 5. Cargar el inventario al arrancar

- **Objetivo:** leer el JSON en `_ready()` y reconstruir los objetos.
- **Explicación:** `JSON.parse_string` devuelve un `Variant`; se comprueba el
  tipo, se recorre la lista y se crea un `Objeto` por cada diccionario. Si el
  archivo no existe o está corrupto, se empieza con la lista vacía.
- **Comprobación:** se crean objetos, se cierra el juego, se vuelve a abrir y
  siguen ahí.
- **Error de la sesión:** `var datos := JSON.parse_string(texto)` no compila
  porque el proyecto trata los avisos como errores (*"inferred from a Variant
  value"*). Solución: `var datos: Variant = ...`, declarando el tipo a mano.

---

# Bloque 4 — Divisas y cambio de moneda ⏸ (en pausa)

> **Estado:** pasos 1 y 2 completados. Los pasos 3, 4 y 5 quedan pendientes
> para retomarlos más adelante.

**Meta:** definir las monedas del mundo, convertir entre ellas y mostrarlas con
su valor exacto sin perder precisión.

- [x] Paso 1 — Tabla de valores en granos y pestaña "Monedas" ✅
- [x] Paso 2 — Conversión entre monedas ✅
- [ ] Paso 3 — Pantalla del cambista (origen, destino, cantidad)
- [ ] Paso 4 — Comisión del cambista
- [ ] Paso 5 — Integrar el costo de los objetos con las divisas

### Paso 1. Tabla de valores en granos y pestaña "Monedas"

- **Objetivo:** guardar los valores de las monedas con exactitud y verlos en
  pantalla tal como se definieron.
- **Archivo:** `Scripts/Divisas.gd` (`class_name Divisas`).
- **Explicación:** los valores se guardan en **granos** (enteros), donde
  `1 grano = 0,01 de cobre de Orelha`. Así no hay errores de redondeo.
  Al mostrar, `granos_a_texto()` los convierte a texto con coma decimal y punto
  de miles (`100000 → "1.000,00"`).
- **Tabla (en granos):**

| Moneda | Cobre | Plata | Oro | Platino |
|---|---|---|---|---|
| Orelha | 100 | 1.000 | 10.000 | 100.000 |
| Turquesa | 10 | 100 | 1.000 | 10.000 |
| Rublyof | 1 | 10 | 100 | 1.000 |
| Lirios | 0 | 1 | 10 | 100 |

- **Escena:** nueva pestaña **Monedas** con un `GridContainer`
  (`Tabla_Monedas`) que el script rellena desde `Divisas`, sin repetir datos.
- **Comprobación:** la pestaña muestra los valores con coma (`1,00`, `10,00`,
  `100,00`, `1.000,00`) y el cobre de Lirios en `0,00`.
- **Caso especial:** el cobre de Lirios vale 0; no se podrá convertir **a** él.

### Paso 2. Conversión entre monedas

- **Objetivo:** pasar una cantidad de una moneda/denominación a otra.
- **Explicación:** toda conversión pasa por una unidad común, los **granos**:

```text
cantidad origen × valor_origen  →  GRANOS  →  ÷ valor_destino  →  cantidad destino
```

- **Funciones nuevas:** `cantidad_a_granos()`, `convertir()`,
  `repartir_en_denominaciones()`, `texto_reparto()` y `existe_denominacion()`.
- **Qué devuelve `convertir()`:** un `Dictionary` con `valido`, `granos`,
  `cantidad`, `resto_granos`, `reparto` y `sobrante_granos`.
- **Casos especiales:**
  - Destino **cobre de Lirios** (vale 0) → `valido: false`.
  - Origen **cobre de Lirios** (vale 0) → conversión válida que da 0.
  - Resto que no cabe en la moneda destino (ej. 70 granos a Orelha, cuya
	moneda menor vale 100) → se devuelve en `sobrante_granos`.
- **Comprobación real (script temporal):**

| Conversión | Resultado |
|---|---|
| 1 oro Orelha → platino Rublyof | 10 platinos (10.000 granos) |
| 15 oros Orelha → plata Rublyof | 15.000 platas = 150 platinos |
| 7 cobres Turquesa → oro Orelha | 0 oros, resto 70, sobrante 70 |
| 5 cobres Lirios → oro Orelha | válido, 0 granos |
| 5 cobres Orelha → cobre Lirios | **no convertible** |
| 2340 granos repartidos en Turquesa | 2 oros, 3 platas y 4 cobres |
| 2340 granos repartidos en Lirios | 23 platinos y 4 oros |

### Paso 3. Pantalla del cambista

- **Objetivo:** elegir moneda y denominación de origen y destino, escribir una
  cantidad y ver el resultado.
- **Explicación:** dos `OptionButton` + un `SpinBox` + etiquetas de resultado.
- **Comprobación:** el resultado coincide con el cálculo a mano.

### Paso 4. Comisión del cambista

- **Objetivo:** cobrar un porcentaje al cambiar moneda.
- **Explicación:** se calcula con enteros sobre los granos y se redondea a favor
  del cambista (o del cliente, según se decida).
- **Comprobación:** cambiar 100,00 con 5% de comisión devuelve 95,00.

### Paso 5. Integrar el costo de los objetos con las divisas

- **Objetivo:** que `costo` deje de ser "oro genérico" y tenga moneda.
- **Explicación:** añadir `moneda` y `denominacion` al `Objeto`, migrar el JSON
  existente y mostrar el costo con `Divisas.valor_en_texto()`.
- **Comprobación:** un objeto de `50,00` se ve igual tras cerrar y abrir.

---

# Bloque 5 — Dados y tiradas ⏸ (en pausa)

**Meta:** tirar los dados de D&D 5e desde la app, guardar la última tirada del
d100 y mantener un registro de las últimas 5 tiradas.

- [x] Paso 1 — Lógica de tirada (`Scripts/Dados.gd`) ✅
- [x] Paso 2 — Guardar la última tirada y el historial de 5 ✅
- [x] Paso 3 — Pestaña Transformaciones con el d100 especial ✅
- [ ] Paso 4 — Pestaña "Dados" con el resto (d4, d6, d8, d10, d12, d20)
- [ ] Paso 5 — Preparar el d100 como dado de transformación

### Decisiones cerradas

- **Solo el d100 especial se guarda** (última tirada + historial de 5) en JSON.
  El historial alimentará la futura mecánica de **"Tirada duplicada"**.
- **El historial no se muestra**: se guarda internamente para detectar
  duplicados en las últimas 4 tiradas, incluso al reabrir la app.
- **Los demás dados no se guardan**: solo se muestran en un registro de la
  sesión mientras la app esté abierta.
- El **d100 especial vive en la pestaña Transformaciones**, porque es donde se
  usará al sacar una nueva transformación.
- Los demás dados van en una **pestaña nueva "Dados"**.

### Paso 1. Lógica de tirada

- **Objetivo:** tener funciones puras para tirar cualquier dado.
- **Archivo:** `Scripts/Dados.gd` (`class_name Dados`).
- **Explicación:** `randi_range(1, caras)` devuelve un entero entre 1 y `caras`
  (ambos incluidos). El proyecto ya siembra el generador aleatorio al arrancar,
  así que no hace falta llamar a `randomize()`.
- **Contenido:**
  - `DADOS_ESTANDAR = [4, 6, 8, 10, 12, 20]`.
  - `DADO_ESPECIAL = 100`.
  - `MAX_HISTORIAL = 5`.
  - `tirar(caras)`, `tirar_d100()`, `agregar_al_historial()` y
	`texto_tirada()`.
- **Comprobación real:** 10.000 tiradas de cada dado dan todos los valores
  posibles (d4 → 4 distintos, d20 → 20, d100 → 100) y nunca salen del rango.
  El historial se recorta solo a 5 y el más reciente queda primero:
  `[42] → [7, 42] → ... → [88, 55, 3, 91, 7]`.

### Paso 2. Guardar la última tirada y el historial de 5

- **Objetivo:** que el d100 especial sobreviva al cierre de la app.
- **Archivo:** `user://d100.json` → en Windows,
  `%APPDATA%\Godot\app_userdata\Clase_Núcleo\d100.json`.
- **Formato:**

```json
{
	"ultima": 88,
	"historial": [88, 55, 3, 91, 7]
}
```

- **Funciones nuevas:** `registrar_tirada_d100()`, `guardar_d100()` y
  `cargar_d100()`. `cargar_d100()` se llama en `_ready()`.
- **Validación al cargar:**
  - `ultima` debe ser un número entre 1 y 100.
  - El historial se recorta a 5 y descarta valores fuera de rango o que no
	sean números.
  - Si falta `ultima` pero hay historial, se usa la tirada más reciente.
  - Si el archivo no existe o está corrupto, arranca con `0` y `[]`.
- **Detalle técnico:** se usa `JSON.new().parse()` en vez de
  `JSON.parse_string()`. `parse_string()` imprime un `ERROR` en consola cuando
  el texto está corrupto; `parse()` devuelve un código (`OK` o error) y deja
  los datos en `json.data`.
- **Comprobación real:**

| Caso | Resultado |
|---|---|
| Sin archivo | `ultima=0`, `historial=[]` |
| 6 tiradas (42, 7, 91, 3, 55, 88) | `ultima=88`, `[88, 55, 3, 91, 7]` |
| Recargar desde JSON | mismos datos |
| JSON corrupto | `ultima=0`, `historial=[]`, sin error en consola |
| Datos fuera de rango | filtra y conserva los 5 válidos: `[7, 88, 12, 13, 14]` |

### Paso 3. Pestaña Transformaciones rediseñada

- **Objetivo:** tirar el d100 y ver la criatura asociada, sin mostrar el
  historial en pantalla.
- **Escena:** la pestaña Transformaciones pasa a tener:
  - `Fila_Superior`, dos paneles lado a lado:
	- `Panel_D100` (230 px de ancho): `Resultado_D100` (64 px),
	  `Boton_Tirar_D100` y `Mensaje_Duplicada`.
	- `Panel_Imagen` (ocupa el resto): `Etiqueta_Criatura`
	  ("Criatura nº X") y `Imagen_Criatura` (`TextureRect`).
  - `Panel_Estadisticas`: `Grid_Estadisticas` de 8 columnas (4 pares
	etiqueta/valor por fila) con nombre, tipo, dificultad, CA, PG, velocidad y
	los seis atributos.
- **Historial oculto:** se eliminan de la pantalla `Ultima_Tirada_D100` e
  `Historial_D100`. El historial se sigue guardando en `d100.json` porque es
  lo que permite detectar duplicados al reabrir la app.
- **Script:** rutas nuevas `ruta_resultado_d100`, `ruta_boton_tirar_d100`,
  `ruta_mensaje_duplicada` y `ruta_etiqueta_criatura`.
- **Duplicado:** `Dados.es_duplicada(historial, resultado, 4)` compara la
  tirada nueva con las **4 anteriores** antes de registrarla.
- **Flujo al pulsar "Tirar d100":**
  1. `Dados.tirar_d100()`.
  2. Se comprueba `es_duplicada()` con el historial **antiguo**.
  3. `registrar_tirada_d100()` actualiza la última tirada y el historial, y
	 guarda el JSON.
  4. `actualizar_panel_d100()` repinta resultado, criatura y oculta el aviso.
  5. Se muestra `Mensaje_Duplicada` si la tirada repetía.
- **Placeholders:** `Imagen_Criatura`, `Etiqueta_Criatura` y las estadísticas
  son texto/vacío de momento; se conectarán a las criaturas en el Bloque 7.
- **Comprobación real (escena instanciada en headless, semilla fija):**

| Tirada | Valor | Duplicada | Esperada |
|---|---|---|---|
| 1 | 22 | no | no |
| 2 | 86 | no | no |
| 3 | 13 | no | no |
| 4 | 7 | no | no |
| 5 | 2 | no | no |
| 6 | 2 | **sí** | sí |

- Al reabrir la app, el resultado y el historial cargan del JSON y el aviso
  empieza oculto. `d100.json` se crea tras la primera tirada.
- **Encaje en pantalla:** con la ventana de 1280×720, el contenido ocupa
  exactamente el alto disponible y `Fila_Superior` crece si la ventana se
  agranda. Se cambió la rejilla de 4 a 8 columnas porque con 4 el mínimo del
  panel de estadísticas desbordaba la ventana por 13 px.

---

# Bloque 6 — Transformaciones: bloques de 10 ⏸ (en pausa)

**Meta:** sacar transformaciones del 1 al 100 desbloqueando bloques de 10
(1–10, 11–20, …). Mientras se prueba la primera ficha de personaje, el d100
solo puede dar números del primer bloque.

- [x] Paso 1 — Limitar el d100 al bloque actual (1–10) ✅
- [ ] Paso 2 — Reiniciar el d100 desde la pantalla
- [ ] Paso 3 — Mostrar el bloque actual en pantalla
- [ ] Paso 4 — Guardar el bloque desbloqueado en JSON
- [ ] Paso 5 — Subir al siguiente bloque (11–20, 21–30…)

### Paso 1. Limitar el d100 al bloque actual

- **Objetivo:** que el d100 solo saque números del bloque desbloqueado.
  De momento, el primero: **1–10**.
- **Archivo:** `Scripts/Dados.gd`.
- **Explicación:** `DADO_ESPECIAL` sigue valiendo `100` porque es el tamaño
  real del dado y se usa para validar el JSON. El límite de juego es otro:
  `MAXIMO_ACTUAL_D100 = 10`. `tirar_d100()` usa ese máximo y la animación de
  la escena también, para que los números que giran estén en el mismo rango.
- **Para desbloquear el siguiente bloque** (temporalmente): cambiar
  `MAXIMO_ACTUAL_D100` a `20`. En el Paso 5 eso será automático y persistente.
- **Valor actual: `1`.** Mientras se prueba la criatura 001 con Latígia, el
  d100 siempre da `1`. Con ese valor la animación muestra `1` en todos los
  fotogramas (no gira), y «Tirada Duplicada» aparece en todas las tiradas
  después de la primera. Es lo esperado en esta prueba.
- **Comprobación real:**
  - 10.000 tiradas: mínimo `1`, máximo `10`, los 10 valores aparecen.
  - 3 tiradas desde la escena: `1`, `4`, `6`; el historial se llena en orden.
  - Arranque normal: sin errores.

---

# Bloque 7 — Criaturas: modelo y base de datos

**Meta:** representar las criaturas en las que se transforma el personaje y
guardar sus estadísticas base en una base de datos. Todavía **sin** sistema de
puntos, mutaciones, costes de habilidades ni fases.

- [x] Paso 1 — Clase `Criatura` con sus estadísticas y habilidades ✅
- [x] Paso 2 — Cargar automáticamente los `.tres` de `Recursos/Criaturas/` ✅
- [ ] Paso 3 — Índice por número (1–100) y detección de repetidos
- [x] Paso 4 — Buscar la criatura de una tirada del d100 ✅
- [x] Paso 5 — Mostrar sus datos en el panel de estadísticas ✅

### Paso 1. Clase Criatura

- **Objetivo:** tener un molde de datos para cada forma o transformación.
- **Archivo:** `Recursos/Recursos_Criatura.gd` (`class_name Criatura`).
- **Explicación:** igual que `Objeto`, es un `Resource`: solo datos, no un
  nodo. El **número del d100 (1–100)** identifica a la criatura.
- **Base de datos:** una carpeta de archivos `.tres`, uno por criatura, en
  `Recursos/Criaturas/`. Se crean desde el editor y se rellenan en el
  Inspector (ver `Documentacion/CRIATURAS.md`).
- **Campos:** `numero`, `nombre`, `tipo`, `dificultad`, `ca`, `pg`, `velocidad`,
  `imagen`, `fuerza`, `destreza`, `constitucion`, `inteligencia`, `sabiduria`,
  `carisma`, `habilidades`.
- **Tipos:** constante `TIPOS` con los 14 tipos de D&D 5e como referencia. El
  campo `tipo` es texto libre y admite valores propios (`"Planta_Insecto"`).
- **Dificultad:** escala homebrew de uso, de 1 a 5 (`Muy fácil`, `Fácil`,
  `Normal`, `Difícil`, `Muy difícil`). Sustituye al CR de D&D.
- **Habilidades:** lista de recursos `Habilidad`
  (`Recursos/Recursos_Habilidad.gd`), cada uno con `nombre` y `descripcion`.
  Cada criatura tiene las suyas, guardadas dentro de su `.tres`. Todavía no
  tienen coste ni son interactivas (Bloque 8).
- **Funciones:**
  - `normalizar()`: limpia textos, pone valores por defecto y limita los
	números a sus rangos (número 1–100, dificultad 1–5, atributos 1–30,
	CA 0–99, PG 1–9999).
  - `es_valida()`: número en rango y nombre no vacío.
  - `nombre_dificultad()`: devuelve `"Normal"` para `dificultad = 3`.
  - `texto_resumen()`: `"Nº 12 · Lobo · Bestia (Dif. 2/5 · Fácil)"`.
  - `normalizar()` también limpia el nombre y la descripción de cada
	habilidad de la lista.
- **Comprobación real:**

| Caso | Resultado |
|---|---|
| Criatura por defecto | `Nº 1 · Sin nombre · Bestia (Dif. 1/5 · Muy fácil)`, inválida |
| Lobo (12, `"  Lobo  "`, dificultad 2) | nombre y textos recortados, válida |
| Número 500, dificultad 9, FUE 99, DES -5, PG 0, CA -1 | `100`, `5`, `30`, `1`, `1`, `0` |
| Tipo vacío | vuelve a `"Bestia"` |
| Números 1 y 100 | válidos |
| Números 0 y 101 | inválidos |
| Dificultades 0 y 6 | se recortan a `1` y `5` |
| Habilidad con `"  Mordisco  "` | nombre recortado y válida |
| Habilidad vacía | inválida |
| Carga de `Criatura_001.tres` | `Nº 1 · Latígia · Planta_Insecto (Dif. 1/5 · Muy fácil)` |

### Paso 2. Cargar automáticamente las criaturas

- **Objetivo:** que la app encuentre sola todos los `.tres` de la carpeta, sin
  que haya que registrar cada criatura a mano.
- **Código:** `cargar_criaturas()` recorre `RUTA_CRIATURAS`
  (`res://Recursos/Criaturas/`), carga cada archivo `.tres`, comprueba que sea
  una `Criatura`, la normaliza y la guarda en `criaturas`, ordenada por número.
- **Arranque:** se llama en `_ready()` antes de `actualizar_panel_d100()`.
- **Comprobación:** con `Criatura_001.tres` en la carpeta, la lista tiene **1**
  criatura y `criaturas[0].nombre` es `"Latígia"`.

### Paso 3. Índice por número (pendiente)

Falta detectar números repetidos al cargar y avisar de posibles fichas
duplicadas. La búsqueda ya funciona, pero todavía recorre la lista.

### Paso 4. Buscar la criatura de una tirada

- **Código:** `buscar_criatura(numero)` devuelve la criatura cuyo `numero`
  coincide, o `null` si no existe.
- **Comprobación:** `buscar_criatura(1)` devuelve Latígia y
  `buscar_criatura(99)` devuelve `null`.

### Paso 5. Mostrar sus datos en el panel

- **Código:** `actualizar_criatura()` se llama desde `actualizar_panel_d100()`.
  - Rellena `Etiqueta_Criatura` con `Criatura nº 1 · Latígia`.
  - Pone el sprite en `Imagen_Criatura` (si la criatura tiene `imagen`).
  - Rellena `Titulo_Estadisticas` y el `Grid_Estadisticas` del popup: nombre,
	tipo, dificultad (`1/5 · Muy fácil`), CA, PG, velocidad y los seis
	atributos.
  - `rellenar_habilidades()` crea un botón por habilidad. El tooltip muestra
	la descripción y al pulsar se abre un diálogo con nombre y descripción.
	Si no hay habilidades, muestra «Sin habilidades».
- **Estados:** sin tirada → `Criatura nº —`; número sin ficha →
  `Criatura nº 99 · sin ficha` (grid vacío en `—`).
- **Comprobación:** con `ultima_tirada_d100 = 1` el panel muestra
  `Criatura nº 1 · Latígia`, el popup sus 12 datos y la lista el marcador
  «Sin habilidades».

---

# Bloque 8 — Habilidades interactivas y puntos

**Meta:** que cada habilidad de la criatura se pueda pulsar, gaste puntos y
quede registrada. Es el primer bloque con mecánica interactiva.

- [ ] Paso 1 — Ampliar `Habilidad`: `coste` en puntos y validación
- [ ] Paso 2 — Bolsa de puntos del personaje (actual, máximo, gastar y recuperar)
- [ ] Paso 3 — Mostrar las habilidades de la criatura como botones
- [ ] Paso 4 — Pulsar una habilidad: comprobar puntos, gastar y marcarla usada
- [ ] Paso 5 — Persistir puntos y usos, y refrescar la pantalla

### Notas para cuando llegue

- Cada criatura tendrá habilidades **distintas**; no hay lista compartida.
- El coste aún no está decidido: habrá que fijar la escala de puntos y si se
  recuperan al cambiar de forma, al descansar o por turno.
- Las fases y las mutaciones llegan después; no meterlas en este bloque.
- La UI de habilidades depende de la reestructuración del Bloque 9.

---

# Bloque 9 — UI de Transformaciones más compacta

**Meta:** que el panel de Transformaciones no ocupe media pantalla. Las
estadísticas pasan a una **ventana emergente** que se consulta cuando hace
falta; la pantalla principal se queda con el d100, la imagen y las habilidades.

- [x] Paso 1 — Mover `Panel_Estadisticas` a una `Ventana_Estadisticas` (popup) ✅
- [x] Paso 2 — Botón «Ver estadísticas» para abrir y cerrar el popup ✅
- [x] Paso 3 — Rellenar el popup desde la criatura cargada (dificultad incluida) ✅
- [x] Paso 4 — Reorganizar la fila principal en tres columnas ✅
- [ ] Paso 5 — Comprobar en 1280×720 y al redimensionar la ventana

### Lo que hay ahora

`Fila_Principal` tiene tres columnas:

| Columna | Ancho | Contenido |
|---|---|---|
| `Columna_Izquierda` | 280 px | Arriba `Panel_D100`; abajo `Panel_Puntos` |
| `Panel_Imagen` | flexible | `Etiqueta_Criatura`, `Imagen_Criatura` y `Boton_Estadisticas` |
| `Panel_Habilidades` | 340 px | `Lista_Habilidades` (botones en el futuro) |

- `Panel_Puntos` tiene `Barra_Transformacion` (dorada) y `Barra_Mutacion`
  (violeta), ambas con `show_percentage = false` y valor `0`.
- Los textos de valor (`Valor_Transformacion`, `Valor_Mutacion`) muestran
  `— / —` hasta que exista el sistema de puntos (Bloque 8).
- `Lista_Habilidades` contiene `Etiqueta_Sin_Habilidades` como marcador. Al
  cargar una criatura con habilidades se sustituye por un botón por habilidad.
- `Ventana_Estadisticas` es una `Window` de 840×440 con el `Grid_Estadisticas`
  dentro; se abre con `popup_centered()`, se cierra con la X (`close_requested`)
  y se rellena desde la criatura de la última tirada.
- El grid usa 6 columnas (tres parejas etiqueta/valor por fila) con 32 px de
  separación horizontal y 14 px vertical, para que las estadísticas no queden
  apretadas.
- Medidas verificadas a 1280×720: 280 + 524 + 340 px de ancho y 588 px de alto,
  sin desbordar.

### Notas para cuando llegue

- El popup ya muestra nombre, tipo, dificultad, CA, PG, velocidad y atributos.
- Las habilidades se quedan en la pantalla principal (son lo que se pulsa).
- Nodos renombrados: `Etiqueta_Dificultad` y `Dificultad_Criatura`
  (antes `Etiqueta_CR` y `CR_Criatura`).

---

# Glosario rápido

- **Nodo (Node):** pieza del árbol de la escena (botones, ventanas, listas…).
- **Resource:** dato reutilizable que se puede guardar y cargar (un objeto, una
  criatura, una imagen…).
- **Señal:** aviso que emite un nodo ("me pulsaron", "cambié de valor").
- **NodePath:** ruta a un nodo dentro de la escena.
- **@export:** hace que una variable aparezca en el Inspector.
- **Tipado:** declarar de qué tipo es una variable (`var x: int = 0`). Ayuda a
  detectar errores antes de ejecutar.
