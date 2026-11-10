extends Control


# ==================================================
# CLASE NÚCLEO
# ==================================================
#
# Control inicial de la ventana de objetos.
#
# Esta versión no utiliza:
# - Nombres únicos con %.
# - Rutas directas escritas dentro del código.
#
# Las rutas se asignan desde el Inspector.
# ==================================================


# ==================================================
# RUTAS ASIGNABLES DESDE EL INSPECTOR
# ==================================================

@export_category("Ventana de objetos")

@export_node_path("Window")
var ruta_ventana_objeto: NodePath

@export_node_path("Button")
var ruta_boton_nuevo_objeto: NodePath

@export_node_path("Button")
var ruta_boton_cancelar_objeto: NodePath

@export_node_path("Button")
var ruta_boton_guardar_objeto: NodePath


@export_category("Formulario de objetos")

@export_node_path("LineEdit")
var ruta_entrada_nombre: NodePath

@export_node_path("SpinBox")
var ruta_entrada_cantidad: NodePath

@export_node_path("LineEdit")
var ruta_entrada_descripcion: NodePath

@export_node_path("OptionButton")
var ruta_opcion_categoria: NodePath

@export_node_path("SpinBox")
var ruta_entrada_costo: NodePath


@export_category("Lista de objetos")

@export_node_path("ItemList")
var ruta_lista_objetos: NodePath


@export_category("Detalle del objeto")

@export_node_path("Label")
var ruta_nombre_detalle: NodePath

@export_node_path("Label")
var ruta_categoria_detalle: NodePath

@export_node_path("Label")
var ruta_cantidad_detalle: NodePath

@export_node_path("Label")
var ruta_descripcion_detalle: NodePath

@export_node_path("Label")
var ruta_costo_detalle: NodePath


@export_category("Buscador y filtros")

@export_node_path("LineEdit")
var ruta_entrada_buscador: NodePath

@export_node_path("OptionButton")
var ruta_filtro_categoria: NodePath

@export_category("Acciones del objeto")

@export_node_path("Button")
var ruta_boton_editar_objeto: NodePath

@export_node_path("Button")
var ruta_boton_eliminar_objeto: NodePath

@export_category("Monedas")

@export_node_path("GridContainer")
var ruta_tabla_monedas: NodePath

@export_category("Transformaciones (d100)")

@export_node_path("Label")
var ruta_resultado_d100: NodePath

@export_node_path("Button")
var ruta_boton_tirar_d100: NodePath

@export_node_path("Label")
var ruta_mensaje_duplicada: NodePath

@export_node_path("Label")
var ruta_etiqueta_criatura: NodePath

@export_node_path("Button")
var ruta_boton_estadisticas: NodePath

@export_node_path("Window")
var ruta_ventana_estadisticas: NodePath

@export_node_path("TextureRect")
var ruta_imagen_criatura: NodePath

@export_node_path("Label")
var ruta_titulo_estadisticas: NodePath

@export_node_path("GridContainer")
var ruta_grid_estadisticas: NodePath

@export_node_path("VBoxContainer")
var ruta_lista_habilidades: NodePath

# ==================================================
# REFERENCIAS INTERNAS
# ==================================================

var ventana_objeto: Window
var boton_nuevo_objeto: Button
var boton_cancelar_objeto: Button
var boton_guardar_objeto: Button

var entrada_nombre: LineEdit
var entrada_cantidad: SpinBox
var entrada_descripcion: LineEdit
var opcion_categoria: OptionButton
var entrada_costo: SpinBox

var lista_objetos: ItemList

var nombre_detalle: Label
var categoria_detalle: Label
var cantidad_detalle: Label
var descripcion_detalle: Label
var costo_detalle: Label

var entrada_buscador: LineEdit
var filtro_categoria: OptionButton
var tabla_monedas: GridContainer
var boton_editar_objeto: Button
var boton_eliminar_objeto: Button

var etiqueta_resultado_d100: Label
var boton_tirar_d100: Button
var etiqueta_duplicada: Label
var etiqueta_criatura: Label
var boton_estadisticas: Button
var ventana_estadisticas: Window
var imagen_criatura: TextureRect
var titulo_estadisticas: Label
var grid_estadisticas: GridContainer
var lista_habilidades: VBoxContainer
var dialogo_habilidad: AcceptDialog

var dialogo_aviso: AcceptDialog
## Diálogo que pide confirmación antes de eliminar.
var dialogo_confirmacion: ConfirmationDialog


# ==================================================
# ALMACENAMIENTO
# ==================================================

## Archivo donde se guarda el inventario (ruta virtual de Godot).
const RUTA_INVENTARIO: String = "user://inventario.json"
var objetos: Array[Objeto] = []
## Objeto seleccionado en la lista, o null si no hay ninguno.
var objeto_seleccionado: Objeto = null
## Objeto que se borrará si el usuario confirma.
var objeto_a_eliminar: Objeto = null
## Objeto que se está editando en la ventana, o null si se está creando.
var objeto_en_edicion: Objeto = null

