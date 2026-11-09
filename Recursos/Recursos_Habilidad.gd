class_name Habilidad
extends Resource
## Una habilidad propia de una criatura transformada.
##
## Es un [Resource]: solo datos, no un nodo. Todavía no tiene coste ni
## efectos; el sistema de puntos y la interacción llegan en el Bloque 8.

## Nombre corto de la habilidad (por ejemplo "Mordisco" o "Telaraña").
@export var nombre: String = ""

## Texto libre con el efecto o la descripción de la habilidad.
@export_multiline var descripcion: String = ""


## Limpia los espacios sobrantes de los textos.
func normalizar() -> void:

	nombre = nombre.strip_edges()
	descripcion = descripcion.strip_edges()


## True si tiene un nombre utilizable.
func es_valida() -> bool:

	return not nombre.strip_edges().is_empty()


## Texto corto para listas o mensajes de consola.
func texto_resumen() -> String:

	var nombre_visible := nombre

	if nombre_visible.is_empty():
		nombre_visible = "Sin nombre"

	if descripcion.is_empty():
		return nombre_visible

	return "%s — %s" % [nombre_visible, descripcion]
