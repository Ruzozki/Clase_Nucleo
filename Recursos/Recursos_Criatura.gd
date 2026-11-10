class_name Criatura
extends Resource
## Representa una forma en la que se transforma el personaje principal.
##
## Es un [Resource], así que solo contiene datos: no es un nodo y no se dibuja
## en la escena. El número del d100 (1–100) identifica a la criatura.


## Número mínimo y máximo del d100 que puede identificar a una criatura.
const NUMERO_MINIMO: int = 1
const NUMERO_MAXIMO: int = 100

## Escala de dificultad de uso de la forma (homebrew, no D&D).
const DIFICULTAD_MINIMA: int = 1
const DIFICULTAD_MAXIMA: int = 5

## Cada criatura tiene exactamente 4 fases de evolución.
const NUMERO_FASES: int = 4

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

## Sprite o pixelart de la forma. Puede quedarse vacío.
@export var imagen: Texture2D

## Habilidades propias de esta forma. Cada criatura tiene las suyas.
@export var habilidades: Array[Habilidad] = []

## Las 4 fases de evolución, en orden: fase 1, 2, 3 y 4.
@export var fases: Array[Fase] = []

## Ajusta los valores a los rangos permitidos y limpia los textos.
func normalizar() -> void:

	numero = clampi(numero, NUMERO_MINIMO, NUMERO_MAXIMO)
	nombre = nombre.strip_edges()
	tipo = tipo.strip_edges()

	if tipo.is_empty():
		tipo = "Bestia"

	dificultad = clampi(
		dificultad,
		DIFICULTAD_MINIMA,
		DIFICULTAD_MAXIMA
	)

	for habilidad in habilidades:
		if habilidad != null:
			habilidad.normalizar()
	
	for fase in fases:
		if fase != null:
			fase.normalizar()

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



## Devuelve la fase con ese número (1–4), o null si no existe.
func obtener_fase(numero_fase: int) -> Fase:

	for fase in fases:
		if fase != null and fase.numero == numero_fase:
			return fase

	return null


## Revisa las fases y devuelve una lista de problemas.
## Si la lista está vacía, las fases están bien.
func problemas_fases() -> Array[String]:

	var problemas: Array[String] = []

	if fases.size() != NUMERO_FASES:
		problemas.append("tiene %d fases en vez de %d" % [fases.size(), NUMERO_FASES])

	var nivel_anterior := 0

	for i in fases.size():

		var fase := fases[i]

		if fase == null:
			problemas.append("la posición %d está vacía" % i)
			continue

		if fase.numero != i + 1:
			problemas.append("la posición %d tiene la fase %d, debería ser la %d" % [i, fase.numero, i + 1])

		if fase.nivel_requerido < nivel_anterior:
			problemas.append("la fase %d pide nivel %d, menos que la fase anterior" % [fase.numero, fase.nivel_requerido])

		nivel_anterior = fase.nivel_requerido

	return problemas