## Archivo donde se guarda el estado del d100 de transformación.
const RUTA_D100: String = "user://d100.json"
## Última tirada del d100, o 0 si todavía no hay ninguna.
var ultima_tirada_d100: int = 0
## Las 5 últimas tiradas del d100, de la más nueva a la más vieja.
var historial_d100: Array[int] = []
## True mientras la animación del d100 está en curso (bloquea el botón).
var tirada_d100_en_curso: bool = false

## Carpeta con los archivos .tres de cada criatura.
const RUTA_CRIATURAS: String = "res://Recursos/Criaturas"
## Criaturas cargadas al arrancar, ordenadas por número.
var criaturas: Array[Criatura] = []

# ==================================================
# INICIALIZACIÓN
# ==================================================

func _ready() -> void:

	crear_dialogo_aviso()
	crear_dialogo_confirmacion()
	crear_dialogo_habilidad()
	if not cargar_referencias():
		return

	conectar_botones()
	cargar_categorias()
	cargar_filtro_categorias()
	cargar_tabla_monedas()
	ventana_objeto.hide()
	ventana_estadisticas.hide()
	
	cargar_inventario()
	cargar_d100()
	cargar_criaturas()
	actualizar_lista_objetos()
	actualizar_panel_d100()


func crear_dialogo_aviso() -> void:

	dialogo_aviso = AcceptDialog.new()
	dialogo_aviso.title = "Aviso"
	add_child(dialogo_aviso)

func crear_dialogo_confirmacion() -> void:

	dialogo_confirmacion = ConfirmationDialog.new()
	dialogo_confirmacion.title = "Eliminar objeto"
	dialogo_confirmacion.ok_button_text = "Eliminar"
	dialogo_confirmacion.cancel_button_text = "Cancelar"
	add_child(dialogo_confirmacion)

	dialogo_confirmacion.confirmed.connect(
		_on_confirmacion_eliminar_confirmada
	)
	dialogo_confirmacion.canceled.connect(
		_on_confirmacion_eliminar_cancelada
	)
	

func crear_dialogo_habilidad() -> void:

	dialogo_habilidad = AcceptDialog.new()
	dialogo_habilidad.title = "Habilidad"
	dialogo_habilidad.ok_button_text = "Cerrar"
	add_child(dialogo_habilidad)

func cargar_categorias() -> void:

	opcion_categoria.clear()

	for categoria in Objeto.CATEGORIAS:
		opcion_categoria.add_item(categoria)

	opcion_categoria.select(0)


func cargar_filtro_categorias() -> void:

	filtro_categoria.clear()
	filtro_categoria.add_item("Todas")

	for categoria in Objeto.CATEGORIAS:
		filtro_categoria.add_item(categoria)

	filtro_categoria.select(0)


# ==================================================
# CARGAR REFERENCIAS
# ==================================================

