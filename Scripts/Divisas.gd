class_name Divisas
extends RefCounted
## Tabla de las monedas del mundo y sus valores.
##
## Los valores se guardan en **granos** (números enteros), no en decimales:
## 1 grano = 0,01 de una moneda de cobre de Orelha.
## Así las conversiones se hacen con enteros y no hay errores de redondeo.
##
## El orden de las denominaciones es siempre el mismo en todas las monedas:
## cobre, plata, oro y platino.


## Denominaciones, de menor a mayor valor. El índice es su posición.
const DENOMINACIONES: Array[String] = [
	"Cobre",
	"Plata",
	"Oro",
	"Platino",
]

## Monedas, de la más valiosa a la menos valiosa.
const MONEDAS: Array[String] = [
	"Orelha",
	"Turquesa",
	"Rublyof",
	"Lirios",
]

## Granos que vale cada moneda, en el mismo orden que DENOMINACIONES.
## Ejemplo: VALORES["Orelha"][2] = 10000 → un oro de Orelha.
const VALORES: Dictionary = {
	"Orelha": [100, 1000, 10000, 100000],
	"Turquesa": [10, 100, 1000, 10000],
	"Rublyof": [1, 10, 100, 1000],
	"Lirios": [0, 1, 10, 100],
}


## Comprueba que una moneda y una denominación existen.
static func existe_denominacion(moneda: String, denominacion: int) -> bool:

	if not VALORES.has(moneda):
		return false

	var valores: Array = VALORES[moneda]

	return denominacion >= 0 and denominacion < valores.size()


## Devuelve el valor en granos de una moneda y una denominación.
## Si la moneda o la denominación no existen, devuelve 0.
static func valor_en_granos(moneda: String, denominacion: int) -> int:

	if not existe_denominacion(moneda, denominacion):
		return 0

	var valores: Array = VALORES[moneda]

	return int(valores[denominacion])


## Devuelve el valor como texto listo para mostrar:
## 10000 → "100,00"; 100000 → "1.000,00"; 0 → "0,00".
static func valor_en_texto(moneda: String, denominacion: int) -> String:

	return granos_a_texto(
		valor_en_granos(moneda, denominacion)
	)


## Convierte granos (enteros) a texto con coma decimal y punto de miles.
static func granos_a_texto(granos: int) -> String:

	var absoluto := absi(granos)

	@warning_ignore("integer_division")
	var unidades := absoluto / 100

	var centavos := absoluto % 100

	var texto := _separar_miles(unidades)
	texto += "," + str(centavos).pad_zeros(2)

	if granos < 0:
		return "-" + texto

	return texto


## Pone un punto cada tres cifras: 100000 → "100.000".
static func _separar_miles(numero: int) -> String:

	var texto := str(numero)
	var resultado := ""
	var contador := 0

	for i in range(texto.length() - 1, -1, -1):

		resultado = texto[i] + resultado
		contador += 1

		if contador % 3 == 0 and i > 0:
			resultado = "." + resultado

	return resultado


# ==================================================
# CONVERSIÓN ENTRE MONEDAS
# ==================================================

## Convierte una cantidad de monedas a granos.
## Ejemplo: 3 oros de Orelha → 3 × 10000 = 30000 granos.
static func cantidad_a_granos(
	cantidad: int,
	moneda: String,
	denominacion: int
) -> int:

	return cantidad * valor_en_granos(moneda, denominacion)


