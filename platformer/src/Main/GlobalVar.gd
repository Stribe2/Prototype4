extends Node


# Declare member variables here. Examples:
var can_be_healed = false
var is_game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_can_be_healed(can_heal):
		can_be_healed = can_heal

func update_is_game_over(game):
		is_game_over = game
func get_can_be_healed():
	return can_be_healed
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