func cargar_referencias() -> bool:

	ventana_objeto = get_node_or_null(
		ruta_ventana_objeto
	) as Window

	boton_nuevo_objeto = get_node_or_null(
		ruta_boton_nuevo_objeto
	) as Button

	boton_cancelar_objeto = get_node_or_null(
		ruta_boton_cancelar_objeto
	) as Button

	boton_guardar_objeto = get_node_or_null(
		ruta_boton_guardar_objeto
	) as Button

	entrada_nombre = get_node_or_null(
		ruta_entrada_nombre
	) as LineEdit

	entrada_cantidad = get_node_or_null(
		ruta_entrada_cantidad
	) as SpinBox

	entrada_descripcion = get_node_or_null(
		ruta_entrada_descripcion
	) as LineEdit

	opcion_categoria = get_node_or_null(
		ruta_opcion_categoria
	) as OptionButton

	entrada_costo = get_node_or_null(
		ruta_entrada_costo
	) as SpinBox

	lista_objetos = get_node_or_null(
		ruta_lista_objetos
	) as ItemList

	nombre_detalle = get_node_or_null(
		ruta_nombre_detalle
	) as Label

	categoria_detalle = get_node_or_null(
		ruta_categoria_detalle
	) as Label

	cantidad_detalle = get_node_or_null(
		ruta_cantidad_detalle
	) as Label

	descripcion_detalle = get_node_or_null(
		ruta_descripcion_detalle
	) as Label

	costo_detalle = get_node_or_null(
		ruta_costo_detalle
	) as Label

	entrada_buscador = get_node_or_null(
		ruta_entrada_buscador
	) as LineEdit

	filtro_categoria = get_node_or_null(
		ruta_filtro_categoria
	) as OptionButton

	tabla_monedas = get_node_or_null(
		ruta_tabla_monedas
	) as GridContainer

	etiqueta_resultado_d100 = get_node_or_null(
		ruta_resultado_d100
	) as Label

	boton_tirar_d100 = get_node_or_null(
		ruta_boton_tirar_d100
	) as Button

	etiqueta_duplicada = get_node_or_null(
		ruta_mensaje_duplicada
	) as Label

	etiqueta_criatura = get_node_or_null(
		ruta_etiqueta_criatura
	) as Label

	boton_estadisticas = get_node_or_null(
		ruta_boton_estadisticas
	) as Button

	ventana_estadisticas = get_node_or_null(
		ruta_ventana_estadisticas
	) as Window

	imagen_criatura = get_node_or_null(
		ruta_imagen_criatura
	) as TextureRect

	titulo_estadisticas = get_node_or_null(
		ruta_titulo_estadisticas
	) as Label

	grid_estadisticas = get_node_or_null(
		ruta_grid_estadisticas
	) as GridContainer

	lista_habilidades = get_node_or_null(
		ruta_lista_habilidades
	) as VBoxContainer

	boton_editar_objeto = get_node_or_null(
		ruta_boton_editar_objeto
	) as Button

	boton_eliminar_objeto = get_node_or_null(
		ruta_boton_eliminar_objeto
	) as Button

	if ventana_objeto == null:
		push_error(
			"No se asignó correctamente Ventana_Objeto."
		)
		return false

	if boton_nuevo_objeto == null:
		push_error(
			"No se asignó correctamente Boton_Nuevo_Objeto."
		)
		return false

	if boton_cancelar_objeto == null:
		push_error(
			"No se asignó correctamente Boton_Cancelar_Objeto."
		)
		return false

	if boton_guardar_objeto == null:
		push_error(
			"No se asignó correctamente Boton_Guardar_Objeto."
		)
		return false

	if entrada_nombre == null:
		push_error(
			"No se asignó correctamente Entrada_Nombre."
		)
		return false

	if entrada_cantidad == null:
		push_error(
			"No se asignó correctamente Entrada_Cantidad."
		)
		return false

	if entrada_descripcion == null:
		push_error(
			"No se asignó correctamente Entrada_Descripcion."
		)
		return false

	if opcion_categoria == null:
		push_error(
			"No se asignó correctamente Opcion_Categoria."
		)
		return false

	if entrada_costo == null:
		push_error(
			"No se asignó correctamente Entrada_Costo."
		)
		return false

	if lista_objetos == null:
		push_error(
			"No se asignó correctamente Lista_Objetos."
		)
		return false

	if nombre_detalle == null:
		push_error(
			"No se asignó correctamente Nombre_Detalle."
		)
		return false

	if categoria_detalle == null:
		push_error(
			"No se asignó correctamente Categoria_Detalle."
		)
		return false

	if cantidad_detalle == null:
		push_error(
			"No se asignó correctamente Cantidad_Detalle."
		)
		return false

	if descripcion_detalle == null:
		push_error(
			"No se asignó correctamente Descripcion_Detalle."
		)
		return false

	if costo_detalle == null:
		push_error(
			"No se asignó correctamente Costo_Detalle."
		)
		return false

	if entrada_buscador == null:
		push_error(
			"No se asignó correctamente Entrada_Buscador."
		)
		return false

	if filtro_categoria == null:
		push_error(
			"No se asignó correctamente Filtro_Categoria."
		)
		return false

	if tabla_monedas == null:
		push_error(
			"No se asignó correctamente Tabla_Monedas."
		)
		return false

	if etiqueta_resultado_d100 == null:
		push_error(
			"No se asignó correctamente Resultado_D100."
		)
		return false

	if boton_tirar_d100 == null:
		push_error(
			"No se asignó correctamente Boton_Tirar_D100."
		)
		return false

	if etiqueta_duplicada == null:
		push_error(
			"No se asignó correctamente Mensaje_Duplicada."
		)
		return false

	if etiqueta_criatura == null:
		push_error(
			"No se asignó correctamente Etiqueta_Criatura."
		)
		return false

	if boton_estadisticas == null:
		push_error(
			"No se asignó correctamente Boton_Estadisticas."
		)
		return false

	if ventana_estadisticas == null:
		push_error(
			"No se asignó correctamente Ventana_Estadisticas."
		)
		return false

	if imagen_criatura == null:
		push_error(
			"No se asignó correctamente Imagen_Criatura."
		)
		return false

	if titulo_estadisticas == null:
		push_error(
			"No se asignó correctamente Titulo_Estadisticas."
		)
		return false

	if grid_estadisticas == null:
		push_error(
			"No se asignó correctamente Grid_Estadisticas."
		)
		return false

	if lista_habilidades == null:
		push_error(
			"No se asignó correctamente Lista_Habilidades."
		)
		return false

	if boton_editar_objeto == null:
		push_error(
			"No se asignó correctamente Boton_Editar_Objeto."
		)
		return false

	if boton_eliminar_objeto == null:
		push_error(
			"No se asignó correctamente Boton_Eliminar_Objeto."
		)
		return false
	
	return true


