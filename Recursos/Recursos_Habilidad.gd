class_name Habilidad
extends Resource
## Una habilidad propia de una criatura transformada.
##
## Es un [Resource]: solo datos, no un nodo. Todavía no tiene coste ni
## efectos; el sistema de puntos y la interacción llegan en el Bloque 8.

## Tipos de acción de una habilidad. Cada uno es un bit distinto, así se
## pueden combinar (por ejemplo ACCION + PASIVA).
const ACCION: int = 1
const ADICIONAL: int = 2
const REACCION: int = 4
const PASIVA: int = 8

## Nombres para mostrar. El orden es el de los bits: 1, 2, 4, 8.
const NOMBRES_TIPO_ACCION: Array[String] = [
	"Acción",
	"Acción adicional",
	"Reacción",
	"Pasiva",
]

## Número de la criatura a la que pertenece esta habilidad (1–100).
@export_range(1, 100, 1) var criatura: int = 1

## Fase en la que se desbloquea. Por ahora siempre es 1: las fases quedan para más adelante.
@export_range(1, 4, 1) var fase: int = 1

## Orden de la habilidad dentro de su criatura y fase (1–99).
@export_range(1, 99, 1) var orden: int = 1

## Tipos de acción. Se pueden marcar varios: "Acción" y "Pasiva", por ejemplo.
@export_flags("Acción", "Acción adicional", "Reacción", "Pasiva") var tipos_accion: int = ACCION

## Puntos de Mutación (PM) que suma al usarla. Con 0 no acumula nada.
@export_range(0, 25, 1) var coste_pm: int = 0

## Alcance como texto libre, por ejemplo "Toque", "9 m" o "Personal".
@export var alcance: String = ""

## Duración como texto libre, por ejemplo "Instantánea" o "3 turnos".
@export var duracion: String = ""

## Tirada o daño como texto libre, por ejemplo "2d6 cortante" o "Cura 1d4".
@export var tirada: String = ""

## Atributo de la tirada de salvación del objetivo. "Ninguna" si no hay.
@export_enum("Ninguna", "FUE", "DES", "CON", "INT", "SAB", "CAR") var salvacion_atributo: String = "Ninguna"

## CD de la salvación. Con 0 se usará la CD del Núcleo (todavía no existe).
@export_range(0, 30, 1) var salvacion_cd: int = 0 

## Nombre corto de la habilidad (por ejemplo "Mordisco" o "Telaraña").
@export var nombre: String = ""

## Texto libre con el efecto o la descripción de la habilidad.
@export_multiline var descripcion: String = ""


## Limpia los espacios sobrantes de los textos.
func normalizar() -> void:

	nombre = nombre.strip_edges()
	descripcion = descripcion.strip_edges()
	alcance = alcance.strip_edges()
	duracion = duracion.strip_edges()
	tirada = tirada.strip_edges()


## True si tiene un nombre utilizable.
func es_valida() -> bool:

	return not nombre.strip_edges().is_empty()

## Identificador calculado con el formato NNN-F-OO. Ejemplo: "001-1-03".
func obtener_id() -> String:

	return "%03d-%d-%02d" % [criatura, fase, orden]

## True si la habilidad tiene marcado ese tipo (usa ACCION, PASIVA…).
func tiene_tipo(tipo: int) -> bool:

	return (tipos_accion & tipo) != 0


## True si la habilidad tiene marcada la opción "Pasiva".
func es_pasiva() -> bool:

	return tiene_tipo(PASIVA)


## Texto con los tipos marcados, por ejemplo "Acción + Pasiva".
func texto_tipos_accion() -> String:

	var nombres: Array[String] = []

	for i in NOMBRES_TIPO_ACCION.size():
		if tipos_accion & (1 << i) != 0:
			nombres.append(NOMBRES_TIPO_ACCION[i])

	if nombres.is_empty():
		return "Sin tipo"

	return " + ".join(nombres)

## True si usar la habilidad suma PM.
func acumula_pm() -> bool:

	return coste_pm > 0

## Texto del coste para botones y fichas, por ejemplo "3 PM" o "Sin coste".
func texto_coste() -> String:

	if coste_pm <= 0:
		return "Sin coste"

	return "%d PM" % coste_pm

## True si la habilidad obliga a hacer una tirada de salvación.
func tiene_salvacion() -> bool:

	return salvacion_atributo != "Ninguna"


## Texto de la salvación, por ejemplo "Salvación DES CD 13".
func texto_salvacion() -> String:

	if not tiene_salvacion():
		return "Sin salvación"

	if salvacion_cd <= 0:
		return "Salvación %s (CD del Núcleo)" % salvacion_atributo

	return "Salvación %s CD %d" % [salvacion_atributo, salvacion_cd]
	
## Texto corto para listas o mensajes de consola.
func texto_resumen() -> String:

	var nombre_visible := nombre

	if nombre_visible.is_empty():
		nombre_visible = "Sin nombre"

	if descripcion.is_empty():
		return nombre_visible

	return "%s — %s" % [nombre_visible, descripcion]
