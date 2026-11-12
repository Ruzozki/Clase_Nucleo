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

@export_category("Pantalla de personaje")

@export_node_path("TabContainer")
var ruta_pantallas: NodePath

@export_node_path("Label")
var ruta_resultado_d100: NodePath

@export_node_path("Button")
var ruta_boton_tirar_d100: NodePath

@export_node_path("Label")
var ruta_mensaje_duplicada: NodePath

@export_node_path("Label")
var ruta_etiqueta_criatura: NodePath

@export_node_path("Label")
var ruta_subtitulo_criatura: NodePath

@export_node_path("Label")
var ruta_fase_criatura: NodePath

@export_node_path("Sprite3D")
var ruta_sprite_criatura: NodePath

@export_node_path("VBoxContainer")
var ruta_lista_habilidades: NodePath

@export_node_path("Control")
var ruta_capa_estadisticas: NodePath

@export_node_path("Control")
var ruta_capa_pericias: NodePath

@export_node_path("PanelContainer")
var ruta_tarjeta_tirada: NodePath

@export_node_path("Label")
var ruta_etiqueta_tirada: NodePath

@export_node_path("Label")
var ruta_modo_tirada: NodePath

@export_node_path("HBoxContainer")
var ruta_fila_dados: NodePath

@export_node_path("Label")
var ruta_total_tirada: NodePath

@export_node_path("Label")
var ruta_estado_tirada: NodePath

@export_node_path("VBoxContainer")
var ruta_lista_tiradas: NodePath

@export_node_path("Button")
var ruta_boton_base_datos: NodePath

@export_node_path("Button")
var ruta_boton_inventario: NodePath

@export_node_path("ProgressBar")
var ruta_barra_pm: NodePath

@export_node_path("Label")
var ruta_valor_pt: NodePath

@export_node_path("ProgressBar")
var ruta_barra_pt: NodePath

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

var pantallas: TabContainer

var etiqueta_resultado_d100: Label
var boton_tirar_d100: Button
var etiqueta_duplicada: Label
var etiqueta_criatura: Label
var subtitulo_criatura: Label
var etiqueta_fase: Label
var sprite_criatura: Sprite3D
var lista_habilidades: VBoxContainer
var capa_estadisticas: Control
var capa_pericias: Control
var botones_pericia: Array[Button] = []
var botones_estadistica: Dictionary = {}
var boton_base_datos: Button
var boton_inventario: Button
var barra_pm: ProgressBar
var valor_pt: Label
var barra_pt: ProgressBar
var dialogo_habilidad: AcceptDialog

var dialogo_aviso: AcceptDialog
## Diálogo que pide confirmación antes de eliminar.
var dialogo_confirmacion: ConfirmationDialog

var tarjeta_tirada: PanelContainer
var etiqueta_tirada: Label
var modo_tirada: Label
var fila_dados: HBoxContainer
var total_tirada: Label
var estado_tirada: Label
var lista_tiradas: VBoxContainer
var menu_tirada: PopupMenu
var boton_tirada_pendiente: Button
var tween_tarjeta: Tween

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
## Archivo donde se guarda el estado de la partida.
const RUTA_PARTIDA: String = "user://partida.json"
## Última tirada del d100, o 0 si todavía no hay ninguna.
var ultima_tirada_d100: int = 0
## Las 5 últimas tiradas del d100, de la más nueva a la más vieja.
var historial_d100: Array[int] = []
## True mientras la animación del d100 está en curso (bloquea el botón).
var tirada_d100_en_curso: bool = false

## Carpeta con los archivos .tres de cada criatura.
const RUTA_CRIATURAS: String = "res://Recursos/Criaturas"
const RUTA_HABILIDADES: String = "res://Recursos/Habilidades"

var catalogo_habilidades: Array[Habilidad] = []
## Criaturas cargadas al arrancar, ordenadas por número.
var criaturas: Array[Criatura] = []
var nucleo: EstadoNucleo = EstadoNucleo.new()

## Posición de cada pestaña dentro del TabContainer de la escena.
const PESTANA_PERSONAJE: int = 0
const PESTANA_OBJETOS: int = 1
const PESTANA_MONEDAS: int = 2
const PESTANA_BASE_DATOS: int = 3

