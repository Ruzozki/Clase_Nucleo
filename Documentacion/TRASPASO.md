# Traspaso de contexto — Clase Núcleo

> Al empezar una sesión nueva, di: **"lee Documentacion/TRASPASO.md"**.

## El proyecto

App de apoyo para una clase homebrew de D&D: un constructo lanza **1d100** y se
transforma en una de **100 criaturas**. Hecha en **Godot 4.4.1** (GL Compatibility).

## Cómo trabajamos

- **1 bloque = 5 pasos.** Cada paso: objetivo → explicación → código → comprobación.
- No se avanza hasta que el paso funcione.
- El usuario es **principiante**: prefiere pegar el código él mismo, aunque a
  veces pide que se lo apliquen.
- Documentar **por bloques**, no línea por línea.
- Validar con Godot headless antes de dar algo por bueno:
  `Godot_v4.4.1-stable_win64_console.exe --headless --path <proyecto> --quit-after 5 --log-file <log>`
  (Godot está en `C:\Users\ruzow\Downloads\Godot_v4.4.1-stable_win64.exe\`,
  no en el PATH).

## Estado actual

- **Bloque 1: completado** ✅ — crear, validar, guardar en memoria, listar y ver detalle.
- **Bloque 2: completado** ✅ — categorías, búsqueda en vivo y filtro combinado.
- **Bloque 3: completado** ✅ — selección, edición, borrado con confirmación y
  persistencia en JSON (guardar tras cada cambio + cargar al arrancar).
- **Siguiente: Bloque 4** — divisas y cambio de moneda (diseño hablado, sin implementar).

## Archivos

| Archivo | Qué es |
|---|---|
| `Escenas/clase_nucleo.gd` | Script principal (~800 líneas): rutas del Inspector, `_ready`, señales, validación, lista, detalle, edición, borrado y persistencia. |
| `Escenas/clase_nucleo.tscn` | Escena principal: pestañas, buscador, lista, detalle, botones Editar/Eliminar y ventana de objeto. |
| `Recursos/Recursos_Objeto.gd` | Molde `class_name Objeto` (¡el archivo NO se llama `objeto.gd`!). |
| `Documentacion/PLAN.md` | Plan por bloques y pasos. |
| `Documentacion/CODIGO.md` | Explicación del código por bloques. |

## Datos guardados

`user://inventario.json` → en Windows:

```text
%APPDATA%\Godot\app_userdata\Clase_Núcleo\inventario.json
```

Formato: lista de diccionarios con `nombre`, `categoria`, `cantidad`, `costo` y
`descripcion`. Se guarda después de crear, editar y eliminar. Se carga en
`_ready()` antes de dibujar la lista.

## Decisiones tomadas

- Se usan **rutas `@export_node_path`** asignadas desde el Inspector (19 rutas).
  Migrar a nombres únicos `%` queda para el Bloque 5.
- `Objeto.CATEGORIAS` es la lista única de 6 categorías: Consumible, Equipo,
  Herramienta, Material, Tesoro, Misceláneo.
- El formulario usa `Opcion_Categoria`; la pantalla principal usa
  `Filtro_Categoria` (con "Todas" en el índice 0). **Son botones distintos.**
- Se guardan **referencias a fichas**, no índices de fila (los índices cambian
  al filtrar).
- Una sola ventana para crear y editar: `objeto_en_edicion == null` significa
  "crear".
- El borrado usa un `ConfirmationDialog` creado por código.
- No es un repo git: los cambios están solo en disco.

## Variables de estado del script

| Variable | Uso |
|---|---|
| `objetos` | Lista `Array[Objeto]`; la fuente de la verdad. |
| `objeto_seleccionado` | Fila marcada; activa Editar/Eliminar. |
| `objeto_en_edicion` | Ficha abierta en la ventana, o `null` si se crea. |
| `objeto_a_eliminar` | Ficha pendiente de confirmar el borrado. |

## Nodos clave de la escena

`Ventana_Objeto`, `Boton_Nuevo_Objeto`, `Boton_Cancelar_Objeto`,
`Boton_Guardar_Objetos`, `Entrada_Nombre`, `Entrada_Cantidad`,
`Entrada_Descripcion`, `Opcion_Categoria`, `Entrada_Costo`, `Lista_Objetos`,
`Nombre_Detalle`, `Categoria_Detalle`, `Cantidad_Detalle`,
`Descripcion_Detalle`, `Costo_Detalle`, `Entrada_Buscador`, `Filtro_Categoria`,
`Boton_Editar_Objeto`, `Boton_Eliminar_Objeto`.

## Errores ya resueltos (para no repetirlos)

- Función de arranque que nadie llama → `dialogo_aviso` `null` → error en el
  primer aviso.
- `@export_node_path` sin asignar → `cargar_referencias()` devuelve `false` y la
  pantalla deja de responder.
- Errata `Enstrada_Costo` (ya corregida a `Entrada_Costo`).
- Al reemplazar una función quedó código viejo pegado en otra → variable local
  (`nombre_limpio`) fuera de su función: *"Identifier not declared"*.
- `var datos := JSON.parse_string(texto)` → aviso de inferencia desde `Variant`
  tratado como error. Solución: `var datos: Variant = ...`.

## Bloques futuros

| Bloque | Tema |
|---|---|
| 4 | Divisas y cambio de moneda |
| 5 | Diseño de UI y refactor (`%`) |
| 6 | Sistema d100 de criaturas y transformaciones |

### Ideas del Bloque 4 (divisas)

- Patrón en "granos": cobre 100, plata 1.000, oro 10.000, platino 100.000.
- 4 ciudades con valores propios: Valdor, Puerto Sal, Karsk, Té-Ru.
- Conversión = `cantidad × valor_origen ÷ valor_destino`, con enteros y resto.
- Comisión del cambista (~5%) para evitar arbitraje.
- `costo` pasaría a guardarse en unidades de referencia (y habría que migrar el
  JSON existente).
- Pendiente de decidir: cobre vs bronce, y si se adopta el patrón en `costo`.
