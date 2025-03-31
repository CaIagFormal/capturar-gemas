class_name Coletor
extends Area2D

@export var aceleracao: float = 250.0
@export var inercia_parar: float = 0.75
@export var inercia_mover: float = 0.80
@onready var colisao: CollisionShape2D = $CollisionShape2D

var velocidade: float = 0

signal gema_capturada

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	var eixox: float  = Input.get_axis("esquerda","direita")
	velocidade += eixox * aceleracao
	velocidade *= (inercia_parar if (eixox==0) else inercia_mover)
	position.x += velocidade * delta
	
	if position.x > get_viewport_rect().size.x-(colisao.shape.height/2):
		position.x = get_viewport_rect().size.x-(colisao.shape.height/2)
		velocidade = 0
	elif position.x < (colisao.shape.height/2):
		position.x = (colisao.shape.height/2)
		velocidade = 0

func _ao_tocar_gema(gema: Gema) -> void:
	gema_capturada.emit(gema,self)
