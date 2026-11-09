# Documentación del código — Clase Núcleo

Esta guía explica **qué hace cada bloque** de los scripts, sin entrar línea por
línea. La idea es que puedas leer un bloque, entender su función y saber dónde
tocar cuando quieras cambiar algo.

> Estado: **Bloque 3 completado** (editar, eliminar y persistencia en JSON).

## 1. Mapa del proyecto

| Archivo | Qué es | Qué hace |
|---|---|---|
| `Escenas/clase_nucleo.tscn` | Escena | Define la UI: pestañas, buscador, lista, panel de detalle, botones de acción y ventana "Nuevo Objeto". |
| `Escenas/clase_nucleo.gd` | Script | Cerebro de la escena: busca nodos, conecta señales, valida, guarda, filtra, edita, elimina y persiste. |
| `Recursos/Recursos_Objeto.gd` | Clase de datos | Molde (`class_name Objeto`) para representar un objeto del inventario. |
| `Documentacion/PLAN.md` | Plan | Bloques y pasos de aprendizaje. |
| `Documentacion/CODIGO.md` | Esta guía | Explicación por bloques del código. |
| `Documentacion/TRASPASO.md` | Contexto | Resumen para arrancar una sesión nueva. |

Carpetas que aún están vacías y para qué pueden servir:

- `Interfaz/` → escenas de UI reutilizables (por ejemplo, una ventana de aviso propia).
- `Scripts/` → scripts que no pertenecen a una escena concreta (lógica del juego).
- `Respaldo/` → copias de seguridad manuales.

> Regla práctica: una escena `.tscn` y su script `.gd` viven juntos y con el
> mismo nombre. Los datos (`Resource`) viven en `Recursos/`.

**Datos guardados:** el inventario se escribe en
`%APPDATA%\Godot\app_userdata\Clase_Núcleo\inventario.json`
(la ruta virtual `user://inventario.json`).

## 2. La idea central: escena y script se complementan

- La **escena** dice *qué se ve*: nodos, contenedores, textos, tamaños.
- El **script** dice *qué hace*: reaccionar a clics, validar, guardar, filtrar.
- El script **no crea** los botones: los **busca** por su ruta.

Para encontrar un nodo hay dos caminos: por `NodePath` (lo que usamos ahora) o
por nombre único `%` (lo veremos en el bloque de refactor).

## 3. `Recursos/Recursos_Objeto.gd`

Es el molde de datos. No se ve en pantalla y no es un nodo.

| Bloque | Qué hace |
|---|---|
| `class_name Objeto` | Registra el nombre `Objeto` para usarlo como tipo en todo el proyecto. |
| `extends Resource` | Hereda de `Resource`: un contenedor de datos que se puede guardar y cargar. |
| `## ...` | Comentarios de documentación. Godot los muestra como ayuda en el Inspector. |
| `const CATEGORIAS` | Lista **única** de categorías válidas. La usan el formulario y el filtro. |
| `@export var nombre: String` | Texto del nombre, editable desde el Inspector. |
| `@export var categoria: String` | Categoría para agrupar y filtrar. Valor inicial `"Misceláneo"`. |
| `@export_range(1, 9999, 1) var cantidad: int` | Entero con mínimo 1, máximo 9999 y paso 1. |
| `@export_range(0, 999999, 1) var costo: int` | Precio del objeto. Mínimo 0 (gratis). |
| `@export_multiline var descripcion: String` | Texto largo, en un cuadro de varias líneas. |

**Por qué `CATEGORIAS` vive aquí:** las categorías son una propiedad del *dato*,
no de la pantalla. Si mañana hay una tienda o un cofre, ya las tienen. Además
evita escribir `"Consumible"` en cinco sitios y que uno quede con otra grafía.

**Cómo se usa:** en `clase_nucleo.gd`, `Objeto.new()` crea una ficha vacía y
luego se rellenan sus campos. Cada ficha es independiente: cambiar una no
afecta a las demás.

## 4. `Escenas/clase_nucleo.gd`

### 4.1. Cabecera del archivo

