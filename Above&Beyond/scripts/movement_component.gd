# MovementComponent.gd
# Component that holds all movement-related parameters and state
class_name MovementComponent
extends Node

# Movement Parameters
@export_group("Basic Movement")
@export var max_speed: float = 225.0
@export var max_acceleration: float = 900.0
@export var max_deceleration: float = 1200.0
@export var max_turn_speed: float = 1200.0

@export_group("Air Movement")
@export var max_air_acceleration: float = 1200.0
@export var max_air_deceleration: float = 900.0
@export var max_air_turn_speed: float = 700.0

@export_group("Jump Parameters")
@export var jump_height: float = 2.75
@export var coyote_time: float = 0.085
@export var jump_buffer: float = 0.15
@export var time_to_jump_apex: float = 1.5
@export var fall_speed_limit: float = 10.0
@export var max_air_jumps: int = 1

@export_group("Variable Jump")
@export var variable_jump_height: bool = true
@export var max_jump_hold_time: float = 0.8
@export var min_jump_hold_time: float = 0.1
@export var jump_hold_gravity_multiplier: float = 0.6
@export var jump_release_gravity_multiplier: float = 2.5

@export_group("Gravity Multipliers")
@export var upward_movement_multiplier: float = 4.0
@export var downward_movement_multiplier: float = 5.0

@export_group("Peak Floatiness")
@export var enable_peak_floatiness: bool = true
@export var peak_velocity_threshold: float = 50.0
@export var peak_gravity_multiplier: float = 0.7

@export_group("Movement Options")
@export var use_acceleration: bool = true
@export var can_move: bool = true

# Internal state variables (not exported)
var desired_velocity: Vector2 = Vector2.ZERO
var last_direction: int = 1
var velocity: Vector2 = Vector2.ZERO
var max_speed_change: float = 0.0
var acceleration: float = 0.0
var deceleration: float = 0.0
var turn_speed: float = 0.0

# Movement state
var pressing_key: bool = false
var direction: float = 0.0

# Jump state
var jump_force: float = 0.0
var jump_buffer_counter: float = 0.0
var coyote_time_counter: float = 0.0
var air_jumps: int = 0
var jump_start_time: float = 0.0
var jump_hold_time: float = 0.0

# Jump flags
var on_floor: bool = false
var on_wall: bool = false
var pressing_jump: bool = false
var currently_jumping: bool = false
var desired_jump: bool = false
var jump_minimum_reached: bool = false

func _ready():
	# Initialize air jumps
	air_jumps = max_air_jumps
