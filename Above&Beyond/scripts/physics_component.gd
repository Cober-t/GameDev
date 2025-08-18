# PhysicsComponent.gd
# Component that manages physics-related properties
class_name PhysicsComponent
extends Node

@export_group("Physics Properties")
@export var friction: float = 0.0
@export var bounciness: float = 0.0
@export var default_gravity_scale: float = 1.0

# Internal physics state
var velocity: Vector2 = Vector2.ZERO
var ground_gravity: float = 1.0
var gravity_scale: float = 0.0
var gravity_multiplier: float = 1.0

func _ready():
	gravity_multiplier = default_gravity_scale
