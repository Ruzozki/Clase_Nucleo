class_name Fase 
extends Resource

## Una fase de evolución de una criatura.
##
## Cada criatura tiene 4 fases. Al tirar el d100 siempre aparece en la fase 1;
## las fases 2, 3 y 4 se alcanzan gastando PT si el Núcleo tiene nivel.


## Número de la fase, del 1 al 4.
@export_range(1, 4, 1) var numero: int = 1

## Nombre de esta evolución. Si está vacío, se usa el de la criatura.
@export var nombre: String = ""

## Imagen de esta evolución. Si está vacía, se usa la de la criatura.
@export var imagen: Texture2D

## Nivel mínimo del Núcleo para poder alcanzar esta fase.
@export_range(1, 20, 1) var nivel_requerido: int = 1

## Puntos de Transformación (PT) que cuesta evolucionar a esta fase.
## En la fase 1 debe ser 0, porque sale directamente con el d100.
@export_range(0, 999, 1) var coste_pt: int = 0


@export_group("Estadísticas")

## Clase de Armadura (CA) en esta fase.
@export_range(0, 99, 1) var ca: int = 10

## Puntos de Golpe (PG) máximos en esta fase.
@export_range(1, 9999, 1) var pg: int = 1

## Velocidad como texto libre, por ejemplo "9 m" o "9 m, volar 12 m".
@export var velocidad: String = "9 m"

@export_subgroup("Atributos")

## Fuerza (FUE).
@export_range(1, 30, 1) var fuerza: int = 10

## Destreza (DES).
@export_range(1, 30, 1) var destreza: int = 10

## Constitución (CON).
@export_range(1, 30, 1) var constitucion: int = 10

## Inteligencia (INT).
@export_range(1, 30, 1) var inteligencia: int = 10

## Sabiduría (SAB).
@export_range(1, 30, 1) var sabiduria: int = 10

## Carisma (CAR).
@export_range(1, 30, 1) var carisma: int = 10


@export_group("Competencias")

## Tiradas de salvación en las que esta fase es competente.
## Cada casilla marcada suma el bono de competencia a esa salvación.
## El orden debe coincidir con ReglasDnD.ATRIBUTOS.
@export_flags("FUE", "DES", "CON", "INT", "SAB", "CAR") var salvaciones_competentes: int = 0

## Pericias en las que esta fase es competente.
## El orden debe coincidir con ReglasDnD.PERICIAS.
@export_flags("Acrobacias", "Atletismo", "Conocimiento Arcano", "Engaño", "Historia", "Interpretación", "Intimidación", "Investigación", "Juego de Manos", "Medicina", "Naturaleza", "Percepción", "Perspicacia", "Persuasión", "Religión", "Sigilo", "Supervivencia", "Trato con Animales") var pericias_competentes: int = 0




## Limpia los textos y mantiene cada número dentro de su rango.
func normalizar() -> void:

	numero = clampi(numero, 1, 4)
	nombre = nombre.strip_edges()
	nivel_requerido = clampi(nivel_requerido, 1, 20)
	coste_pt = maxi(coste_pt, 0)

	# La fase 1 sale con el d100: nunca cuesta PT.
	if numero == 1:
		coste_pt = 0

	ca = clampi(ca, 0, 99)
	pg = clampi(pg, 1, 9999)
	velocidad = velocidad.strip_edges()

	if velocidad.is_empty():
		velocidad = "9 m"

	fuerza = clampi(fuerza, 1, 30)
	destreza = clampi(destreza, 1, 30)
	constitucion = clampi(constitucion, 1, 30)
	inteligencia = clampi(inteligencia, 1, 30)
	sabiduria = clampi(sabiduria, 1, 30)
	carisma = clampi(carisma, 1, 30)


## True si el número de fase está entre 1 y 4.
func es_valida() -> bool:

	return numero >= 1 and numero <= 4


## Valor de un atributo a partir de su abreviatura: "DES" → destreza.
func valor_atributo(atributo: String) -> int:

	match atributo:
		"FUE":
			return fuerza
		"DES":
			return destreza
		"CON":
			return constitucion
		"INT":
			return inteligencia
		"SAB":
			return sabiduria
		"CAR":
			return carisma

	return 0


## True si la casilla de salvación de ese atributo está marcada.
func es_competente_salvacion(atributo: String) -> bool:

	var indice := ReglasDnD.ATRIBUTOS.find(atributo)

	if indice == -1:
		return false

	return (salvaciones_competentes & (1 << indice)) != 0


## True si la casilla de esa pericia está marcada.
func es_competente_pericia(nombre_pericia: String) -> bool:

	var indice := ReglasDnD.nombres_pericias().find(nombre_pericia)

	if indice == -1:
		return false

	return (pericias_competentes & (1 << indice)) != 0


## Modificador de salvación: modificador del atributo + bono si es competente.
func valor_salvacion(atributo: String, bono: int) -> int:

	var total := ReglasDnD.modificador(valor_atributo(atributo))

	if es_competente_salvacion(atributo):
		total += bono

	return total


## Modificador de pericia: modificador de su atributo + bono si es competente.
func valor_pericia(nombre_pericia: String, bono: int) -> int:

	var atributo := ReglasDnD.atributo_de_pericia(nombre_pericia)
	var total := ReglasDnD.modificador(valor_atributo(atributo))

	if es_competente_pericia(nombre_pericia):
		total += bono

	return total