# ==================================================
# CONECTAR SEÑALES
# ==================================================

func conectar_botones() -> void:

	if not boton_nuevo_objeto.pressed.is_connected(
		_on_boton_nuevo_objeto_pressed
	):
		boton_nuevo_objeto.pressed.connect(
			_on_boton_nuevo_objeto_pressed
		)

	if not boton_cancelar_objeto.pressed.is_connected(
		_on_boton_cancelar_objeto_pressed
	):
		boton_cancelar_objeto.pressed.connect(
			_on_boton_cancelar_objeto_pressed
		)

	if not boton_guardar_objeto.pressed.is_connected(
		_on_boton_guardar_objeto_pressed
	):
		boton_guardar_objeto.pressed.connect(
			_on_boton_guardar_objeto_pressed
		)
	if not boton_editar_objeto.pressed.is_connected(
		_on_boton_editar_objeto_pressed
	):
		boton_editar_objeto.pressed.connect(
			_on_boton_editar_objeto_pressed
		)
	if not boton_eliminar_objeto.pressed.is_connected(
		_on_boton_eliminar_objeto_pressed
	):
		boton_eliminar_objeto.pressed.connect(
			_on_boton_eliminar_objeto_pressed
		)

	if not boton_tirar_d100.pressed.is_connected(
		_on_boton_tirar_d100_pressed
	):
		boton_tirar_d100.pressed.connect(
			_on_boton_tirar_d100_pressed
		)

	if not boton_estadisticas.pressed.is_connected(
		_on_boton_estadisticas_pressed
	):
		boton_estadisticas.pressed.connect(
			_on_boton_estadisticas_pressed
		)

	if not ventana_estadisticas.close_requested.is_connected(
		_on_ventana_estadisticas_close_requested
	):
		ventana_estadisticas.close_requested.connect(
			_on_ventana_estadisticas_close_requested
		)
	
	if not lista_objetos.item_selected.is_connected(
		_on_lista_objetos_item_selected
	):
		lista_objetos.item_selected.connect(
			_on_lista_objetos_item_selected
		)
		
	if not filtro_categoria.item_selected.is_connected(
		_on_filtro_categoria_item_selected
	):
		filtro_categoria.item_selected.connect(
			_on_filtro_categoria_item_selected
		)
		
	if not entrada_buscador.text_changed.is_connected(
		_on_entrada_buscador_text_changed
	):
		entrada_buscador.text_changed.connect(
			_on_entrada_buscador_text_changed
		)

	if not ventana_objeto.close_requested.is_connected(
		_on_ventana_objeto_close_requested
	):
		ventana_objeto.close_requested.connect(
			_on_ventana_objeto_close_requested
		)


# ==================================================
# ABRIR VENTANA
# ==================================================

func abrir_ventana_objeto(objeto: Objeto = null) -> void:

	objeto_en_edicion = objeto

	if objeto == null:
		ventana_objeto.title = "Nuevo Objeto"
		limpiar_formulario_objeto()
	else:
		ventana_objeto.title = "Editar Objeto"
		cargar_formulario_objeto(objeto)

	ventana_objeto.popup_centered(
		Vector2i(600, 360)
	)

	entrada_nombre.grab_focus()


# ==================================================
# CERRAR VENTANA
# ==================================================

func cerrar_ventana_objeto() -> void:

	objeto_en_edicion = null
	ventana_objeto.hide()


# ==================================================
# LIMPIAR FORMULARIO
# ==================================================

func limpiar_formulario_objeto() -> void:

	entrada_nombre.clear()
	entrada_cantidad.value = 1
	entrada_costo.value = 0
	entrada_descripcion.clear()
	opcion_categoria.select(0)

func cargar_formulario_objeto(objeto: Objeto) -> void:

	entrada_nombre.text = objeto.nombre
	entrada_cantidad.value = objeto.cantidad
	entrada_costo.value = objeto.costo
	entrada_descripcion.text = objeto.descripcion
	seleccionar_categoria(objeto.categoria)


func seleccionar_categoria(categoria: String) -> void:

	var indice := Objeto.CATEGORIAS.find(categoria)

	if indice < 0:
		indice = 0

	opcion_categoria.select(indice)


func aplicar_formulario_a_objeto(
	objeto: Objeto,
	nombre_limpio: String
) -> void:

	objeto.nombre = nombre_limpio
	objeto.cantidad = int(entrada_cantidad.value)
	objeto.costo = int(entrada_costo.value)
	objeto.descripcion = entrada_descripcion.text.strip_edges()
	objeto.categoria = opcion_categoria.get_item_text(
		opcion_categoria.selected
	)

