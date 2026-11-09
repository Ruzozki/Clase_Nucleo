# Cómo crear y rellenar una criatura

Cada criatura es un archivo de Godot (`.tres`) que contiene sus estadísticas.
No hay que tocar código: se rellena desde el **Inspector**.

- **Carpeta:** `res://Recursos/Criaturas/`
- **Un archivo por criatura.** Por ejemplo: `Criatura_001.tres`.
- **El número del d100 identifica a la criatura.** El archivo `Criatura_001.tres`
  lleva `numero = 1`, porque los números enteros no guardan ceros a la izquierda.

---

## Paso a paso en Godot

1. Abre el proyecto en Godot.
2. En el panel **FileSystem**, busca la carpeta `Recursos`.
3. Clic derecho sobre `Recursos` → **Crear nueva carpeta** → escribe `Criaturas`.
4. Clic derecho sobre `Criaturas` → **Crear nuevo** → **Recurso…**
5. En el buscador escribe `Criatura` y pulsa **Crear**.
6. Guarda el archivo como `Criatura_001.tres` dentro de `Recursos/Criaturas/`.
7. Selecciona el archivo en el FileSystem: el **Inspector** muestra todos los
   campos.
8. Rellena la ficha (tabla de abajo).
9. Guarda con **Ctrl + S**.

> Si `Criatura` no aparece en la lista, cierra y vuelve a abrir el proyecto
> (o usa **Proyecto → Recargar proyecto actual**) para que Godot registre la
> clase.

---

## Los campos

| Campo | Tipo | Rango | Qué poner |
|---|---|---|---|
| `numero` | entero | 1–100 | El resultado del d100. Para la 001: `1`. |
| `nombre` | texto | — | Nombre de la criatura. |
| `tipo` | texto libre | — | Bestia, Aberración, Dragón… o uno propio como `Planta_Insecto`. |
| `dificultad` | entero | 1–5 | Dificultad de uso de la forma (ver abajo). |
| `ca` | entero | 0–99 | Clase de armadura (AC). |
| `pg` | entero | 1–9999 | Puntos de golpe (HP). |
| `velocidad` | texto | — | `9 m`, `12 m`, `vuelo 18 m`, `nadar 12 m`… |
| `imagen` | textura | — | Sprite o pixelart de la forma. Puede quedarse vacío. |
| `fuerza` | entero | 1–30 | Fuerza (STR). |
| `destreza` | entero | 1–30 | Destreza (DEX). |
| `constitucion` | entero | 1–30 | Constitución (CON). |
| `inteligencia` | entero | 1–30 | Inteligencia (INT). |
| `sabiduria` | entero | 1–30 | Sabiduría (WIS). |
| `carisma` | entero | 1–30 | Carisma (CHA). |
| `habilidades` | lista | — | Habilidades propias de la criatura (ver abajo). |

**Tipos disponibles:**

Aberración, Bestia, Celestial, Constructo, Dragón, Elemental, Feérico,
Infernal, Gigante, Humanoide, Monstruosidad, No muerto, Planta, Cieno.

> Es una lista de referencia, **no una restricción**: el campo admite cualquier
> texto propio, por ejemplo `Planta_Insecto`.

---

## Dificultad de uso (1–5)

El **Challenge Rating (CR)** de D&D ya no se usa. En su lugar hay una escala
propia (homebrew) que mide **lo difícil que es usar esa forma**:

| Valor | Nombre | Significado |
|---|---|---|
| `1` | Muy fácil | Se usa sin esfuerzo. |
| `2` | Fácil | Cómoda, con un coste pequeño. |
| `3` | Normal | El uso estándar. |
| `4` | Difícil | Exige control o tiene un coste alto. |
| `5` | Muy difícil | Solo para situaciones concretas. |

- Se guarda como **número entero** (`dificultad = 3`).
- El nombre se obtiene con `nombre_dificultad()` (`"Normal"`).
- Los límites están en `DIFICULTAD_MINIMA = 1` y `DIFICULTAD_MAXIMA = 5`.
- `normalizar()` recorta cualquier valor fuera de la escala.
- Es una etiqueta de diseño: todavía **no** cambia ninguna mecánica.

