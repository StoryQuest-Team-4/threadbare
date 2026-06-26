extends Node
@onready var label: RichTextLabel = $CanvasLayer/Control/RichTextLabel
@onready var imagen: TextureRect = $CanvasLayer/Control/TextureRect
@onready var hint: Label = $CanvasLayer/Control/HintEspacio
var esperando_avance: bool = false
var escribiendo: bool = false
var parpadeo: Tween
var paneo: Tween
var tween_texto: Tween
signal avanzar
signal texto_completo
var secuencia: Array[Dictionary] = [
	{
		"texto": "Año 3100. Cusco ya no es la ciudad que fue. Las piedras antiguas siguen en pie, pero su historia se ha desvanecido entre luces de neon y olvido.",
		"imagen": null,
	},
	{
		"texto": "Cusi camina por la Plaza de Armas, como cada dia, sin saber que algo ha despertado en las sombras de la ciudad.",
		"imagen": preload("res://scenes/quests/story_quests/runa_runner/0_intro/Picture Intro/Gemini_Generated_Image_ywb85wywb85wywb8.png"),
	},
	{
		"texto": "De pronto, una sombra oscura se alza frente a ella. Dos ojos rojos brillan entre el humo negro, observandola fijamente.",
		"imagen": preload("res://scenes/quests/story_quests/runa_runner/0_intro/Picture Intro/Gemini_Generated_Image_jau20ejau20ejau2.png"),
	},
	{
		"texto": "No hay tiempo para preguntas. La criatura avanza y Wayra solo puede hacer una cosa: correr.",
		"imagen": null,
	},
	{
		"texto": "Un portal se abre bajo sus pies, brillando con un simbolo que ella jamas habia visto, pero que de alguna forma reconoce.",
		"imagen": preload("res://scenes/quests/story_quests/runa_runner/0_intro/Picture Intro/Gemini_Generated_Image_nv0l4tnv0l4tnv0l.png"),
	},
	{
		"texto": "Cusi cae a traves de el, dejando atras el Cusco futurista... y a la sombra que aun la sigue.",
		"imagen": null,
	},
	{
		"texto": "Al abrir los ojos, el aire es distinto. Las montañas se alzan ante ella, verdes y vivas, bañadas por un sol que creia olvidado.",
		"imagen": preload("res://scenes/quests/story_quests/runa_runner/0_intro/Picture Intro/Gemini_Generated_Image_p5kprip5kprip5kp.png"),
	},
	{
		"texto": "El Valle Sagrado se extiende frente a ella. Wayra no sabe como llego aqui, pero algo le dice que esta historia comienza ahora.",
		"imagen": null,
	},
	{
		"texto": "El portal la habia teletransportado directo al Valle Sagrado. Ahora debia encontrar una forma de volver... antes de que la sombra la encontrara primero.",
		"imagen": null,
	},
]
func _ready() -> void:
	imagen.visible = false
	label.visible = false
	hint.visible = false
	await get_tree().create_timer(0.5).timeout
	await reproducir_intro()
	SceneSwitcher.change_to_file(
		"res://scenes/quests/story_quests/runa_runner/0_intro/Intro_segunda_parte.tscn"
	)
func reproducir_intro() -> void:
	for paso: Dictionary in secuencia:
		var texto: String = paso["texto"] as String
		var textura: Texture2D = paso["imagen"] as Texture2D
		label.text = texto
		label.visible_ratio = 0.0
		label.visible = true
		imagen.visible = false
		await fadeIn(label)
		escribiendo = true
		tween_texto = create_tween()
		tween_texto.tween_property(label, "visible_ratio", 1.0, texto.length() * 0.05)
		tween_texto.finished.connect(_on_texto_finalizado, CONNECT_ONE_SHOT)
		await texto_completo
		escribiendo = false
		await esperar_tecla()
		await fadeOut(label)
		if textura != null:
			imagen.texture = textura
			imagen.visible = true
			imagen.pivot_offset = imagen.size / 2
			imagen.scale = Vector2(1.3, 1.3)
			imagen.position.x = 0
			imagen.position.y = -25
			await fadeIn(imagen)
			animar_imagen()
			await esperar_tecla()
			paneo.kill()
			await fadeOut(imagen)
func _on_texto_finalizado() -> void:
	texto_completo.emit()
func animar_imagen() -> void:
	paneo = create_tween()
	paneo.tween_property(imagen, "position:y", 25, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
func esperar_tecla() -> void:
	esperando_avance = true
	hint.visible = true
	hint.pivot_offset = hint.size / 2
	parpadeo = create_tween().set_loops()
	parpadeo.tween_property(hint, "scale", Vector2(1.15, 1.15), 0.5).set_trans(Tween.TRANS_SINE)
	parpadeo.tween_property(hint, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE)
	await avanzar
	parpadeo.kill()
	hint.scale = Vector2(1.0, 1.0)
	hint.visible = false
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if escribiendo:
			tween_texto.kill()
			label.visible_ratio = 1.0
			escribiendo = false
			texto_completo.emit()
		elif esperando_avance:
			esperando_avance = false
			avanzar.emit()
func fadeIn(nodo: CanvasItem) -> void:
	nodo.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(nodo, "modulate:a", 1.0, 0.6)
	await tween.finished
func fadeOut(nodo: CanvasItem) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(nodo, "modulate:a", 0.0, 0.6)
	await tween.finished