# ==================================================
# LISTA DE OBJETOS
# ==================================================

func actualizar_lista_objetos() -> void:

	objeto_seleccionado = null
	
	lista_objetos.clear()

	var texto_busqueda := entrada_buscador.text.strip_edges().to_lower()
	var categoria_filtro := obtener_categoria_filtro()
	var encontrados := 0
	mostrar_detalle_vacio()
	actualizar_botones_acciones()
	
	for objeto in objetos:

		if not coincide_busqueda(objeto, texto_busqueda):
			continue

		if not coincide_categoria(objeto, categoria_filtro):
			continue

		var indice := lista_objetos.add_item(objeto.nombre)
		lista_objetos.set_item_metadata(indice, objeto)
		encontrados += 1

	if encontrados == 0:
		lista_objetos.add_item("Sin resultados")
		lista_objetos.set_item_disabled(0, true)

	mostrar_detalle_vacio()

func obtener_categoria_filtro() -> String:

	if filtro_categoria.selected <= 0:
		return ""

	return filtro_categoria.get_item_text(
		filtro_categoria.selected
	)

func coincide_busqueda(objeto: Objeto, texto_busqueda: String) -> bool:

	if texto_busqueda.is_empty():
		return true

	if objeto.nombre.to_lower().contains(texto_busqueda):
		return true

	if objeto.descripcion.to_lower().contains(texto_busqueda):
		return true

	return false

func coincide_categoria(objeto: Objeto, categoria_filtro: String) -> bool:

	if categoria_filtro.is_empty():
		return true

	return objeto.categoria == categoria_filtro
# ==================================================
# DETALLE DEL OBJETO
# ==================================================

func mostrar_detalle_objeto(objeto: Objeto) -> void:

	nombre_detalle.text = "Nombre: " + objeto.nombre
	categoria_detalle.text = "Categoría: " + objeto.categoria
	cantidad_detalle.text = "Cantidad: " + str(objeto.cantidad)
	costo_detalle.text = "Costo: " + str(objeto.costo) + " oro"
	descripcion_detalle.text = "Descripción: " + objeto.descripcion


func mostrar_detalle_vacio() -> void:

	nombre_detalle.text = "Nombre:"
	categoria_detalle.text = "Categoría:"
	cantidad_detalle.text = "Cantidad:"
	costo_detalle.text = "Costo:"
	descripcion_detalle.text = "Descripción:"

# ==================================================
# ACCIONES DEL OBJETO
# ==================================================

func actualizar_botones_acciones() -> void:

	var hay_seleccion := objeto_seleccionado != null

	boton_editar_objeto.disabled = not hay_seleccion
	boton_eliminar_objeto.disabled = not hay_seleccion
	
# ==================================================
# TABLA DE MONEDAS
# ==================================================

func cargar_tabla_monedas() -> void:

	for hijo in tabla_monedas.get_children():
		tabla_monedas.remove_child(hijo)
		hijo.queue_free()

	agregar_celda_moneda("Moneda", true, false)

	for denominacion in Divisas.DENOMINACIONES:
		agregar_celda_moneda(denominacion, true, true)

	for moneda in Divisas.MONEDAS:

		agregar_celda_moneda(moneda, false, false)

		for i in Divisas.DENOMINACIONES.size():
			agregar_celda_moneda(
				Divisas.valor_en_texto(moneda, i),
				false,
				true
			)


func agregar_celda_moneda(
	texto: String,
	es_cabecera: bool,
	alinear_derecha: bool
) -> void:

	var celda := Label.new()
	celda.text = texto

	if alinear_derecha:
		celda.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	if es_cabecera:
		celda.add_theme_font_size_override("font_size", 18)
		celda.add_theme_color_override(
			"font_color",
			Color(0.86, 0.72, 0.38)
		)
	else:
		celda.add_theme_font_size_override("font_size", 16)

	tabla_monedas.add_child(celda)


# ==================================================
# DADO ESPECIAL D100
# ==================================================

## La animación muestra 60 números a 0,05 s cada uno = 3 s.
const PASOS_ANIMACION_D100: int = 60
const INTERVALO_ANIMACION_D100: float = 0.05

## Refresca la pantalla del d100: resultado y criatura.
## El mensaje de duplicado se oculta aquí y se muestra al tirar.
func actualizar_panel_d100() -> void:

	if ultima_tirada_d100 > 0:
		etiqueta_resultado_d100.text = str(ultima_tirada_d100)
	else:
		etiqueta_resultado_d100.text = "—"

	actualizar_criatura()
	etiqueta_duplicada.visible = false


## Registra una tirada del d100: actualiza la última, el historial y guarda.
func registrar_tirada_d100(resultado: int) -> void:

	if resultado < 1 or resultado > Dados.DADO_ESPECIAL:
		return

	ultima_tirada_d100 = resultado
	historial_d100 = Dados.agregar_al_historial(
		historial_d100,
		resultado
	)

	guardar_d100()


