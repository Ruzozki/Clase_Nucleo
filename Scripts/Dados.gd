class_name Dados
extends RefCounted
## Utilidades para tirar dados de D&D 5e.
##
## El d100 (dado de porcentaje) es especial: es el dado de transformación.
## Su última tirada y su historial de 5 se guardan aparte, en la escena.


## Dados normales de D&D 5e, sin contar el d100 especial.
const DADOS_ESTANDAR: Array[int] = [4, 6, 8, 10, 12, 20]

## Caras del dado de transformación.
const DADO_ESPECIAL: int = 100

## Máximo que puede salir ahora mismo en el d100.
## Temporal: solo la criatura 001 está en pruebas, así que siempre sale 1.
const MAXIMO_ACTUAL_D100: int = 1

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
## Ahora mismo solo devuelve números del bloque desbloqueado (1–10).
static func tirar_d100() -> int:

	return randi_range(1, MAXIMO_ACTUAL_D100)


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
