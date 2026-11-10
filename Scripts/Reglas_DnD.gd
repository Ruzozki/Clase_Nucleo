class_name ReglasDnD
extends RefCounted
## Reglas de D&D 5e que usa la app: atributos, modificadores y competencia.
##
## Solo contiene datos fijos y cálculos. No guarda nada.


## Abreviaturas de los seis atributos, en el orden habitual de D&D.
const ATRIBUTOS: Array[String] = ["FUE", "DES", "CON", "INT", "SAB", "CAR"]

## Bono de competencia provisional, hasta que exista el nivel del Núcleo.
const BONO_COMPETENCIA_PROVISIONAL: int = 2


## Las 18 pericias de D&D 5e y el atributo del que depende cada una.
## El orden importa: las casillas de competencia de Fase usarán este mismo orden.
const PERICIAS: Dictionary = {
	"Acrobacias": "DES",
	"Atletismo": "FUE",
	"Conocimiento Arcano": "INT",
	"Engaño": "CAR",
	"Historia": "INT",
	"Interpretación": "CAR",
	"Intimidación": "CAR",
	"Investigación": "INT",
	"Juego de Manos": "DES",
	"Medicina": "SAB",
	"Naturaleza": "INT",
	"Percepción": "SAB",
	"Perspicacia": "SAB",
	"Persuasión": "CAR",
	"Religión": "INT",
	"Sigilo": "DES",
	"Supervivencia": "SAB",
	"Trato con Animales": "SAB",
}

## Modificador de un atributo: (valor - 10) / 2, redondeando hacia abajo.
## Ejemplos: 10 → +0, 15 → +2, 3 → -4.
static func modificador(valor: int) -> int:

	return floori((valor - 10) / 2.0)


## Texto con signo para la pantalla: 2 → "+2", -1 → "-1", 0 → "+0".
static func texto_modificador(valor_modificador: int) -> String:

	if valor_modificador >= 0:
		return "+" + str(valor_modificador)

	return str(valor_modificador)


## Bono de competencia según el nivel (D&D 5e).
## Niveles 1–4 → +2, 5–8 → +3, 9–12 → +4, 13–16 → +5, 17–20 → +6.
static func bono_competencia(nivel: int) -> int:

	var nivel_valido := clampi(nivel, 1, 20)
	return 2 + floori((nivel_valido - 1) / 4.0)



## Devuelve la abreviatura del atributo de una pericia: "Sigilo" → "DES".
## Si la pericia no existe, devuelve un texto vacío.
static func atributo_de_pericia(pericia: String) -> String:

	var atributo: String = PERICIAS.get(pericia, "")
	return atributo


## Devuelve los nombres de las 18 pericias, en el orden de la tabla.
static func nombres_pericias() -> Array[String]:

	var nombres: Array[String] = []

	for nombre in PERICIAS.keys():
		nombres.append(nombre)

	return nombres
