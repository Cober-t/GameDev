extends State
class_name PlayerJump

@export var player : PlayerController

@onready var mv: MovementComponent = null

# --------------------------------------------------------

func Enter() -> void:
	#print("PLAYER ENTER JUMP STATE")
	if not player:
		return

	if player.has_node("MovementComponent"):
		mv = player.get_node("MovementComponent")
	if player.animated_sprite_2d:
		player.animated_sprite_2d.play("jump")

# --------------------------------------------------------

func Exit() -> void:
	#print("PLAYER EXIT JUMP STATE")
	pass
	
# --------------------------------------------------------

func Update(_delta: float) -> void:
	#print("PLAYER JUMP UPDATE STATE")
	pass

# --------------------------------------------------------

func PhysicsUpdate(_delta: float) -> void:
	#print("PLAYER JUMP PHYSICS UPDATE STATE")
	if not mv:
		return

	if mv.on_floor:
		if mv.direction != 0:
			Transitioned.emit(self, "walk")
		else:
			Transitioned.emit(self, "idle")

# --------------------------------------------------------