## Escribe la última tirada y el historial en RUTA_D100.
func guardar_d100() -> void:

	var datos := {
		"ultima": ultima_tirada_d100,
		"historial": historial_d100,
	}

	var archivo := FileAccess.open(RUTA_D100, FileAccess.WRITE)

	if archivo == null:
		push_error(
			"No se pudo abrir " + RUTA_D100 + " para guardar."
		)
		return

	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()


## Lee RUTA_D100 y reconstruye la última tirada y el historial.
## Si el archivo no existe o trae datos inválidos, arranca limpio.
func cargar_d100() -> void:

	ultima_tirada_d100 = 0
	historial_d100.clear()

	if not FileAccess.file_exists(RUTA_D100):
		return

	var archivo := FileAccess.open(RUTA_D100, FileAccess.READ)

	if archivo == null:
		push_error(
			"No se pudo abrir " + RUTA_D100 + " para leer."
		)
		return

	var texto := archivo.get_as_text()
	archivo.close()

	var json := JSON.new()
	var codigo_error := json.parse(texto)

	if codigo_error != OK:
		return

	var datos: Variant = json.data

	if not (datos is Dictionary):
		return

	var diccionario: Dictionary = datos

	var ultima: Variant = diccionario.get("ultima", 0)

	if ultima is int or ultima is float:

		var numero_ultima := int(ultima)

		if numero_ultima >= 1 and numero_ultima <= Dados.DADO_ESPECIAL:
			ultima_tirada_d100 = numero_ultima

	var historial: Variant = diccionario.get("historial", [])

	if not (historial is Array):
		return

	var lista: Array = historial

	for valor in lista:

		if historial_d100.size() >= Dados.MAX_HISTORIAL:
			break

		if not (valor is int or valor is float):
			continue

		var numero_tirada := int(valor)

		if numero_tirada < 1 or numero_tirada > Dados.DADO_ESPECIAL:
			continue

		historial_d100.append(numero_tirada)

	# Si el archivo trae historial pero no "ultima", se usa la más reciente.
	if ultima_tirada_d100 == 0 and not historial_d100.is_empty():
		ultima_tirada_d100 = historial_d100[0]


# ==================================================
# CRIATURAS
# ==================================================

## Etiquetas del grid de estadísticas que se rellenan con datos.
const ETIQUETAS_ESTADISTICAS: Array[String] = [
	"Nombre_Criatura",
	"Tipo_Criatura",
	"Dificultad_Criatura",
	"CA_Criatura",
	"PG_Criatura",
	"Velocidad_Criatura",
	"Fuerza_Criatura",
	"Destreza_Criatura",
	"Constitucion_Criatura",
	"Inteligencia_Criatura",
	"Sabiduria_Criatura",
	"Carisma_Criatura",
]


## Carga todos los .tres de RUTA_CRIATURAS, los normaliza y los ordena.
func cargar_criaturas() -> void:

	criaturas.clear()

	if not DirAccess.dir_exists_absolute(RUTA_CRIATURAS):
		push_warning("No existe la carpeta " + RUTA_CRIATURAS)
		return

	var carpeta := DirAccess.open(RUTA_CRIATURAS)

	if carpeta == null:
		push_error("No se pudo abrir " + RUTA_CRIATURAS)
		return

	carpeta.list_dir_begin()
	var archivo := carpeta.get_next()

	while not archivo.is_empty():

		if not carpeta.current_is_dir() and archivo.ends_with(".tres"):

			var recurso: Resource = load(
				RUTA_CRIATURAS + "/" + archivo
			)

			if recurso is Criatura:

				var criatura := recurso as Criatura
				criatura.normalizar()
				for problema in criatura.problemas_fases():
					push_warning("Criatura %d: %s" % [criatura.numero, problema])
				criaturas.append(criatura)

		archivo = carpeta.get_next()

	carpeta.list_dir_end()

	criaturas.sort_custom(
		func(a: Criatura, b: Criatura) -> bool:
			return a.numero < b.numero
	)


## Devuelve la criatura con ese número, o null si no existe.
func buscar_criatura(numero: int) -> Criatura:

	for criatura in criaturas:
		if criatura.numero == numero:
			return criatura

	return null


## Refresca la criatura mostrada según la última tirada del d100.
func actualizar_criatura() -> void:

	if ultima_tirada_d100 <= 0:
		mostrar_criatura_vacia("Criatura nº —")
		return

	var criatura := buscar_criatura(ultima_tirada_d100)

	if criatura == null:
		mostrar_criatura_vacia(
			"Criatura nº %d · sin ficha" % ultima_tirada_d100
		)
		return

	etiqueta_criatura.text = "Criatura nº %d · %s" % [
		criatura.numero,
		criatura.nombre,
	]
	titulo_estadisticas.text = etiqueta_criatura.text
	imagen_criatura.texture = criatura.imagen

	rellenar_estadisticas(criatura)
	rellenar_habilidades(criatura)


