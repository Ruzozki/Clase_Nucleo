class_name Tirada
extends RefCounted
## Resultado de una tirada de habilidad, listo para pintar o guardar.
##
## No tira los dados: los recibe ya tirados. Así la tarjeta, el historial
## y una futura animación usan exactamente el mismo resultado.


var etiqueta: String = ""
var modo: int = Dados.Modo.NORMAL
var dados: Array[int] = []
var bono: int = 0
var base: int = 0
var total: int = 0
## Índice del dado que cuenta en ventaja o desventaja.
var indice_usado: int = -1
var critico: bool = false
var pifia: bool = false


## Monta el resultado a partir de los dados ya tirados.
static func crear(
	p_etiqueta: String,
	p_modo: int,
	p_dados: Array[int],
	p_bono: int
) -> Tirada:

	var tirada := Tirada.new()
	tirada.etiqueta = p_etiqueta
	tirada.modo = p_modo
	tirada.dados = p_dados
	tirada.bono = p_bono
	tirada.base = Dados.resultado_d20(p_dados, p_modo)
	tirada.total = tirada.base + p_bono

	for i in p_dados.size():

		if p_dados[i] == tirada.base:
			tirada.indice_usado = i
			break

	tirada.critico = tirada.base == Dados.DADO_HABILIDAD
	tirada.pifia = tirada.base == 1

	return tirada


## Texto corto del modo: "Normal", "Ventaja" o "Desventaja".
func nombre_modo() -> String:

	match modo:
		Dados.Modo.VENTAJA:
			return "Ventaja"
		Dados.Modo.DESVENTAJA:
			return "Desventaja"

	return "Normal"


## Todos los dados en una línea: "12" o "12/18".
func texto_dados() -> String:

	var texto := ""

	for dado in dados:

		if not texto.is_empty():
			texto += "/"

		texto += str(dado)

	return texto


## " + 2", " - 1" o "" si el bono es 0.
func texto_bono() -> String:

	if bono == 0:
		return ""

	return " " + ReglasDnD.texto_modificador(bono)