---

## Habilidades

Cada criatura tiene sus **propias** habilidades, guardadas dentro de su
archivo `.tres`. No hay una lista compartida.

Cada habilidad es un recurso `Habilidad` con dos campos:

| Campo | Tipo | Qué poner |
|---|---|---|
| `nombre` | texto | Nombre corto: `Mordisco`, `Telaraña`, `Trepar`. |
| `descripcion` | texto multilínea | Qué hace la habilidad. |

### Cómo añadir una habilidad

1. Selecciona la criatura en el FileSystem.
2. En el Inspector busca el campo **Habilidades**.
3. Pulsa **Add Element**.
4. En el desplegable del elemento elige **New Habilidad**.
5. Despliega ese elemento y rellena `nombre` y `descripcion`.
6. Repite para cada habilidad y guarda con **Ctrl + S**.

> Si prefieres tener una habilidad en un archivo aparte, créala como recurso
> `Habilidad` y guárdala en `.tres`; luego arrástrala al elemento de la lista.

- El orden de la lista es el orden en que se mostrarán.
- Una habilidad sin `nombre` se considera inválida y se ignora.
- `normalizar()` limpia los espacios de nombre y descripción.
- Todavía **no** gastan puntos ni tienen coste: por ahora abren un diálogo con
  su descripción. El coste y los usos llegan en el **Bloque 8** (habilidades
  interactivas y puntos).

---

## De la ficha de D&D al Inspector

| En la ficha de D&D | En la criatura |
|---|---|
| **Armor Class (AC)** | `ca` |
| **Hit Points (HP)**, por ejemplo `11 (2d8+2)` | `pg = 11` |
| **Speed**, por ejemplo `40 ft.` | `velocidad = "12 m"` |
| **STR / DEX / CON / INT / WIS / CHA** | `fuerza`, `destreza`, `constitucion`, `inteligencia`, `sabiduria`, `carisma` |

> La velocidad se guarda en **metros**, no en pies. Redondea: `30 ft.` ≈ `9 m`,
> `40 ft.` ≈ `12 m`, `60 ft.` ≈ `18 m`.

> El **Challenge Rating (CR)** no se copia: en su lugar decides tú la
> `dificultad` de uso de 1 a 5.

> Guarda el **valor del atributo** (por ejemplo `15`), no el modificador
> (`+2`). El modificador se calcula más adelante.

---

## Ficha de la criatura 001

Plantilla para copiar en el Inspector:

```text
numero:       1
nombre:       (nombre de la criatura)
tipo:         Bestia
dificultad:   1
ca:           10
pg:           1
velocidad:    9 m
imagen:       (opcional; arrastra aquí el sprite o pixelart)
fuerza:       10
destreza:     10
constitucion: 10
inteligencia: 10
sabiduria:    10
carisma:      10
```

### Ejemplo relleno (Lobo de D&D 5e)

```text
numero:       1
nombre:       Lobo
tipo:         Bestia
dificultad:   2
ca:           13
pg:           11
velocidad:    12 m
imagen:       (opcional; arrastra aquí el sprite o pixelart)
fuerza:       12
destreza:     15
constitucion: 12
inteligencia: 3
sabiduria:    12
carisma:      6
```

---

## Reglas y comprobaciones

- El **número** debe estar entre `1` y `100` y no repetirse entre criaturas.
- El **nombre** no puede quedar vacío.
- La **dificultad** va de `1` (muy fácil) a `5` (muy difícil).
- Los campos numéricos se limitan solos a su rango en el Inspector.
- Si algún valor llega fuera de rango desde código, `normalizar()` lo corrige.
- `es_valida()` devuelve `true` cuando el número está en rango y hay nombre.
- Para comprobar que quedó bien: selecciona el `.tres` y revisa el Inspector.
  La app la muestra cuando sale su número en la tirada del d100.
