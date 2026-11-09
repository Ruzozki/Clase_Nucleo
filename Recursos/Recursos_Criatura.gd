class_name Criatura
extends Resource
## Representa una forma en la que se transforma el personaje principal.
##
## Es un [Resource], así que solo contiene datos: no es un nodo y no se dibuja
## en la escena. El número del d100 (1–100) identifica a la criatura.


## Número mínimo y máximo del d100 que puede identificar a una criatura.
const NUMERO_MINIMO: int = 1
const NUMERO_MAXIMO: int = 100

## Rango permitido para los seis atributos de D&D 5e.
const ATRIBUTO_MINIMO: int = 1
const ATRIBUTO_MAXIMO: int = 30

## Escala de dificultad de uso de la forma (homebrew, no D&D).
const DIFICULTAD_MINIMA: int = 1
const DIFICULTAD_MAXIMA: int = 5

## Nombres de la escala de dificultad. El índice 0 es dificultad 1.
const NOMBRES_DIFICULTAD: Array[String] = [
	"Muy fácil",
	"Fácil",
	"Normal",
	"Difícil",
	"Muy difícil",
]

## Tipos de criatura de D&D 5e.
const TIPOS: Array[String] = [
	"Aberración",
	"Bestia",
	"Celestial",
	"Constructo",
	"Dragón",
	"Elemental",
	"Feérico",
	"Infernal",
	"Gigante",
	"Humanoide",
	"Monstruosidad",
	"No muerto",
	"Planta",
	"Cieno",
]

## Número del d100 que identifica a esta criatura (1–100).
@export_range(1, 100, 1) var numero: int = 1

## Nombre visible de la criatura.
@export var nombre: String = ""

## Tipo de criatura (Bestia, Aberración…).
@export var tipo: String = "Bestia"

## Dificultad de uso de la forma, de 1 (muy fácil) a 5 (muy difícil).
@export_range(1, 5, 1) var dificultad: int = 1

## Clase de armadura.
@export_range(0, 99, 1) var ca: int = 10

## Puntos de golpe.
@export_range(1, 9999, 1) var pg: int = 1

## Velocidad como texto: "9 m", "vuelo 18 m"…
@export var velocidad: String = "9 m"

## Sprite o pixelart de la forma. Puede quedarse vacío.
@export var imagen: Texture2D

## Los seis atributos de D&D 5e.
@export_range(1, 30, 1) var fuerza: int = 10
@export_range(1, 30, 1) var destreza: int = 10
@export_range(1, 30, 1) var constitucion: int = 10
@export_range(1, 30, 1) var inteligencia: int = 10
@export_range(1, 30, 1) var sabiduria: int = 10
@export_range(1, 30, 1) var carisma: int = 10

## Habilidades propias de esta forma. Cada criatura tiene las suyas.
@export var habilidades: Array[Habilidad] = []


## Ajusta los valores a los rangos permitidos y limpia los textos.
func normalizar() -> void:

	numero = clampi(numero, NUMERO_MINIMO, NUMERO_MAXIMO)
	nombre = nombre.strip_edges()
	tipo = tipo.strip_edges()
	velocidad = velocidad.strip_edges()

	if tipo.is_empty():
		tipo = "Bestia"

	dificultad = clampi(
		dificultad,
		DIFICULTAD_MINIMA,
		DIFICULTAD_MAXIMA
	)

	ca = clampi(ca, 0, 99)
	pg = clampi(pg, 1, 9999)

	fuerza = clampi(fuerza, ATRIBUTO_MINIMO, ATRIBUTO_MAXIMO)
	destreza = clampi(destreza, ATRIBUTO_MINIMO, ATRIBUTO_MAXIMO)
	constitucion = clampi(
		constitucion,
		ATRIBUTO_MINIMO,
		ATRIBUTO_MAXIMO
	)
	inteligencia = clampi(
		inteligencia,
		ATRIBUTO_MINIMO,
		ATRIBUTO_MAXIMO
	)
	sabiduria = clampi(sabiduria, ATRIBUTO_MINIMO, ATRIBUTO_MAXIMO)
	carisma = clampi(carisma, ATRIBUTO_MINIMO, ATRIBUTO_MAXIMO)

	for habilidad in habilidades:
		if habilidad != null:
			habilidad.normalizar()


## True si tiene un número dentro de rango y un nombre utilizable.
func es_valida() -> bool:

	return (
		numero >= NUMERO_MINIMO
		and numero <= NUMERO_MAXIMO
		and not nombre.strip_edges().is_empty()
	)


## Nombre de la dificultad actual: "Muy fácil" … "Muy difícil".
func nombre_dificultad() -> String:

	var indice := (
		clampi(dificultad, DIFICULTAD_MINIMA, DIFICULTAD_MAXIMA)
		- DIFICULTAD_MINIMA
	)

	return NOMBRES_DIFICULTAD[indice]


## Texto corto para listas o mensajes de consola.
func texto_resumen() -> String:

	var nombre_visible := nombre

	if nombre_visible.is_empty():
		nombre_visible = "Sin nombre"

	return "Nº %d · %s · %s (Dif. %d/%d · %s)" % [
		numero,
		nombre_visible,
		tipo,
		dificultad,
		DIFICULTAD_MAXIMA,
		nombre_dificultad(),
	]
