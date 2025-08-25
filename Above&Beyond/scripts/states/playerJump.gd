extends State
class_name PlayerJump

@export var player : CharacterBody2D

@onready var mv: MovementComponent

# --------------------------------------------------------

func Enter() -> void:
	print("PLAYER ENTER JUMP STATE")
	if player and player.has_node("MovementComponent"):
		mv = player.get_node("MovementComponent")
	else:
		mv = null

# --------------------------------------------------------

func Exit() -> void:
	print("PLAYER EXIT JUMP STATE")
	
# --------------------------------------------------------

func Update(_delta: float) -> void:
	#print("PLAYER JUMP UPDATE STATE")
	pass

# --------------------------------------------------------

func PhysicsUpdate(_delta: float) -> void:
	print("PLAYER JUMP PHYSICS UPDATE STATE")
	if not mv:
		return

	if mv.on_floor:
		if mv.direction != 0:
			Transitioned.emit(self, "walk")
		else:
			Transitioned.emit(self, "idle")

# --------------------------------------------------------
