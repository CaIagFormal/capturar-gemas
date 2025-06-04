extends Node2D

@export var cena_de_gema: PackedScene
@export var cena_de_joojador: PackedScene
@export var gemas_limite: int
@onready var placar: Label = $Placar
@onready var placar_recorde: Label = $Placarzinho
@onready var timer: Timer = $Timer
@onready var coletores: Array[Coletor]
@onready var reset: Button = $REINICIAR
var pontuacao: int = 0
var gemas: int = 0
var gameover_label: Label
var efeito: Sprite2D
var lbl_fs: float = 0
var pause: bool = false
var gameover: bool = false
var tamanho: float = 1
var joojadores: int = 1
@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var sfx_gema: AudioStreamPlayer2D = $SFXGema
var highscore: FileAccess = FileAccess.open("res://highscore.dat", FileAccess.READ_WRITE)
var recorde_val: int

const KABOOM = preload("res://assets/explode.wav")
const mp_music = preload("res://assets/owen_was_her.mp3")

func gerar_gema() -> void:
	if gemas>=gemas_limite:
		return;
	gemas += 1;

	var nova_gema: Gema = cena_de_gema.instantiate()
	nova_gema.rng = RandomNumberGenerator.new()
	nova_gema.rng.randomize()
	nova_gema.vida = nova_gema.rng.randf_range(1,5+(joojadores*3))
	nova_gema.definir_scale()
	if joojadores==1:
		timer.wait_time = (nova_gema.vida * 2)
	else:
		timer.wait_time = 1
	timer.start()
	add_child(nova_gema)
	nova_gema.saiu_da_tela.connect(_ao_gema_sair_da_tela)

func _ready() -> void:
	if highscore == null:
		highscore = FileAccess.open("res://highscore.dat", FileAccess.WRITE_READ)
		highscore.seek(0)
		highscore.store_16(0)
		highscore.flush()
		
	highscore.seek(0)
	recorde_val = highscore.get_16();
	placar_recorde.text = "Recorde Atual: "+str(recorde_val).pad_zeros(5)
	gerar_gema()
	coletores.append($Coletor)

func _ao_tempo_expirar() -> void:
	gerar_gema()

func game_over() -> void:
	var texto_game_over: String = "Game Over!"
	if recorde_val<pontuacao:
		highscore.seek(0)
		highscore.store_16(pontuacao)
		highscore.close()
		texto_game_over = "Novo Recorde!!"
	
	timer.stop()
	bgm.stop()
	sfx_gema.stop()
	sfx_gema.stream = KABOOM
	sfx_gema.pitch_scale = 1
	sfx_gema.volume_db = 1
	sfx_gema.play()
	reset.visible = true;
	
	for child in get_children():
		child.set_process(false)
	set_process(true)
	apresentar_mensagem_game_over(texto_game_over)
	apresentar_efeito()
	gameover = true;
	
func apresentar_efeito() -> void:
	efeito = Sprite2D.new()
	efeito.texture = load("res://assets/efeito.png")
	
func apresentar_mensagem_game_over(texto) -> void:
	#Cria a Label
	gameover_label = Label.new()	
	
	#Define estilos
	gameover_label.set("theme_override_colors/font_color",Color(255.0,255.0,0.0,0.8))
	gameover_label.set("theme_override_colors/font_shadow_color",Color(255.0,0.0,0.0))
	gameover_label.set("theme_override_colors/font_outline_color",Color(0.0,0.0,0.0))
	gameover_label.set("theme_override_constants/shadow_offset_x",2)
	gameover_label.set("theme_override_constants/shadow_offset_y",2)
	gameover_label.set("theme_override_constants/outline_size",7)
	gameover_label.set("theme_override_constants/shadow_outline_size",2)
	gameover_label.set("theme_override_font_sizes/font_size",48)
	
	#Define o texto a ser apresentado
	gameover_label.text = texto
	
	#Adiciona Label na tela
	add_child(gameover_label)
	_process(1)
	
func centraliza_game_over():
	
	#Centraliza a Label
	var janela = get_viewport().get_size()
	var label_size = gameover_label.get_rect().size
	gameover_label.position = Vector2(janela.x- label_size.x,janela.y - label_size.y)/2
	
	var efeito_size = efeito.get_rect().size
	efeito.position = Vector2(janela.x- efeito_size.x,janela.y - efeito_size.y)/2
	
	var recorde_size = placar_recorde.get_rect().size
	var target_position = Vector2(janela.x - recorde_size.x,janela.y + 200 - recorde_size.y)/2
	if placar_recorde.position == target_position:
		return
	placar_recorde.position += Vector2((target_position.x-placar_recorde.position.x)*0.05,(target_position.y-placar_recorde.position.y)*0.05)

	
	var placar_size = placar.get_rect().size
	target_position = Vector2(janela.x- placar_size.x,janela.y - placar_size.y+100)/2
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
	if (pontuacao>recorde_val):
		placar_recorde.text = "Recorde Atual: "+placar.text
		
	

func _ao_gema_sair_da_tela()-> void:
	game_over()
	
func _process(delta: float) -> void:
	if not gameover:
		if not pause:
			tamanho += 0.02*(0.1-tamanho)*delta
			for coletor in coletores:
				coletor.tamanho(tamanho)
			if joojadores==1 and (Input.is_action_just_pressed("direita_p2") or Input.is_action_just_pressed("esquerda_p2")):
				abrir_novo_joojador()
		if Input.is_action_just_pressed("pausar"):
			pause = not pause;
			for i in get_children():
				i.set_process(pause)
				timer.paused = not pause
				bgm.playing = pause
		return;
	gameover_label.rotation = 1-lbl_fs
	lbl_fs += 0.05*(1-lbl_fs)
	gameover_label.scale = Vector2(lbl_fs,lbl_fs)
	
	centraliza_game_over()
	if lbl_fs == 48:
		gameover = false
	
	""" para debug
func _process(delta: float) -> void:
	placar.text = str(timer.time_left)
	"""

func _on_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()
	
func abrir_novo_joojador() -> void:
	
	joojadores += 1
	var novo_joojador: Coletor = cena_de_joojador.instantiate()
	novo_joojador.jogador = joojadores
	novo_joojador.position = coletores[0].position
	novo_joojador.gema_capturada.connect(_ao_coletor_gema_capturada)
	add_child(novo_joojador)
	coletores.append(novo_joojador)
	for coletor in coletores:
		coletor.colorir()
	if bgm.stream != mp_music:
		bgm.stream = mp_music
		bgm.pitch_scale = 1
		bgm.volume_db = 1
		bgm.play()
	timer.wait_time = 1
	timer.start()
