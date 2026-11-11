class_name EstadoNucleo
extends RefCounted
## Estado actual del Núcleo durante la partida.
##
## Solo guarda datos y los cambia con funciones pequeñas. No sabe nada de la
## pantalla: la escena lo lee para mostrarlo.


## Los estados posibles del Núcleo.
enum Estado {
	NUCLEO,
	TRANSFORMADO,
	SOBRECALENTAMIENTO,
	REINICIO,
}

## Nombres para mostrar. El orden es el del enum.
const NOMBRES_ESTADO: Array[String] = [
	"Núcleo",
	"Transformado",
	"Sobrecalentamiento",
	"Reinicio",
]

## Tope de Puntos de Mutación.
const PM_MAXIMO: int = 25

## Puntos de Transformación con los que empieza el Núcleo.
const PT_INICIALES: int = 2

## Tramos de riesgo de mutación. Cada fila es [PM desde, % de mutar].
## Deben ir ordenadas de menor a mayor. Se editan al equilibrar.
const TRAMOS_RIESGO: Array = [
	[0, 0],
	[5, 5],
	[10, 15],
	[15, 30],
	[20, 50],
	[25, 100],
]

## Estado actual: forma base, transformado, mutado o reiniciándose.
var estado: Estado = Estado.NUCLEO

## Puntos de Transformación disponibles.
var pt: int = PT_INICIALES

## Puntos de Mutación acumulados (0 – PM_MAXIMO).
var pm: int = 0

## Criatura en la que está transformado. Null si es el Núcleo.
var criatura_actual: Criatura = null

## Mutación activa. Null si no está mutado.
var mutacion_actual: Mutacion = null

## Turnos que quedan del sobrecalentamiento o del reinicio.
var turnos_restantes: int = 0


## Nombre del estado actual para mostrar en pantalla.
func nombre_estado() -> String:

	return NOMBRES_ESTADO[estado]

## Suma PM al usar una habilidad. Devuelve cuántos se sumaron de verdad.
## Solo acumula si el Núcleo está transformado: en Núcleo, sobrecalentamiento
## o reinicio no se suma nada.
func sumar_pm(cantidad: int) -> int:

	if estado != Estado.TRANSFORMADO:
		return 0

	if cantidad <= 0:
		return 0

	var antes := pm
	pm = mini(pm + cantidad, PM_MAXIMO)

	return pm - antes


## True si los PM llegaron al tope.
func pm_al_maximo() -> bool:

	return pm >= PM_MAXIMO

## Porcentaje de mutar con los PM actuales, según la tabla de tramos.
func probabilidad_mutacion() -> int:

	var porcentaje := 0

	for tramo in TRAMOS_RIESGO:

		var desde: int = tramo[0]
		var valor: int = tramo[1]

		if pm >= desde:
			porcentaje = valor

	return porcentaje

## True si, con esa tirada del dado de mutación, la criatura muta.
## Muta si la tirada es igual o menor que el porcentaje de riesgo actual.
## Solo puede mutar si está transformado.
func muta_con_tirada(tirada: int) -> bool:

	if estado != Estado.TRANSFORMADO:
		return false

	return tirada <= probabilidad_mutacion()

## Se transforma en una criatura: empieza sin mutación y con los PM a 0.
## Con null vuelve a ser el Núcleo.
func transformar_en(criatura: Criatura) -> void:

	criatura_actual = criatura
	mutacion_actual = null
	turnos_restantes = 0
	pm = 0

	if criatura == null:
		estado = Estado.NUCLEO
	else:
		estado = Estado.TRANSFORMADO


## Empieza una mutación: sobrecalentamiento, PM a 0 y los turnos de la mutación.
## Solo funciona si está transformado.
func empezar_mutacion(mutacion: Mutacion) -> void:

	if estado != Estado.TRANSFORMADO or mutacion == null:
		return

	mutacion_actual = mutacion
	estado = Estado.SOBRECALENTAMIENTO
	pm = 0
	turnos_restantes = mutacion.duracion_turnos