## Deja el panel y el popup sin datos de criatura.
func mostrar_criatura_vacia(texto: String) -> void:

	etiqueta_criatura.text = texto
	titulo_estadisticas.text = texto
	imagen_criatura.texture = null

	rellenar_estadisticas(null)
	rellenar_habilidades(null)


## Rellena el grid del popup. Con null, deja todas las etiquetas en "—".
func rellenar_estadisticas(criatura: Criatura) -> void:

	for nombre in ETIQUETAS_ESTADISTICAS:
		poner_texto_estadistica(nombre, "—")

	if criatura == null:
		return

	poner_texto_estadistica("Nombre_Criatura", criatura.nombre)
	poner_texto_estadistica("Tipo_Criatura", criatura.tipo)
	poner_texto_estadistica(
		"Dificultad_Criatura",
		"%d/%d · %s" % [
			criatura.dificultad,
			Criatura.DIFICULTAD_MAXIMA,
			criatura.nombre_dificultad(),
		]
	)
	var fase := criatura.obtener_fase(1)

	if fase == null:
		return

	poner_texto_estadistica("CA_Criatura", str(fase.ca))
	poner_texto_estadistica("PG_Criatura", str(fase.pg))
	poner_texto_estadistica("Velocidad_Criatura", fase.velocidad)
	poner_texto_estadistica("Fuerza_Criatura", str(fase.fuerza))
	poner_texto_estadistica("Destreza_Criatura", str(fase.destreza))
	poner_texto_estadistica("Constitucion_Criatura", str(fase.constitucion))
	poner_texto_estadistica("Inteligencia_Criatura", str(fase.inteligencia))
	poner_texto_estadistica("Sabiduria_Criatura", str(fase.sabiduria))
	poner_texto_estadistica("Carisma_Criatura", str(fase.carisma))


func poner_texto_estadistica(nombre: String, texto: String) -> void:

	var etiqueta := grid_estadisticas.get_node_or_null(
		nombre
	) as Label

	if etiqueta != null:
		etiqueta.text = texto


## Sustituye la lista de habilidades por un botón por habilidad.
func rellenar_habilidades(criatura: Criatura) -> void:

	for hijo in lista_habilidades.get_children():
		lista_habilidades.remove_child(hijo)
		hijo.queue_free()

	if criatura == null or criatura.habilidades.is_empty():

		var etiqueta := Label.new()
		etiqueta.name = "Etiqueta_Sin_Habilidades"
		etiqueta.text = "Sin habilidades"
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		etiqueta.size_flags_vertical = Control.SIZE_EXPAND_FILL
		etiqueta.add_theme_color_override(
			"font_color",
			Color(0.62, 0.62, 0.68, 1)
		)
		lista_habilidades.add_child(etiqueta)
		return

	var indice := 0

	for habilidad in criatura.habilidades:

		indice += 1

		if habilidad == null:
			continue

		var boton := Button.new()
		boton.name = "Habilidad_%d" % indice
		boton.text = habilidad.nombre
		boton.tooltip_text = habilidad.descripcion
		boton.custom_minimum_size = Vector2(0, 42)
		boton.pressed.connect(_on_habilidad_pressed.bind(habilidad))
		lista_habilidades.add_child(boton)


func _on_habilidad_pressed(habilidad: Habilidad) -> void:

	dialogo_habilidad.title = habilidad.nombre
	dialogo_habilidad.dialog_text = habilidad.descripcion
	dialogo_habilidad.popup_centered()


# ==================================================
# PERSISTENCIA
# ==================================================

func objeto_a_diccionario(objeto: Objeto) -> Dictionary:

	return {
		"nombre": objeto.nombre,
		"categoria": objeto.categoria,
		"cantidad": objeto.cantidad,
		"costo": objeto.costo,
		"descripcion": objeto.descripcion,
	}


func guardar_inventario() -> void:

	var lista := []

	for objeto in objetos:
		lista.append(objeto_a_diccionario(objeto))

	var archivo := FileAccess.open(
		RUTA_INVENTARIO,
		FileAccess.WRITE
	)

	if archivo == null:
		push_error(
			"No se pudo abrir " + RUTA_INVENTARIO + " para guardar."
		)
		return

	archivo.store_string(
		JSON.stringify(lista, "\t")
	)

	archivo.close()
