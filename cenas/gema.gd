class_name Gema
extends Area2D

@export var aceleracao: float
@export var friccao: float
@export var varpeso: float

@export var velocidade: Vector2
var vida: int

@onready var visual: Sprite2D = $ElementRedDiamond
@onready var colisao: CollisionShape2D = $CollisionShape2D

signal saiu_da_tela

func definir_scale():
	var scale = 0.25+(vida*0.5)
	self.scale = Vector2(scale,scale)

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	position.x = rng.randf_range(30.0, get_viewport_rect().size.x -30)
	velocidade.x = rng.randf_range(-300,300)
	vida = rng.randf_range(1,5)
	
	definir_scale()
	
func _process(delta: float) -> void:
	velocidade.y += aceleracao + varpeso*vida
	velocidade.x *= friccao
	position.y += delta * velocidade.y
	position.x += delta * velocidade.x
	
	if position.x > get_viewport_rect().size.x-(colisao.shape.size.x/1.4):
		position.x = get_viewport_rect().size.x-(colisao.shape.size.x/1.4) # x/2*raiz 2 -> x/ raiz 2
		velocidade.x *= -1
	elif position.x < (colisao.shape.size.x/1.4):
		position.x = (colisao.shape.size.x/1.4)
		velocidade.x *= -1
	if position.y > get_viewport_rect().size.y:
		saiu_da_tela.emit()
		set_process(false)
		queue_free()
		
func capturar() -> bool:
	vida -= 1
	definir_scale()
	if (vida==0):
		set_process(false)
		queue_free()
		return true;
	return false;