Un comentario que explica la decisión de diseño: esta versión **no** usa `%` ni
rutas escritas en el código; las rutas se asignan en el Inspector. Es
documentación para tu yo del futuro.

### 4.2. Rutas asignables desde el Inspector

**19** variables `@export_node_path` agrupadas en seis categorías:

| Sección | Rutas |
|---|---|
| *Ventana de objetos* | ventana, botón nuevo, botón cancelar, botón guardar |
| *Formulario de objetos* | nombre, cantidad, descripción, categoría, costo |
| *Lista de objetos* | `Lista_Objetos` |
| *Detalle del objeto* | nombre, categoría, cantidad, descripción, costo |
| *Buscador y filtros* | entrada del buscador, filtro de categoría |
| *Acciones del objeto* | botón editar, botón eliminar |

- Cada una guarda la **dirección** de un nodo de la escena.
- `@export_category("...")` crea un grupo en el Inspector para ordenarlas.
- El texto entre paréntesis (`"Window"`, `"Button"`, `"LineEdit"`, `"SpinBox"`,
  `"OptionButton"`, `"ItemList"`, `"Label"`) filtra qué tipo de nodo puedes
  asignar.
- Se asignan en el Inspector del nodo raíz. Si falta una,
  `cargar_referencias()` avisa con `push_error`.

### 4.3. Referencias internas

Variables tipadas (`Window`, `Button`, `LineEdit`, `SpinBox`, `OptionButton`,
`ItemList`, `Label`, `AcceptDialog`, `ConfirmationDialog`) que guardarán el
**nodo real** una vez cargado. Están agrupadas por el mismo criterio que las
rutas.

Diferencia clave:

- **Ruta** (`NodePath`) = la dirección, como "Calle Mayor 5".
- **Referencia** (`Button`, `LineEdit`...) = la persona que vive ahí; con ella
  puedes llamar a sus funciones.

### 4.4. Almacenamiento

```gdscript
const RUTA_INVENTARIO: String = "user://inventario.json"

var objetos: Array[Objeto] = []

var objeto_seleccionado: Objeto = null
var objeto_a_eliminar: Objeto = null
var objeto_en_edicion: Objeto = null
```

- `RUTA_INVENTARIO` es una **constante**: la ruta del archivo, escrita una sola
  vez. `user://` es una carpeta propia del proyecto gestionada por Godot.
- `objetos` es la "base de datos" en memoria y la **fuente de la verdad**.
  `Array[Objeto]` es una lista **tipada**: solo acepta objetos de tipo `Objeto`.
- Las tres variables de estado guardan **referencias a fichas**, no índices de
  fila (los índices cambian al filtrar):

| Variable | Para qué |
|---|---|
| `objeto_seleccionado` | El objeto marcado en la lista. Activa Editar/Eliminar. |
| `objeto_a_eliminar` | La "víctima" pendiente de confirmación. |
| `objeto_en_edicion` | El objeto abierto en la ventana, o `null` si se está creando. |

> La `ItemList` solo *muestra* lo que hay en `objetos`. Nunca se consulta la
> lista para saber qué objetos existen: se consulta `objetos`.

### 4.5. `_ready()`

Se ejecuta **una vez**, cuando la escena entra en el árbol. Es el arranque del
script. Orden:

1. `crear_dialogo_aviso()` → prepara el aviso.
2. `crear_dialogo_confirmacion()` → prepara el diálogo de borrado.
3. `cargar_referencias()` → busca los nodos. Si algo falta, `return` y no sigue.
4. `conectar_botones()` → enlaza clics, selecciones y escritura con funciones.
5. `cargar_categorias()` → rellena el desplegable del formulario.
6. `cargar_filtro_categorias()` → rellena el desplegable del filtro.
7. `ventana_objeto.hide()` → la ventana empieza oculta.
8. `cargar_inventario()` → lee el JSON y llena `objetos`.
9. `actualizar_lista_objetos()` → dibuja la lista y deja el detalle limpio.

> El orden del 8 y el 9 importa: **primero los datos, después la pantalla**.

