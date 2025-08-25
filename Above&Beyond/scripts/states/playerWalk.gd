extends State
class_name PlayerWalk

@export var player : CharacterBody2D

@onready var mv: MovementComponent

# --------------------------------------------------------

func Enter() -> void:
	print("PLAYER ENTER WALK STATE")
	if player and player.has_node("MovementComponent"):
		mv = player.get_node("MovementComponent")
	else:
		mv = null

# --------------------------------------------------------

func Exit() -> void:
	print("PLAYER EXIT WALK STATE")
	pass
	
# --------------------------------------------------------

func Update(_delta: float) -> void:
	#print("PLAYER WALK UPDATE STATE")
	pass

# --------------------------------------------------------

func PhysicsUpdate(_delta: float) -> void:
	print("PLAYER PHYSICS WALK STATE")
	if not mv:
		return

	if mv.on_floor and mv.direction == 0:
		Transitioned.emit(self, "idle")
	elif mv.velocity.y < 0: # going up
		Transitioned.emit(self, "jump")

# --------------------------------------------------------
