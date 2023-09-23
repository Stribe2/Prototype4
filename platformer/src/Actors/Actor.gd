class_name Actor
extends KinematicBody2D

# I have removed the enemy, so this is only being used for the player now.

export var base_velocity = 15.0
export var acceleration = 125.0
export var max_velocity_walking = 40.0
export var jump_force = 100.0
export var max_velocity_sprinting = 80.0
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP

var _velocity = Vector2.ZERO


# _physics_process is called after the inherited _physics_process function.
# This allows the Player and Enemy scenes to be affected by gravity.
func _physics_process(delta):
	_velocity.y += gravity * delta