> Si `crear_dialogo_aviso()` falta, `dialogo_aviso` queda `null` y el primer
> aviso revienta con *"Invalid assignment ... on a base object of type 'Nil'"*.
> Pasó una vez: las funciones de arranque no se ejecutan solas.

### 4.6. `crear_dialogo_aviso()` y `crear_dialogo_confirmacion()`

Crean los diálogos **por código** y los añaden como hijos del `Control`. Así no
hace falta añadirlos a la escena a mano.

| Diálogo | Tipo | Botones | Uso |
|---|---|---|---|
| `dialogo_aviso` | `AcceptDialog` | un "OK" | Errores de validación. |
| `dialogo_confirmacion` | `ConfirmationDialog` | "Eliminar" + "Cancelar" | Confirmar un borrado. |

`crear_dialogo_confirmacion()` también conecta sus dos señales:

- `confirmed` → `_on_confirmacion_eliminar_confirmada()` (borra).
- `canceled` → `_on_confirmacion_eliminar_cancelada()` (no hace nada, limpia).

`canceled` se emite al pulsar "Cancelar", la **X** o **Esc**.

### 4.7. `cargar_categorias()` y `cargar_filtro_categorias()`

Rellenan los dos `OptionButton`, que son distintos y no hay que confundirlos:

| Función | Botón | Contenido |
|---|---|---|
| `cargar_categorias()` | `Opcion_Categoria` (formulario) | las 6 categorías, sin "Todas" |
| `cargar_filtro_categorias()` | `Filtro_Categoria` (pantalla) | **"Todas"** + las 6 categorías |

Ambas hacen `clear()` antes de rellenar, para no duplicar opciones si se llaman
dos veces, y terminan con `select(0)`.

**Por qué "Todas" va primero:** porque `select(0)` deja la primera opción
activa. Así el filtro arranca en estado neutro. Y esa posición extra explica por
qué **no** se puede usar `Objeto.CATEGORIAS[selected]`: en el filtro, la
categoría 0 está en el índice 1.

### 4.8. `cargar_referencias() -> bool`

Convierte cada ruta en una referencia real:

```gdscript
ventana_objeto = get_node_or_null(ruta_ventana_objeto) as Window
```

- `get_node_or_null()` → devuelve el nodo o `null` si no existe, **sin cerrar
  el juego**.
- `as Window` → comprueba y convierte al tipo; si no es una `Window`, queda
  `null`.
- Después hay un `if ... == null` por cada referencia: si falta, `push_error` y
  `return false`.
- Devuelve `true` solo si **todas** existen.

`push_error` no detiene el juego: escribe el error en Output. Por eso `_ready()`
comprueba el `bool` y hace `return` para no seguir con referencias vacías.

### 4.9. `conectar_botones()`

Enlaza cada señal con su función:

| Señal | Función |
|---|---|
| `Boton_Nuevo_Objeto.pressed` | `_on_boton_nuevo_objeto_pressed` |
| `Boton_Cancelar_Objeto.pressed` | `_on_boton_cancelar_objeto_pressed` |
| `Boton_Guardar_Objetos.pressed` | `_on_boton_guardar_objeto_pressed` |
| `Boton_Editar_Objeto.pressed` | `_on_boton_editar_objeto_pressed` |
| `Boton_Eliminar_Objeto.pressed` | `_on_boton_eliminar_objeto_pressed` |
| `Lista_Objetos.item_selected` | `_on_lista_objetos_item_selected` |
| `Entrada_Buscador.text_changed` | `_on_entrada_buscador_text_changed` |
| `Filtro_Categoria.item_selected` | `_on_filtro_categoria_item_selected` |
| `Ventana_Objeto.close_requested` | `_on_ventana_objeto_close_requested` |

Las señales del `ConfirmationDialog` se conectan en
`crear_dialogo_confirmacion()`, no aquí, porque nacen con el diálogo.

`is_connected()` evita conectar dos veces la misma señal (sería un error).

> El nombre `conectar_botones()` se quedó corto: ya conecta también el buscador
> y el filtro. Renombrarlo a `conectar_senales()` está en la lista del refactor.