func cargar_inventario() -> void:

	objetos.clear()

	if not FileAccess.file_exists(RUTA_INVENTARIO):
		return

	var archivo := FileAccess.open(
		RUTA_INVENTARIO,
		FileAccess.READ
	)

	if archivo == null:
		push_error(
			"No se pudo abrir " + RUTA_INVENTARIO + " para leer."
		)
		return

	var texto := archivo.get_as_text()
	archivo.close()

	var datos: Variant = JSON.parse_string(texto)

	if not (datos is Array):
		push_error(
			"El archivo de inventario no contiene una lista válida."
		)
		return

	for dato in datos:
		if not (dato is Dictionary):
			continue

		objetos.append(diccionario_a_objeto(dato))


func diccionario_a_objeto(dato: Dictionary) -> Objeto:

	var objeto := Objeto.new()

	objeto.nombre = str(
		dato.get("nombre", "Objeto sin nombre")
	)

	var categoria := str(
		dato.get("categoria", "Misceláneo")
	)

	if not (categoria in Objeto.CATEGORIAS):
		categoria = "Misceláneo"

	objeto.categoria = categoria
	objeto.cantidad = int(dato.get("cantidad", 1))
	objeto.costo = int(dato.get("costo", 0))
	objeto.descripcion = str(
		dato.get("descripcion", "")
	)

	return objeto
# ==================================================
# SEÑALES
# ==================================================

func _on_boton_nuevo_objeto_pressed() -> void:

	abrir_ventana_objeto()


func _on_boton_cancelar_objeto_pressed() -> void:

	cerrar_ventana_objeto()


func _on_boton_guardar_objeto_pressed() -> void:

	var nombre_limpio := entrada_nombre.text.strip_edges()

	if nombre_limpio.is_empty():
		mostrar_aviso(
			"El nombre del objeto no puede estar vacío."
		)
		entrada_nombre.grab_focus()
		return

	if objeto_en_edicion == null:
		var nuevo_objeto := Objeto.new()
		aplicar_formulario_a_objeto(nuevo_objeto, nombre_limpio)
		objetos.append(nuevo_objeto)
	else:
		aplicar_formulario_a_objeto(objeto_en_edicion, nombre_limpio)
		
	guardar_inventario()
	actualizar_lista_objetos()

	cerrar_ventana_objeto()


func _on_boton_editar_objeto_pressed() -> void:

	if objeto_seleccionado == null:
		return

	abrir_ventana_objeto(objeto_seleccionado)

func _on_boton_eliminar_objeto_pressed() -> void:

	if objeto_seleccionado == null:
		return

	objeto_a_eliminar = objeto_seleccionado

	dialogo_confirmacion.dialog_text = (
		'¿Seguro que quieres eliminar "'
		+ objeto_a_eliminar.nombre
		+ '"?\n\nEsta acción no se puede deshacer.'
	)

	dialogo_confirmacion.popup_centered(Vector2i(420, 150))


func _on_confirmacion_eliminar_confirmada() -> void:

	if objeto_a_eliminar == null:
		return

	objetos.erase(objeto_a_eliminar)
	objeto_a_eliminar = null
	guardar_inventario()
	actualizar_lista_objetos()


func _on_confirmacion_eliminar_cancelada() -> void:

	objeto_a_eliminar = null
	
	
func _on_lista_objetos_item_selected(indice: int) -> void:

	objeto_seleccionado = lista_objetos.get_item_metadata(indice) as Objeto

	if objeto_seleccionado == null:
		mostrar_detalle_vacio()
	else:
		mostrar_detalle_objeto(objeto_seleccionado)

	actualizar_botones_acciones()


func _on_entrada_buscador_text_changed(_texto_nuevo: String) -> void:

	actualizar_lista_objetos()


func _on_ventana_objeto_close_requested() -> void:

	cerrar_ventana_objeto()

func _on_filtro_categoria_item_selected(_indice: int) -> void:

	actualizar_lista_objetos()


func _on_boton_tirar_d100_pressed() -> void:

	if tirada_d100_en_curso:
		return

	tirada_d100_en_curso = true
	boton_tirar_d100.disabled = true

	var resultado := Dados.tirar_d100()
	var duplicada := Dados.es_duplicada(
		historial_d100,
		resultado
	)

	etiqueta_duplicada.visible = false

	for i in PASOS_ANIMACION_D100:

		etiqueta_resultado_d100.text = str(
			randi_range(1, Dados.MAXIMO_ACTUAL_D100)
		)

		await get_tree().create_timer(
			INTERVALO_ANIMACION_D100
		).timeout

	registrar_tirada_d100(resultado)
	actualizar_panel_d100()
	etiqueta_duplicada.visible = duplicada
	tirada_d100_en_curso = false
	boton_tirar_d100.disabled = false


func _on_boton_estadisticas_pressed() -> void:

	ventana_estadisticas.popup_centered()


func _on_ventana_estadisticas_close_requested() -> void:

	ventana_estadisticas.hide()


# ==================================================
# AVISOS
# ==================================================

func mostrar_aviso(texto: String) -> void:

	dialogo_aviso.dialog_text = texto
	dialogo_aviso.popup_centered()