# ==================================================
# INICIALIZACIÓN
# ==================================================

func _ready() -> void:
	
	crear_dialogo_aviso()
	crear_dialogo_confirmacion()
	crear_dialogo_habilidad()
	crear_menu_tirada()
	if not cargar_referencias():
		return

	conectar_botones()
	cargar_categorias()
	cargar_filtro_categorias()
	cargar_tabla_monedas()
	pantallas.set_tab_title(PESTANA_BASE_DATOS, "Base de datos")
	# Objetos y Base de datos se alcanzan con los botones del panel de personaje:
	# sus pestañas quedan ocultas de la barra superior.
	pantallas.set_tab_hidden(PESTANA_OBJETOS, true)
	pantallas.set_tab_hidden(PESTANA_BASE_DATOS, true)
	ventana_objeto.hide()
	
	cargar_partida()
	cargar_inventario()
	cargar_d100()
	cargar_criaturas()
	cargar_habilidades()
	
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

	pantallas = get_node_or_null(
		ruta_pantallas
	) as TabContainer

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

	subtitulo_criatura = get_node_or_null(
		ruta_subtitulo_criatura
	) as Label

	etiqueta_fase = get_node_or_null(
		ruta_fase_criatura
	) as Label

	sprite_criatura = get_node_or_null(
		ruta_sprite_criatura
	) as Sprite3D
	
	lista_habilidades = get_node_or_null(
		ruta_lista_habilidades
	) as VBoxContainer

	capa_estadisticas = get_node_or_null(
		ruta_capa_estadisticas
	) as Control

	_preparar_estadisticas()
	
	capa_pericias = get_node_or_null(
		ruta_capa_pericias
	) as Control

	_preparar_pericias_hud()
	
	tarjeta_tirada = get_node_or_null(
		ruta_tarjeta_tirada
	) as PanelContainer

	etiqueta_tirada = get_node_or_null(
		ruta_etiqueta_tirada
	) as Label

	modo_tirada = get_node_or_null(
		ruta_modo_tirada
	) as Label

	fila_dados = get_node_or_null(
		ruta_fila_dados
	) as HBoxContainer

	total_tirada = get_node_or_null(
		ruta_total_tirada
	) as Label

	estado_tirada = get_node_or_null(
		ruta_estado_tirada
	) as Label

	lista_tiradas = get_node_or_null(
		ruta_lista_tiradas
	) as VBoxContainer
	
	boton_base_datos = get_node_or_null(
		ruta_boton_base_datos
	) as Button

	boton_inventario = get_node_or_null(
		ruta_boton_inventario
	) as Button

	barra_pm = get_node_or_null(
		ruta_barra_pm
	) as ProgressBar

	valor_pt = get_node_or_null(
		ruta_valor_pt
	) as Label

	barra_pt = get_node_or_null(
		ruta_barra_pt
	) as ProgressBar

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

	if pantallas == null:
		push_error(
			"No se asignó correctamente Pantallas."
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
			"No se asignó correctamente Nombre_Transformacion."
		)
		return false

	if subtitulo_criatura == null:
		push_error(
			"No se asignó correctamente Subtitulo_Transformacion."
		)
		return false

	if etiqueta_fase == null:
		push_error(
			"No se asignó correctamente Fase_Transformacion."
		)
		return false

	if sprite_criatura == null:
		push_error(
			"No se asignó correctamente Criatura_3D."
		)
		return false

	if lista_habilidades == null:
		push_error(
			"No se asignó correctamente Lista_Habilidades."
		)
		return false

	if boton_base_datos == null:
		push_error(
			"No se asignó correctamente Boton_Base_Datos."
		)
		return false

	if boton_inventario == null:
		push_error(
			"No se asignó correctamente Boton_Inventario."
		)
		return false

	if barra_pm == null:
		push_error(
			"No se asignó correctamente Barra_PM."
		)
		return false

	if valor_pt == null:
		push_error(
			"No se asignó correctamente Valor_PT."
		)
		return false

	if barra_pt == null:
		push_error(
			"No se asignó correctamente Barra_PT."
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

	if not boton_base_datos.pressed.is_connected(
		_on_boton_base_datos_pressed
	):
		boton_base_datos.pressed.connect(
			_on_boton_base_datos_pressed
		)

	if not boton_inventario.pressed.is_connected(
		_on_boton_inventario_pressed
	):
		boton_inventario.pressed.connect(
			_on_boton_inventario_pressed
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
	boton_tirar_d100.disabled = not nucleo.puede_tirar_d100()

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

## Escribe nivel, PT, bonos y criaturas registradas en RUTA_PARTIDA.
func guardar_partida() -> void:

	var datos := {
		"nivel": nucleo.nivel,
		"pt": nucleo.pt,
		"bonos_pt": nucleo.bonos_pt,
		"registradas": nucleo.criaturas_registradas,
	}

	var archivo := FileAccess.open(RUTA_PARTIDA, FileAccess.WRITE)

	if archivo == null:
		push_error(
			"No se pudo abrir " + RUTA_PARTIDA + " para guardar."
		)
		return

	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()


## Lee RUTA_PARTIDA. Si no existe, arranca una partida nueva.
func cargar_partida() -> void:

	nucleo.nivel = 1
	nucleo.bonos_pt = 0
	nucleo.criaturas_registradas.clear()
	nucleo.pt = nucleo.pt_maximos()

	if not FileAccess.file_exists(RUTA_PARTIDA):
		return

	var archivo := FileAccess.open(RUTA_PARTIDA, FileAccess.READ)

	if archivo == null:
		push_error(
			"No se pudo abrir " + RUTA_PARTIDA + " para leer."
		)
		return

	var texto := archivo.get_as_text()
	archivo.close()

	var json := JSON.new()

	if json.parse(texto) != OK:
		return

	if not (json.data is Dictionary):
		return

	var datos: Dictionary = json.data

	var nivel: Variant = datos.get("nivel", 1)

	if nivel is int or nivel is float:
		nucleo.nivel = int(nivel)

	var bonos: Variant = datos.get("bonos_pt", 0)

	if bonos is int or bonos is float:
		nucleo.bonos_pt = int(bonos)

	var registradas: Variant = datos.get("registradas", [])

	if registradas is Array:

		for valor in registradas:

			if not (valor is int or valor is float):
				continue

			nucleo.registrar_criatura(int(valor))

	var pt: Variant = datos.get("pt", nucleo.pt_maximos())

	if pt is int or pt is float:
		nucleo.pt = int(pt)

	nucleo.normalizar()
	
# ==================================================
# CRIATURAS
# ==================================================

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
				
				for problema in criatura.problemas_mutaciones():
					push_warning("Criatura %d: %s" % [criatura.numero, problema])
					
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

## Carga las habilidades de RUTA_HABILIDADES/NNN/ y comprueba que cada archivo
## esté bien puesto. Las que fallan se avisan y no se cargan.
func cargar_habilidades() -> void:

	catalogo_habilidades.clear()

	if not DirAccess.dir_exists_absolute(RUTA_HABILIDADES):
		push_warning("No existe la carpeta " + RUTA_HABILIDADES)
		return

	var ids_vistos: Dictionary = {}

	for nombre_carpeta in DirAccess.get_directories_at(RUTA_HABILIDADES):

		var ruta_carpeta := RUTA_HABILIDADES + "/" + nombre_carpeta

		for archivo in DirAccess.get_files_at(ruta_carpeta):

			if not archivo.ends_with(".tres"):
				continue

			var ruta := ruta_carpeta + "/" + archivo
			var recurso: Resource = load(ruta)
			
			if not (recurso is Habilidad):
				push_warning("%s no es una Habilidad" % ruta)
				continue

			var habilidad := recurso as Habilidad
			habilidad.normalizar()

			var id: String = habilidad.obtener_id()
			var problemas: Array[String] = []

			if archivo.get_basename() != id:
				problemas.append("el archivo debería llamarse %s.tres" % id)

			if nombre_carpeta != "%03d" % habilidad.criatura:
				problemas.append("debería estar en la carpeta %03d" % habilidad.criatura)

			if ids_vistos.has(id):
				problemas.append("el id %s está repetido" % id)

			if not habilidad.es_valida():
				problemas.append("no tiene nombre")

			if not problemas.is_empty():
				push_warning("Habilidad %s: %s" % [ruta, ", ".join(problemas)])
				continue

			ids_vistos[id] = true
			catalogo_habilidades.append(habilidad)

	catalogo_habilidades.sort_custom(
		func(a: Habilidad, b: Habilidad) -> bool:
			return a.obtener_id() < b.obtener_id()
	)
	
## Devuelve las habilidades y pasivas de una criatura hasta esa fase, ordenadas
## por id. Con fase_maxima = 1 (por ahora) salen solo las de fase 1.
func habilidades_de(numero_criatura: int, fase_maxima: int = 1) -> Array[Habilidad]:

	var resultado: Array[Habilidad] = []

	for habilidad in catalogo_habilidades:
		if habilidad.criatura == numero_criatura and habilidad.fase <= fase_maxima:
			resultado.append(habilidad)

	return resultado

# ==================================================
# ESCENARIO 3D
# ==================================================

## Altura en metros de la criatura en el escenario, sea cual sea el tamaño de su PNG.
const ALTURA_SPRITE_3D: float = 2.2

## Color del HUD al pasar el ratón por una estadística.
const DORADO_HUD: Color = Color("#E8C15A")

## Color de una pifia (un 1 natural).
const ROJO_PIFIA: Color = Color("#DB5C5C")

## Orden de los nueve botones de estadística del HUD.
const ABREVIATURAS_ESTADISTICA: Array[String] = [
	"FUE", "DES", "CON", "INT", "SAB", "CAR",
	"CA", "PG", "VEL",
]

## Cuántas tiradas se enseñan en el historial.
const MAX_HISTORIAL_TIRADAS: int = 8

## Pone la textura en el sprite 3D, la recorta a su contenido visible
## y la escala para que siempre mida ALTURA_SPRITE_3D desde los pies.
func poner_textura_3d(textura: Texture2D) -> void:

	if sprite_criatura == null:
		return

	sprite_criatura.texture = textura
	sprite_criatura.region_enabled = false

	if textura == null:
		return

	var rect := _rect_visible(textura)
	var alto := rect.size.y

	if alto <= 0.0:
		return

	sprite_criatura.region_enabled = true
	sprite_criatura.region_rect = rect
	sprite_criatura.pixel_size = ALTURA_SPRITE_3D / alto
	sprite_criatura.position = Vector3(
		0.0,
		ALTURA_SPRITE_3D * 0.5,
		0.0
	)


## Rectángulo de los píxeles con alpha de la textura.
## Si la imagen no tiene transparencia, devuelve la textura entera.
func _rect_visible(textura: Texture2D) -> Rect2:

	var imagen := textura.get_image()

	if imagen == null:
		return Rect2(Vector2.ZERO, Vector2(textura.get_size()))

	if imagen.is_compressed():
		imagen.decompress()

	var usado := imagen.get_used_rect()

	if usado.size.x <= 0 or usado.size.y <= 0:
		return Rect2(Vector2.ZERO, Vector2(textura.get_size()))

	return Rect2(usado)

## Refresca la transformación mostrada según la última tirada del d100.
func actualizar_criatura() -> void:

	if ultima_tirada_d100 <= 0:
		mostrar_criatura_vacia(
			"Sin transformación",
			"Tira el d100 para empezar"
		)
		return

	var criatura := buscar_criatura(ultima_tirada_d100)

	if criatura == null:
		mostrar_criatura_vacia(
			"Criatura nº %d · sin ficha" % ultima_tirada_d100,
			"No hay ficha en Recursos/Criaturas"
		)
		return

	var fase := criatura.obtener_fase(1)
	var nombre_visible := criatura.nombre

	if fase != null and not fase.nombre.is_empty():
		nombre_visible = fase.nombre

	etiqueta_criatura.text = nombre_visible
	etiqueta_fase.text = "Fase 1"
	subtitulo_criatura.text = "Nº %03d · %s · Dificultad %d/%d · %s" % [
		criatura.numero,
		criatura.tipo,
		criatura.dificultad,
		Criatura.DIFICULTAD_MAXIMA,
		criatura.nombre_dificultad(),
	]

	
	poner_textura_3d(criatura.imagen)
	rellenar_estadisticas(fase)
	rellenar_puntos()
	rellenar_habilidades(criatura)
	rellenar_pericias(fase)


## Deja la pantalla sin datos de criatura.
func mostrar_criatura_vacia(texto: String, subtitulo: String) -> void:

	etiqueta_criatura.text = texto
	subtitulo_criatura.text = subtitulo
	etiqueta_fase.text = "Fase —"


	poner_textura_3d(null)
	rellenar_estadisticas(null)
	rellenar_puntos()
	rellenar_habilidades(null)
	rellenar_pericias(null)


## Localiza los nueve botones del HUD y les da el dorado al pasar el ratón.
func _preparar_estadisticas() -> void:

	botones_estadistica.clear()

	if capa_estadisticas == null:
		return

	for abreviatura in ABREVIATURAS_ESTADISTICA:

		var boton := capa_estadisticas.get_node_or_null(
			"Boton_" + abreviatura
		) as Button

		if boton == null:
			continue

		botones_estadistica[abreviatura] = boton

		_estilizar_boton_hud(boton)


## Estilo común de los botones flotantes del HUD.
func _estilizar_boton_hud(boton: Button) -> void:

	boton.add_theme_constant_override("icon_max_width", 24)
	boton.add_theme_color_override("font_hover_color", DORADO_HUD)
	boton.add_theme_color_override("font_pressed_color", DORADO_HUD)
	boton.add_theme_color_override("icon_hover_color", DORADO_HUD)
	boton.add_theme_color_override("icon_pressed_color", DORADO_HUD)
	boton.add_theme_color_override("icon_focus_color", DORADO_HUD)

	if not boton.has_meta("tirada_conectada"):
		boton.set_meta("tirada_conectada", true)
		boton.pressed.connect(_on_boton_tirada_pressed.bind(boton))
		boton.gui_input.connect(_on_boton_tirada_gui_input.bind(boton))

## Escribe los nueve valores de la fase en los botones del HUD.
func rellenar_estadisticas(fase: Fase) -> void:

	if fase == null:

		for abreviatura in ABREVIATURAS_ESTADISTICA:
			_poner_estadistica(abreviatura, "—", 0)

		return

	# Las tiradas de estadística son d20 limpio, sin modificador.
	_poner_estadistica("FUE", str(fase.fuerza), 0)
	_poner_estadistica("DES", str(fase.destreza), 0)
	_poner_estadistica("CON", str(fase.constitucion), 0)
	_poner_estadistica("INT", str(fase.inteligencia), 0)
	_poner_estadistica("SAB", str(fase.sabiduria), 0)
	_poner_estadistica("CAR", str(fase.carisma), 0)
	_poner_estadistica("CA", str(fase.ca), 0)
	_poner_estadistica("PG", str(fase.pg), 0)
	_poner_estadistica("VEL", fase.velocidad, 0)


## "FUE 14" mientras no haya icono; solo "14" cuando lo tenga.
func _poner_estadistica(abreviatura: String, valor: String, bono: int) -> void:

	var boton := botones_estadistica.get(abreviatura) as Button

	if boton == null:
		return

	boton.set_meta("bono", bono)
	boton.set_meta("etiqueta", abreviatura)

	if boton.icon == null:
		boton.text = "%s %s" % [abreviatura, valor]
	else:
		boton.text = valor

## Muestra los PM y los PT del Núcleo en sus barras.
func rellenar_puntos() -> void:

	barra_pm.max_value = EstadoNucleo.PM_MAXIMO
	barra_pm.value = nucleo.pm

	actualizar_barra_pt()


## Refresca la barra de PT y su texto.
func actualizar_barra_pt() -> void:

	var pt_maximos := nucleo.pt_maximos()

	barra_pt.max_value = pt_maximos
	barra_pt.value = nucleo.pt
	valor_pt.text = "%d / %d" % [nucleo.pt, pt_maximos]


## Las 18 pericias, en los botones libres del HUD.
func rellenar_pericias(fase: Fase) -> void:

	var nombres := ReglasDnD.nombres_pericias()

	for i in nombres.size():

		if i >= botones_pericia.size():
			break

		var boton := botones_pericia[i]

		if boton == null:
			continue

		var nombre := nombres[i]

		if fase == null:
			boton.text = nombre
			boton.set_meta("bono", 0)
			boton.set_meta("etiqueta", nombre)
			continue

		var valor := fase.valor_pericia(
			nombre,
			ReglasDnD.BONO_COMPETENCIA_PROVISIONAL
		)

		var marca := ""

		if fase.es_competente_pericia(nombre):
			marca = "● "

		boton.text = "%s%s  %s" % [
			marca,
			nombre,
			ReglasDnD.texto_modificador(valor),
		]

		boton.set_meta("bono", valor)
		boton.set_meta("etiqueta", nombre)


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
		boton.custom_minimum_size = Vector2(0, 48)
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
	if not nucleo.puede_tirar_d100():
		mostrar_aviso("No tienes PT suficientes para tirar el d100.")
		return

	if not nucleo.gastar_pt(nucleo.coste_d100()):
		actualizar_barra_pt()
		actualizar_panel_d100()
		return

	actualizar_barra_pt()
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
			randi_range(1, Dados.DADO_ESPECIAL)
		)

		await get_tree().create_timer(
			INTERVALO_ANIMACION_D100
		).timeout

	var criatura := buscar_criatura(resultado)

	registrar_tirada_d100(resultado)
	nucleo.transformar_en(criatura)

	if criatura != null:
		nucleo.registrar_criatura(resultado)

	guardar_partida()
	actualizar_barra_pt()
	actualizar_panel_d100()
	etiqueta_duplicada.visible = duplicada
	tirada_d100_en_curso = false


func _on_boton_base_datos_pressed() -> void:

	pantallas.current_tab = PESTANA_BASE_DATOS


func _on_boton_inventario_pressed() -> void:

	pantallas.current_tab = PESTANA_OBJETOS


# ==================================================
# AVISOS
# ==================================================

func mostrar_aviso(texto: String) -> void:

	dialogo_aviso.dialog_text = texto
	dialogo_aviso.popup_centered()

## Localiza los 18 botones de pericia del HUD.
## No depende de tildes ni mayúsculas en el nombre del nodo.
func _preparar_pericias_hud() -> void:

	botones_pericia.clear()

	if capa_pericias == null:
		return

	var botones_por_nombre: Dictionary = {}

	for hijo in capa_pericias.get_children():

		if hijo is Button:
			botones_por_nombre[_sin_tildes(str(hijo.name))] = hijo

	for nombre in ReglasDnD.nombres_pericias():

		var clave := _sin_tildes("Boton_" + nombre.replace(" ", "_"))
		var boton := botones_por_nombre.get(clave) as Button

		botones_pericia.append(boton)

		if boton == null:
			push_warning(
				"Pericia sin botón en el HUD: %s" % nombre
			)
			continue

		_estilizar_boton_hud(boton)


## Minúsculas y sin tildes, para comparar nombres de nodo.
func _sin_tildes(texto: String) -> String:

	var limpio := texto.to_lower()

	var tildes := {
		"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
		"ü": "u", "ñ": "n",
	}

	for letra in tildes:
		limpio = limpio.replace(letra, tildes[letra])

	return limpio

# ==================================================
# TIRADAS DE HABILIDAD
# ==================================================

## Menú que sale con el clic derecho sobre una estadística o pericia.
func crear_menu_tirada() -> void:

	menu_tirada = PopupMenu.new()
	menu_tirada.add_item("Normal", Dados.Modo.NORMAL)
	menu_tirada.add_item("Ventaja", Dados.Modo.VENTAJA)
	menu_tirada.add_item("Desventaja", Dados.Modo.DESVENTAJA)
	menu_tirada.id_pressed.connect(_on_menu_tirada_id_pressed)
	add_child(menu_tirada)


func _on_boton_tirada_pressed(boton: Button) -> void:

	tirar_para_boton(boton, Dados.Modo.NORMAL)


func _on_boton_tirada_gui_input(evento: InputEvent, boton: Button) -> void:

	if not (evento is InputEventMouseButton):
		return

	if not evento.pressed:
		return

	if evento.button_index != MOUSE_BUTTON_RIGHT:
		return

	boton_tirada_pendiente = boton
	menu_tirada.position = Vector2i(evento.global_position)
	menu_tirada.popup()


func _on_menu_tirada_id_pressed(id: int) -> void:

	if boton_tirada_pendiente == null:
		return

	tirar_para_boton(boton_tirada_pendiente, id)
	boton_tirada_pendiente = null


## Tira d20 + el bono guardado en el botón y pinta la tarjeta.
func tirar_para_boton(boton: Button, modo: int) -> void:

	var bono := int(boton.get_meta("bono", 0))
	var etiqueta := str(boton.get_meta("etiqueta", str(boton.name)))

	var tirada := Tirada.crear(
		etiqueta,
		modo,
		Dados.tirar_d20(modo),
		bono
	)

	_mostrar_tarjeta_tirada(tirada)
	_agregar_al_historial(tirada)


## Color del resultado: dorado en crítico, rojo en pifia, blanco normal.
func _color_resultado(tirada: Tirada) -> Color:

	if tirada.critico:
		return DORADO_HUD

	if tirada.pifia:
		return ROJO_PIFIA

	return Color(0.94, 0.95, 0.98, 1)


## Pinta la tarjeta central con los dados, el bono y el total.
func _mostrar_tarjeta_tirada(tirada: Tirada) -> void:

	if tarjeta_tirada == null:
		return

	etiqueta_tirada.text = tirada.etiqueta
	modo_tirada.text = tirada.nombre_modo()

	_preparar_dados_tarjeta(tirada)

	total_tirada.text = str(tirada.total)
	total_tirada.add_theme_color_override(
		"font_color",
		_color_resultado(tirada)
	)

	if tirada.critico:
		estado_tirada.text = "¡Crítico natural!"
	elif tirada.pifia:
		estado_tirada.text = "¡Pifia!"
	elif tirada.modo != Dados.Modo.NORMAL:
		estado_tirada.text = "Cuenta el %d" % tirada.base
	else:
		estado_tirada.text = ""

	estado_tirada.visible = not estado_tirada.text.is_empty()
	estado_tirada.add_theme_color_override(
		"font_color",
		_color_resultado(tirada)
	)

	tarjeta_tirada.visible = true
	tarjeta_tirada.modulate.a = 0.0
	tarjeta_tirada.scale = Vector2(0.94, 0.94)
	tarjeta_tirada.pivot_offset = tarjeta_tirada.size * 0.5

	if tween_tarjeta != null and tween_tarjeta.is_valid():
		tween_tarjeta.kill()

	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(
		tarjeta_tirada,
		"modulate:a",
		1.0,
		0.14
	)
	tween_tarjeta.parallel().tween_property(
		tarjeta_tirada,
		"scale",
		Vector2.ONE,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_tarjeta.tween_interval(2.2)
	tween_tarjeta.tween_property(
		tarjeta_tirada,
		"modulate:a",
		0.0,
		0.45
	)
	tween_tarjeta.tween_callback(_ocultar_tarjeta_tirada)


## Vacía la fila y crea una ficha por dado. El descartado va atenuado.
func _preparar_dados_tarjeta(tirada: Tirada) -> void:

	if fila_dados == null:
		return

	for hijo in fila_dados.get_children():

		fila_dados.remove_child(hijo)
		hijo.queue_free()

	var empatan := (
		tirada.dados.size() > 1
		and tirada.dados[0] == tirada.dados[1]
	)

	for i in tirada.dados.size():

		var usado := i == tirada.indice_usado or empatan

		fila_dados.add_child(
			_crear_ficha_dado(tirada.dados[i], usado, tirada)
		)

	if tirada.bono != 0:

		var etiqueta_bono := Label.new()
		etiqueta_bono.text = ReglasDnD.texto_modificador(tirada.bono)
		etiqueta_bono.add_theme_font_size_override("font_size", 26)
		etiqueta_bono.add_theme_color_override(
			"font_color",
			Color(0.76, 0.78, 0.85, 1)
		)
		etiqueta_bono.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fila_dados.add_child(etiqueta_bono)


## Ficha cuadrada con el número de un dado.
func _crear_ficha_dado(
	valor: int,
	usado: bool,
	tirada: Tirada
) -> PanelContainer:

	var ficha := PanelContainer.new()
	ficha.custom_minimum_size = Vector2(58, 54)

	var color := _color_resultado(tirada)

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.1, 0.11, 0.16, 1)
	estilo.corner_radius_top_left = 8
	estilo.corner_radius_top_right = 8
	estilo.corner_radius_bottom_right = 8
	estilo.corner_radius_bottom_left = 8
	estilo.border_width_left = 2
	estilo.border_width_top = 2
	estilo.border_width_right = 2
	estilo.border_width_bottom = 2
	estilo.border_color = color if usado else Color(0.3, 0.32, 0.4, 1)
	ficha.add_theme_stylebox_override("panel", estilo)

	var numero := Label.new()
	numero.text = str(valor)
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numero.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	numero.add_theme_font_size_override("font_size", 30)
	numero.add_theme_color_override(
		"font_color",
		color if usado else Color(0.52, 0.54, 0.62, 1)
	)
	ficha.add_child(numero)

	if not usado:
		ficha.modulate.a = 0.55

	return ficha


## Añade la tirada arriba del historial como una mini-tarjeta.
func _agregar_al_historial(tirada: Tirada) -> void:

	if lista_tiradas == null:
		return

	var fila := PanelContainer.new()
	fila.mouse_filter = Control.MOUSE_FILTER_PASS

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.09, 0.1, 0.14, 0.95)
	estilo.corner_radius_top_left = 6
	estilo.corner_radius_top_right = 6
	estilo.corner_radius_bottom_right = 6
	estilo.corner_radius_bottom_left = 6
	estilo.border_width_left = 3
	estilo.border_color = _color_resultado(tirada)
	fila.add_theme_stylebox_override("panel", estilo)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 8)
	margen.add_theme_constant_override("margin_top", 4)
	margen.add_theme_constant_override("margin_right", 8)
	margen.add_theme_constant_override("margin_bottom", 4)

	var linea := HBoxContainer.new()
	linea.add_theme_constant_override("separation", 8)

	var dados := Label.new()
	dados.text = tirada.texto_dados()
	dados.custom_minimum_size = Vector2(44, 0)
	dados.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dados.add_theme_font_size_override("font_size", 15)
	dados.add_theme_color_override(
		"font_color",
		_color_resultado(tirada)
	)

	var nombre := Label.new()
	nombre.text = tirada.etiqueta
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nombre.clip_text = true
	nombre.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nombre.add_theme_font_size_override("font_size", 14)

	var total := Label.new()
	total.text = str(tirada.total)
	total.add_theme_font_size_override("font_size", 18)
	total.add_theme_color_override(
		"font_color",
		_color_resultado(tirada)
	)

	linea.add_child(dados)
	linea.add_child(nombre)
	linea.add_child(total)
	margen.add_child(linea)
	fila.add_child(margen)

	if tirada.modo != Dados.Modo.NORMAL:

		fila.tooltip_text = "%s · d20 %s%s" % [
			tirada.nombre_modo(),
			tirada.texto_dados(),
			tirada.texto_bono(),
		]

	lista_tiradas.add_child(fila)
	lista_tiradas.move_child(fila, 0)

	while lista_tiradas.get_child_count() > MAX_HISTORIAL_TIRADAS:

		var viejo := lista_tiradas.get_child(
			lista_tiradas.get_child_count() - 1
		)
		lista_tiradas.remove_child(viejo)
		viejo.queue_free()


func _ocultar_tarjeta_tirada() -> void:

	tarjeta_tirada.visible = false