### 4.10. Abrir, cerrar y rellenar el formulario

- `abrir_ventana_objeto(objeto: Objeto = null)`: el parámetro es **opcional**.
  - Guarda `objeto_en_edicion = objeto`.
  - Si es `null`: título **"Nuevo Objeto"** y `limpiar_formulario_objeto()`.
  - Si no: título **"Editar Objeto"** y `cargar_formulario_objeto(objeto)`.
  - Muestra la ventana centrada a 600×360 y pone el cursor en el nombre.
- `cerrar_ventana_objeto()`: pone `objeto_en_edicion = null` (para no quedarse
  "pegado" en modo edición) y oculta la ventana.
- `limpiar_formulario_objeto()`: vacía nombre y descripción, devuelve la
  cantidad a 1, el costo a 0 y la categoría a la primera.
- `cargar_formulario_objeto(objeto)`: copia los datos de la ficha a los campos.
- `seleccionar_categoria(categoria)`: traduce el **texto** de la categoría al
  **índice** del `OptionButton` con `Objeto.CATEGORIAS.find()`. Si no la
  encuentra (`-1`), cae en la primera.
- `aplicar_formulario_a_objeto(objeto, nombre_limpio)`: el camino inverso:
  copia los campos a la ficha. Se usa tanto al crear como al editar.

**Por qué una sola ventana para dos modos:** no duplicar formularios ni
validaciones. La variable `objeto_en_edicion` es la que decide.

### 4.11. `actualizar_lista_objetos()`

Es el corazón de la pantalla. Reconstruye la `ItemList` **desde el array**,
aplicando los filtros activos:

1. `objeto_seleccionado = null` → al reconstruir, la selección anterior deja de
   ser válida.
2. `lista_objetos.clear()` → borra las filas anteriores.
3. Lee el texto del buscador (`strip_edges()` + `to_lower()`) y la categoría del
   filtro.
4. Recorre `objetos` y descarta con `continue` lo que no pase **la búsqueda** o
   **la categoría**.
5. Por cada superviviente: `add_item(nombre)` + `set_item_metadata(indice, objeto)`.
6. Si no sobrevivió ninguno (`encontrados == 0`), añade una fila
   **"Sin resultados"** y la desactiva con `set_item_disabled(0, true)`.
7. `mostrar_detalle_vacio()` y `actualizar_botones_acciones()` → dejan la
   pantalla coherente (sin detalle y con Editar/Eliminar apagados).

Se llama al iniciar, al guardar, al editar, al eliminar, al escribir en el
buscador y al cambiar el filtro.

### 4.12. Las tres funciones auxiliares del filtrado

| Función | Qué responde |
|---|---|
| `coincide_busqueda(objeto, texto)` | ¿El nombre **o** la descripción contienen el texto? Si el texto está vacío, todo coincide. |
| `coincide_categoria(objeto, categoria)` | ¿La categoría del objeto es exactamente la del filtro? Si el filtro está vacío, todo coincide. |
| `obtener_categoria_filtro()` | Devuelve el texto de la categoría elegida, o `""` si está en "Todas". |

Detalles que importan:

- Se usa `==` y no `contains()` en la categoría: son valores exactos, y
  `contains()` haría que "Material" coincidiera con "Materiales".
- `selected <= 0` cubre tanto "Todas" (0) como "nada seleccionado" (-1).
- Las tres devuelven "todo coincide" cuando no hay filtro. Si no, borrar el
  buscador vaciaría la lista.

### 4.13. Detalle del objeto

- `mostrar_detalle_objeto(objeto)`: escribe en las cinco etiquetas el nombre,
  la categoría, la cantidad, el costo y la descripción.
- `mostrar_detalle_vacio()`: deja las etiquetas con sus textos base.

`str(objeto.cantidad)` convierte un número a texto para poder concatenarlo.

### 4.14. Acciones del objeto

`actualizar_botones_acciones()` enciende o apaga **Editar** y **Eliminar**
según haya selección:

```gdscript
var hay_seleccion := objeto_seleccionado != null
boton_editar_objeto.disabled = not hay_seleccion
boton_eliminar_objeto.disabled = not hay_seleccion
```

Se llama al cambiar la selección y cada vez que se reconstruye la lista.

### 4.15. Persistencia (JSON)

Cuatro funciones, dos para guardar y dos para leer:

| Función | Qué hace |
|---|---|
| `objeto_a_diccionario(objeto)` | Traduce una ficha a `{ "nombre": ..., "cantidad": ... }`. |
| `guardar_inventario()` | Recorre `objetos`, hace la lista de diccionarios y la escribe en el archivo. |
| `cargar_inventario()` | Lee el archivo y reconstruye `objetos`. |
| `diccionario_a_objeto(dato)` | Traduce un diccionario a una ficha `Objeto`. |

**Guardar:**

```text
objetos → lista de Dictionary → JSON.stringify(lista, "\t") → FileAccess → inventario.json
```

- `FileAccess.open(RUTA_INVENTARIO, FileAccess.WRITE)` crea o **sobrescribe** el
  archivo. Devuelve `null` si falla; por eso se comprueba.
- `store_string()` escribe el texto y `close()` lo vuelca al disco.
- `"\t"` como segundo argumento de `JSON.stringify` es la indentación: el
  archivo sale legible, un campo por línea (las claves, ordenadas).
- Se guarda **después de crear, editar y eliminar**, no al cerrar la app.

**Cargar:**

```text
inventario.json → FileAccess.READ → get_as_text() → JSON.parse_string() → Array → diccionario_a_objeto()
```

- Si el archivo **no existe**, se sale sin error: es la primera ejecución.
- `JSON.parse_string()` devuelve `Variant`: puede ser `Array`, `Dictionary`,
  número o `null`. Hay que comprobar `is Array` antes de recorrerlo.
- `datos` se declara `var datos: Variant = ...`, **no** con `:=`: el proyecto
  trata como error los avisos de inferencia desde `Variant`.
- Cada entrada se comprueba con `is Dictionary`; si no lo es, se salta.
- `dato.get("clave", valor_por_defecto)` evita fallos si un objeto viejo no
  tiene ese campo.
- `int(...)` convierte los números: JSON devuelve `3.0`, no `3`.
- La categoría se valida contra `Objeto.CATEGORIAS`; si no está, pasa a
  `"Misceláneo"`.

> **Formato del archivo:** una lista de diccionarios con las cinco
> propiedades. No se guardan índices ni identificadores: el orden del array es
> el orden de los objetos.

### 4.16. Señales (`_on_...`)

Son funciones que se ejecutan cuando ocurre algo. El prefijo `_on_` es una
convención, no una obligación.

- `_on_boton_nuevo_objeto_pressed()` → `abrir_ventana_objeto()` sin parámetro
  (modo crear).
- `_on_boton_editar_objeto_pressed()` → si hay selección,
  `abrir_ventana_objeto(objeto_seleccionado)` (modo editar).
- `_on_boton_eliminar_objeto_pressed()` → guarda la víctima en
  `objeto_a_eliminar`, escribe el texto del diálogo y lo abre.
- `_on_confirmacion_eliminar_confirmada()` → `objetos.erase(...)`, limpia la
  víctima, guarda y refresca.
- `_on_confirmacion_eliminar_cancelada()` → solo limpia la víctima.
- `_on_boton_cancelar_objeto_pressed()` → cierra la ventana.
- `_on_ventana_objeto_close_requested()` → cierra la ventana (la X).
- `_on_entrada_buscador_text_changed(_texto_nuevo)` → vuelve a dibujar la lista.
  Se usa el parámetro con `_` porque no hace falta: el texto se lee del nodo.
- `_on_filtro_categoria_item_selected(_indice)` → vuelve a dibujar la lista.
- `_on_lista_objetos_item_selected(indice)` → recupera el `Objeto` guardado en
  esa fila con `get_item_metadata(indice)`. Si no hay objeto (por ejemplo, la
  fila "Sin resultados"), limpia el detalle. Después actualiza los botones.
