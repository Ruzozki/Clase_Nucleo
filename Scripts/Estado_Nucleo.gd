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
const PT_INICIALES: int = 1

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

## Nivel actual del Núcleo.
var nivel: int = 1

## PT extra que suman los hitos.
var bonos_pt: int = 0

## Números de criatura ya registrados (1–100), sin repetir.
var criaturas_registradas: Array[int] = []

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

## PT máximos: nivel del Núcleo más lo que den los hitos.
func pt_maximos() -> int:

	return maxi(nivel + bonos_pt, 0)


## Coste de la siguiente tirada del d100. La primera es gratis.
func coste_d100() -> int:

	if criaturas_registradas.is_empty():
		return 0

	return 1


## True si hay PT para pagar la siguiente tirada.
func puede_tirar_d100() -> bool:

	return pt >= coste_d100()


## Gasta PT si alcanza. Devuelve true si se pudo pagar.
func gastar_pt(cantidad: int) -> bool:

	if cantidad <= 0:
		return true

	if pt < cantidad:
		return false

	pt -= cantidad
	return true


## Guarda una criatura como registrada. Devuelve true si era nueva.
func registrar_criatura(numero: int) -> bool:

	if numero < 1 or numero > 100:
		return false

	if criaturas_registradas.has(numero):
		return false

	criaturas_registradas.append(numero)
	criaturas_registradas.sort()
	return true


## Mantiene el estado dentro de sus límites.
func normalizar() -> void:

	nivel = clampi(nivel, 1, 20)
	bonos_pt = maxi(bonos_pt, 0)
	criaturas_registradas.sort()
	pt = clampi(pt, 0, pt_maximos())
	
