class_name Dados
extends RefCounted
## Utilidades para tirar dados de D&D 5e.
##
## El d100 (dado de porcentaje) es especial: es el dado de transformación.
## Su última tirada y su historial de 5 se guardan aparte, en la escena.


## Dados normales de D&D 5e, sin contar el d100 especial.
const DADOS_ESTANDAR: Array[int] = [4, 6, 8, 10, 12, 20]

## Caras del dado de mutación. Es otro d100, distinto del de transformación.
const DADO_MUTACION: int = 100

## Caras del dado de transformación.
const DADO_ESPECIAL: int = 100

## Hasta qué número vale una tirada del d100 de transformación.
## Temporal: la criatura 1 a 10 están en pruebas. En el futuro lo decidirán los Hitos.
const UMBRAL_D100: int = 10

## Máximo de tiradas que se recuerdan del dado especial.
const MAX_HISTORIAL: int = 5


## Tira un dado de las caras indicadas.
## Devuelve un número entre 1 y `caras` (ambos incluidos).
## Si `caras` es menor que 1, devuelve 0.
static func tirar(caras: int) -> int:

	if caras < 1:
		return 0

	return randi_range(1, caras)


## Tira el d100 de transformación.
## Se tira un d100 de verdad; si sale más que el umbral, se vuelve a tirar.
## Así el resultado siempre está entre 1 y UMBRAL_D100.
static func tirar_d100() -> int:

	var umbral := clampi(UMBRAL_D100, 1, DADO_ESPECIAL)
	var resultado := tirar(DADO_ESPECIAL)

	while resultado > umbral:
		resultado = tirar(DADO_ESPECIAL)

	return resultado

## Tira el dado de mutación (otro d100, sin umbral). Devuelve de 1 a 100.
static func tirar_dado_mutacion() -> int:

	return tirar(DADO_MUTACION)
	
## Añade una tirada al principio del historial y lo recorta a MAX_HISTORIAL.
## Devuelve una lista nueva (no modifica la que recibe).
## Ejemplo: [7, 91] + 42 → [42, 7, 91].
static func agregar_al_historial(
	historial: Array[int],
	resultado: int
) -> Array[int]:

	var nuevo: Array[int] = [resultado]

	for i in historial.size():

		if nuevo.size() >= MAX_HISTORIAL:
			break

		nuevo.append(historial[i])

	return nuevo


## Comprueba si un resultado ya salió en las últimas `ultimas` tiradas.
## El historial está ordenado de la más nueva a la más vieja.
static func es_duplicada(
	historial: Array[int],
	resultado: int,
	ultimas: int = 4
) -> bool:

	var limite := mini(ultimas, historial.size())

	for i in limite:

		if historial[i] == resultado:
			return true

	return false


## Texto para el registro de la sesión: (20, 17) → "d20 → 17".
static func texto_tirada(caras: int, resultado: int) -> String:

	return "d" + str(caras) + " → " + str(resultado)