- `_on_boton_guardar_objeto_pressed()` → **la más importante**:
  1. Limpia espacios del nombre.
  2. Si está vacío: avisa y pone el cursor. `return` corta la función.
  3. Si `objeto_en_edicion == null`: crea `Objeto.new()`, lo rellena con
	 `aplicar_formulario_a_objeto()` y lo añade con `append()`.
  4. Si no: aplica el formulario **sobre la ficha existente** (no duplica).
  5. `guardar_inventario()` → escribe el archivo.
  6. `actualizar_lista_objetos()` → refresca la pantalla.
  7. `cerrar_ventana_objeto()` → cierra y vuelve a modo neutro.

### 4.17. Avisos

`mostrar_aviso(texto)` cambia el texto del diálogo y lo muestra centrado. Se usa
para los errores de validación.

## 5. Flujo completo

```text
F5
 └─ _ready()
	 ├─ crear_dialogo_aviso()
	 ├─ crear_dialogo_confirmacion()
	 ├─ cargar_referencias() ──► si falta algo: push_error + return
	 ├─ conectar_botones()
	 ├─ cargar_categorias()
	 ├─ cargar_filtro_categorias()
	 ├─ ventana_objeto.hide()
	 ├─ cargar_inventario() ──► lee inventario.json (si existe)
	 └─ actualizar_lista_objetos() ──► pinta la lista y limpia el detalle

Clic en "Nuevo Objeto"
 └─ _on_boton_nuevo_objeto_pressed()
	 └─ abrir_ventana_objeto()
		 ├─ objeto_en_edicion = null
		 ├─ título "Nuevo Objeto" + limpiar_formulario_objeto()
		 ├─ ventana_objeto.popup_centered(...)
		 └─ entrada_nombre.grab_focus()

Clic en "Editar" (con fila seleccionada)
 └─ _on_boton_editar_objeto_pressed()
	 └─ abrir_ventana_objeto(objeto_seleccionado)
		 ├─ objeto_en_edicion = ficha
		 ├─ título "Editar Objeto" + cargar_formulario_objeto(ficha)
		 └─ popup + foco

Clic en "Guardar Objeto"
 └─ _on_boton_guardar_objeto_pressed()
	 ├─ ¿nombre vacío? ──► mostrar_aviso() + return
	 ├─ ¿objeto_en_edicion == null?
	 │    ├─ sí: Objeto.new() → aplicar_formulario_a_objeto() → append()
	 │    └─ no: aplicar_formulario_a_objeto(objeto_en_edicion, ...)
	 ├─ guardar_inventario() ──► escribe el JSON
	 ├─ actualizar_lista_objetos()
	 └─ cerrar_ventana_objeto() ──► objeto_en_edicion = null

Clic en "Eliminar" (con fila seleccionada)
 └─ _on_boton_eliminar_objeto_pressed()
	 ├─ objeto_a_eliminar = objeto_seleccionado
	 └─ dialogo_confirmacion.popup_centered(...)

   "Cancelar" / X / Esc
	 └─ _on_confirmacion_eliminar_cancelada()
		 └─ objeto_a_eliminar = null

   "Eliminar"
	 └─ _on_confirmacion_eliminar_confirmada()
		 ├─ objetos.erase(objeto_a_eliminar)
		 ├─ objeto_a_eliminar = null
		 ├─ guardar_inventario()
		 └─ actualizar_lista_objetos()

Escribir en el buscador / cambiar el filtro
 └─ actualizar_lista_objetos()
	 ├─ objeto_seleccionado = null + botones apagados
	 ├─ clear()
	 ├─ por cada objeto:
	 │    ├─ ¿pasa la búsqueda?  ──► si no: continue
	 │    ├─ ¿pasa la categoría? ──► si no: continue
	 │    └─ add_item() + set_item_metadata()
	 ├─ ¿0 encontrados? ──► add_item("Sin resultados") + set_item_disabled()
	 └─ mostrar_detalle_vacio()

Clic en una fila de la lista
 └─ _on_lista_objetos_item_selected(indice)
	 ├─ get_item_metadata(indice) as Objeto
	 ├─ ¿null? ──► mostrar_detalle_vacio()
	 ├─ si no ──► mostrar_detalle_objeto(objeto)
	 └─ actualizar_botones_acciones()
```

