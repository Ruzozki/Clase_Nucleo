class_name Mutacion
extends Resource
## Una mutación de una criatura.
##
## Cada criatura tiene 2: una positiva y una negativa. Es un [Resource]:
## solo datos. Al mutar se sortea una de las dos.


## Nombre de la mutación (por ejemplo "Piel de espinas").
@export var nombre: String = ""

## Si la mutación ayuda o perjudica a la criatura.
@export_enum("Positiva", "Negativa") var tipo: String = "Positiva"

## Qué riesgo o desventaja trae.
@export_multiline var riesgo: String = ""

## Qué recompensa o ventaja da.
@export_multiline var recompensa: String = ""

## Imagen de la criatura mientras dure la mutación. Puede quedarse vacía.
@export var imagen: Texture2D

## Turnos que dura la mutación (el sobrecalentamiento) durante un combate.
@export_range(1, 20, 1) var duracion_turnos: int = 3

@export_group("Modificadores de estadísticas")

## Cambio a la Clase de Armadura. Con 0 no cambia.
@export_range(-10, 10, 1) var mod_ca: int = 0

## Cambio a los Puntos de Golpe máximos. Con 0 no cambia.
@export_range(-50, 50, 1) var mod_pg: int = 0

@export_subgroup("Atributos")

## Cambio a la Fuerza (FUE).
@export_range(-10, 10, 1) var mod_fuerza: int = 0

## Cambio a la Destreza (DES).
@export_range(-10, 10, 1) var mod_destreza: int = 0

## Cambio a la Constitución (CON).
@export_range(-10, 10, 1) var mod_constitucion: int = 0

## Cambio a la Inteligencia (INT).
@export_range(-10, 10, 1) var mod_inteligencia: int = 0

## Cambio a la Sabiduría (SAB).
@export_range(-10, 10, 1) var mod_sabiduria: int = 0

## Cambio al Carisma (CAR).
@export_range(-10, 10, 1) var mod_carisma: int = 0

## Limpia los espacios sobrantes de los textos.
func normalizar() -> void:

	nombre = nombre.strip_edges()
	riesgo = riesgo.strip_edges()
	recompensa = recompensa.strip_edges()


## True si tiene un nombre utilizable.
func es_valida() -> bool:

	return not nombre.strip_edges().is_empty()


## True si es una mutación positiva.
func es_positiva() -> bool:

	return tipo == "Positiva"

## Texto con los cambios, por ejemplo "CA +1, FUE -2". Si no hay, "Sin cambios".
func texto_modificadores() -> String:

	var pares: Array = [
		["CA", mod_ca],
		["PG", mod_pg],
		["FUE", mod_fuerza],
		["DES", mod_destreza],
		["CON", mod_constitucion],
		["INT", mod_inteligencia],
		["SAB", mod_sabiduria],
		["CAR", mod_carisma],
	]

	var partes: Array[String] = []

	for par in pares:

		var etiqueta: String = par[0]
		var valor: int = par[1]

		if valor != 0:
			partes.append(
				"%s %s" % [etiqueta, ReglasDnD.texto_modificador(valor)]
			)

	if partes.is_empty():
		return "Sin cambios"

	return ", ".join(partes)
