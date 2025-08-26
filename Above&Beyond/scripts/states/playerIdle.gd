extends State
class_name PlayerIdle

@export var player : PlayerController

@onready var mv: MovementComponent  = null

# --------------------------------------------------------

func Enter() -> void:
	#print("PLAYER ENTER IDLE STATE")
	if not player:
		return

	if player.has_node("MovementComponent"):
		mv = player.get_node("MovementComponent")
	if player.animated_sprite_2d:
		player.animated_sprite_2d.play("idle")

# --------------------------------------------------------

func Exit() -> void:
	#print("PLAYER EXIT IDLE STATE")
	pass
	
# --------------------------------------------------------

func Update(_delta: float) -> void:
	#print("PLAYER IDLE UPDATE STATE")
	pass

# --------------------------------------------------------

func PhysicsUpdate(_delta: float) -> void:
	if not mv:
		return

	if mv.on_floor and mv.direction != 0:
		Transitioned.emit(self, "walk")
	elif not mv.on_floor and mv.velocity.y < 0: # going up
		Transitioned.emit(self, "jump")
	pass

# --------------------------------------------------------