## 6. Conceptos clave

| Término | Explicación |
|---|---|
| Nodo | Pieza del árbol de escena (botón, ventana, lista...). |
| Escena | Árbol de nodos guardado en un `.tscn`. |
| Script | Código que da comportamiento a un nodo (`.gd`). |
| Señal | Aviso que emite un nodo ("me pulsaron", "cambié de valor"). |
| `NodePath` | Ruta a un nodo dentro de la escena. |
| `Resource` | Dato reutilizable; no es un nodo. |
| `@export` | Muestra una variable en el Inspector. |
| Tipado | Declarar el tipo (`var x: int`); ayuda a detectar errores. |
| `Variant` | Tipo "cualquiera": puede contener cualquier valor. |
| `null` | "No hay nada" / referencia vacía. |
| `append` | Añadir al final de una lista. |
| `erase` | Quitar de una lista un elemento (por referencia). |
| `size` | Número de elementos de una lista. |
| `ItemList` | Nodo que muestra una lista de textos seleccionables. |
| Metadato | Dato extra guardado dentro de una fila (`set_item_metadata`). |
| `OptionButton` | Botón con lista desplegable de opciones. |
| `selected` | Índice de la opción elegida en un `OptionButton`. |
| `continue` | Salta a la siguiente vuelta de un bucle. |
| `to_lower()` | Convierte texto a minúsculas. |
| `contains()` | Comprueba si un texto contiene otro. |
| `str()` / `int()` | Convierten entre texto y número. |
| `Dictionary` | Pareja clave → valor (`{ "nombre": "Espada" }`). |
| JSON | Formato de texto para guardar datos; listas, diccionarios, textos y números. |
| `FileAccess` | Clase para leer y escribir archivos. |
| `user://` | Carpeta de datos del proyecto, gestionada por Godot. |
| `ConfirmationDialog` | Ventana con botones de aceptar y cancelar. |
| `push_error` | Escribe un error en Output sin cerrar el juego. |

## 7. Notas y mejoras pendientes

- **`conectar_botones()`** ya conecta más que botones. Renombrar a
  `conectar_senales()` en el refactor.
- **Acentos en la búsqueda:** `pocion` no encuentra `Poción`, porque `ó` y `o`
  son caracteres distintos. Se arregla con una función que normalice el texto.
- **El detalle se limpia al escribir:** es consecuencia de reconstruir la lista.
  Si molesta, se puede recordar qué objeto estaba seleccionado.
- **La selección se pierde al guardar o eliminar:** la lista se reconstruye y
  `objeto_seleccionado` pasa a `null`. Se podría volver a seleccionar la fila.
- **`mostrar_detalle_vacio()` está dos veces** en `actualizar_lista_objetos()`
  (al principio y al final). Es inofensivo; sobra la primera.
- **"Sin resultados"** se añade como fila desactivada. Alternativa: usar una
  etiqueta aparte debajo de la lista.
- **`costo` está en "oro"** y se muestra con la palabra fija. Si se implementa
  el Bloque 4 (divisas), debería guardarse en unidades de referencia.
- **Escritura no atómica:** `guardar_inventario()` sobrescribe el archivo
  directamente. Si la app muriera justo escribiendo, podría quedar truncado.
  La solución avanzada es escribir en un temporal y renombrarlo.
- **Sin identificadores:** dos objetos con el mismo nombre son fichas distintas
  en memoria (se distinguen por referencia), pero en el JSON solo se distinguen
  por su posición.
- **Rutas del Inspector:** funcionan, pero son el patrón más verboso. En el
  Bloque 5 se cambiarán a nombres únicos `%`.
- **La lista** se reconstruye entera en cada tecla. Con decenas de objetos es
  instantáneo; con miles habría que optimizar.
