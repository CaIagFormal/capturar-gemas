extends Node2D

@export var cena_de_gema: PackedScene
@export var gemas_limite: int
@onready var placar: Label = $Placar
@onready var timer: Timer = $Timer
var pontuacao: int = 0
var gemas: int = 0
var label: Label
var efeito: Sprite2D
var lbl_fs: float = 0
var gameover: bool = false
@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var sfx_gema: AudioStreamPlayer2D = $SFXGema

const KABOOM = preload("res://assets/explode.wav")

func gerar_gema() -> void:
	if gemas>=gemas_limite:
		return;
	gemas += 1;
	var nova_gema: Gema = cena_de_gema.instantiate()
	timer.wait_time = (nova_gema.vida * 5) + 1
	timer.start()
	add_child(nova_gema)
	nova_gema.saiu_da_tela.connect(_ao_gema_sair_da_tela)

func _ready() -> void:
	gerar_gema()

func _ao_tempo_expirar() -> void:
	gerar_gema()

func game_over() -> void:
	timer.stop()
	bgm.stop()
	sfx_gema.stop()
	sfx_gema.stream = KABOOM
	sfx_gema.volume_db = 1000
	sfx_gema.play()
	for child in get_children():
		child.set_process(false)
	set_process(true)
	apresentar_mensagem_game_over()
	apresentar_efeito()
	gameover = true;
	
func apresentar_efeito() -> void:
	efeito = Sprite2D.new()
	efeito.texture = load("res://assets/efeito.png")
	
func apresentar_mensagem_game_over() -> void:
	#Cria a Label
	label = Label.new()	
	
	#Define estilos
	label.set("theme_override_colors/font_color",Color(255.0,255.0,0.0,0.8))
	label.set("theme_override_colors/font_shadow_color",Color(255.0,0.0,0.0))
	label.set("theme_override_colors/font_outline_color",Color(0.0,0.0,0.0))
	label.set("theme_override_constants/shadow_offset_x",2)
	label.set("theme_override_constants/shadow_offset_y",2)
	label.set("theme_override_constants/outline_size",7)
	label.set("theme_override_constants/shadow_outline_size",2)
	label.set("theme_override_font_sizes/font_size",48)
	
	#Define o texto a ser apresentado
	label.text = "Game Over!"
	
	#Adiciona Label na tela
	add_child(label)
	_process(1)
func centraliza_game_over():
	
	#Centraliza a Label
	var janela = get_viewport().get_size()
	var label_size = label.get_rect().size
	label.position = Vector2(janela.x- label_size.x,janela.y - label_size.y)/2
	
	var efeito_size = efeito.get_rect().size
	efeito.position = Vector2(janela.x- efeito_size.x,janela.y - efeito_size.y)/2
	
	var placar_size = placar.get_rect().size
	var target_position = Vector2(janela.x- placar_size.x,janela.y - placar_size.y+100)/2
	if placar.position == target_position:
		return
	placar.position += Vector2((target_position.x-placar.position.x)*0.05,(target_position.y-placar.position.y)*0.05)
func _ao_coletor_gema_capturada(gema: Gema,coletor: Coletor) -> void:
	sfx_gema.position = gema.position
	sfx_gema.pitch_scale = gema.vida
	sfx_gema.play()
	gema.position.y = coletor.position.y;
	gema.velocidade.y = gema.varpeso*-100*gema.vida-500
	gema.velocidade.x += coletor.velocidade / 4
	pontuacao += gema.vida
	if (gema.capturar()):
		gemas -= 1
	placar.text = str(pontuacao).pad_zeros(5)

func _ao_gema_sair_da_tela()-> void:
	game_over()
	
func _process(delta: float) -> void:
	if not gameover:
		return;
	label.rotation = 1-lbl_fs
	lbl_fs += 0.05*(1-lbl_fs)
	label.scale = Vector2(lbl_fs,lbl_fs)
	
	centraliza_game_over()
	if lbl_fs == 48:
		gameover = false
	
	""" para debug
func _process(delta: float) -> void:
	placar.text = str(timer.time_left)
	"""
