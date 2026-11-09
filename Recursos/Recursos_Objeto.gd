class_name Objeto
extends Resource
## Representa un objeto del inventario del constructo.
##
## Es un [Resource], así que solo contiene datos: no es un nodo
## y no se dibuja en la escena.

## Categorías válidas para clasificar los objetos.
## Se usan tanto en el formulario como en el filtro, para no repetir textos.
const CATEGORIAS: Array[String] = [
	"Consumible",
	"Equipo",
	"Herramienta",
	"Material",
	"Tesoro",
	"Misceláneo",
]

## Nombre visible del objeto (por ejemplo, "Poción de curación").
@export var nombre: String = ""

## Categoría para agrupar y filtrar objetos (por ejemplo, "Consumible").
@export var categoria: String = "Misceláneo"

## Cuántas unidades hay. Nunca debería ser menor que 1.
@export_range(1, 9999, 1) var cantidad: int = 1

## Coste en piezas de oro o en la moneda del cofi (0 = gratis).
@export_range(0, 999999, 1) var costo: int = 0

## Descripción libre del objeto.
@export_multiline var descripcion: String = ""
