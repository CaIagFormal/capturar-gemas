class_name Coletor
extends Area2D

@export var aceleracao: float = 300.0
@export var inercia_parar: float = 0.75
@export var inercia_mover: float = 0.80
@export var jogador: int = 1
@onready var colisao: CollisionShape2D = $CollisionShape2D
@onready var visual: Sprite2D = $Sprite2D
var cores_jogadores: Array[Color] = [Color(0,255,255),Color(0,255,255),Color(255,0,255),Color(0,255,0)]

var velocidade: float = 0

signal gema_capturada

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	var eixox: float  = Input.get_axis("esquerda_p"+str(jogador),"direita_p"+str(jogador))
	velocidade += eixox * aceleracao
	velocidade *= (inercia_parar if (eixox==0) else inercia_mover)
	position.x += velocidade * delta
	
	if position.x > get_viewport_rect().size.x-(colisao.shape.height/2):
		position.x = get_viewport_rect().size.x-(colisao.shape.height/2)
		velocidade = 0
	elif position.x < (colisao.shape.height/2):
		position.x = (colisao.shape.height/2)
		velocidade = 0

func _ao_tocar_gema(gema: Object) -> void:
	if (gema is Coletor):
		return
	gema_capturada.emit(gema,self)
	
func tamanho(width: float) -> void:
	scale = Vector2(width,1)
	
func colorir() -> void:
	visual.modulate = cores_jogadores[jogador]
	