## Convierte un importe de una moneda/denominación a otra.
##
## Devuelve un Dictionary con estas claves:
##   "valido"          → false si alguna moneda/denominación no existe
##                       o si el destino vale 0 (no se puede dividir).
##   "granos"          → valor total del importe de origen.
##   "cantidad"        → monedas completas de la denominación de destino.
##   "resto_granos"    → granos que no llegan a esa denominación.
##   "reparto"         → Array[int] con las monedas del destino, en el orden
##                       de DENOMINACIONES (0 = cobre ... 3 = platino).
##   "sobrante_granos" → granos que no se pueden representar con la moneda
##                       de destino (su moneda más pequeña vale más).
static func convertir(
	cantidad: int,
	moneda_origen: String,
	denominacion_origen: int,
	moneda_destino: String,
	denominacion_destino: int
) -> Dictionary:

	var reparto_vacio: Array[int] = []

	var resultado := {
		"valido": false,
		"granos": 0,
		"cantidad": 0,
		"resto_granos": 0,
		"reparto": reparto_vacio,
		"sobrante_granos": 0,
	}

	if cantidad < 0:
		return resultado

	if not existe_denominacion(moneda_origen, denominacion_origen):
		return resultado

	if not existe_denominacion(moneda_destino, denominacion_destino):
		return resultado

	var valor_destino := valor_en_granos(
		moneda_destino,
		denominacion_destino
	)

	if valor_destino <= 0:
		return resultado

	var granos := cantidad_a_granos(
		cantidad,
		moneda_origen,
		denominacion_origen
	)

	@warning_ignore("integer_division")
	var cantidad_destino := granos / valor_destino

	var resto := granos % valor_destino

	var reparto := repartir_en_denominaciones(
		granos,
		moneda_destino
	)

	var valores: Array = VALORES[moneda_destino]
	var sobrante := granos

	for i in reparto.size():
		sobrante -= reparto[i] * int(valores[i])

	resultado["valido"] = true
	resultado["granos"] = granos
	resultado["cantidad"] = cantidad_destino
	resultado["resto_granos"] = resto
	resultado["reparto"] = reparto
	resultado["sobrante_granos"] = sobrante

	return resultado


## Reparte una cantidad de granos en monedas de una moneda concreta.
## Devuelve un Array[int] en el mismo orden que DENOMINACIONES:
## índice 0 = cobre, 1 = plata, 2 = oro, 3 = platino.
## Ejemplo: 2340 granos en Turquesa → [4, 3, 2, 0]
## (2 oros, 3 platas y 4 cobres).
static func repartir_en_denominaciones(
	granos: int,
	moneda: String
) -> Array[int]:

	var reparto: Array[int] = []

	if not VALORES.has(moneda):
		return reparto

	var valores: Array = VALORES[moneda]

	for i in valores.size():
		reparto.append(0)

	if granos < 0:
		return reparto

	var restante := granos

	for i in range(valores.size() - 1, -1, -1):

		var valor := int(valores[i])

		if valor <= 0:
			continue

		@warning_ignore("integer_division")
		var cantidad := restante / valor

		reparto[i] = cantidad
		restante -= cantidad * valor

	return reparto


## Convierte un reparto en texto legible.
## Ejemplo: [4, 3, 2, 0] en Turquesa →
## "2 oros, 3 platas y 4 cobres de Turquesa".
static func texto_reparto(
	reparto: Array[int],
	moneda: String
) -> String:

	var partes: Array[String] = []

	for i in range(reparto.size() - 1, -1, -1):

		if i >= DENOMINACIONES.size():
			continue

		if reparto[i] <= 0:
			continue

		var nombre := DENOMINACIONES[i].to_lower()

		if reparto[i] != 1:
			nombre += "s"

		partes.append(str(reparto[i]) + " " + nombre)

	if partes.is_empty():
		return "0 " + DENOMINACIONES[0].to_lower() + "s de " + moneda

	return _unir_partes(partes) + " de " + moneda


## Une una lista de textos con comas y una "y" antes del último.
static func _unir_partes(partes: Array[String]) -> String:

	if partes.size() == 1:
		return partes[0]

	var texto := ""

	for i in partes.size():

		if i == 0:
			texto = partes[i]
		elif i == partes.size() - 1:
			texto += " y " + partes[i]
		else:
			texto += ", " + partes[i]

	return texto
