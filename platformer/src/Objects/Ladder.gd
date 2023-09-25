extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player
var is_player_climbing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_player_climbing == true:
		player.global_translate(Vector2(0.2, -3.0))


func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		player = body
		player.is_climbing = true
		is_player_climbing = true
		print("time to climb boi!")


func _on_Area2D_body_exited(body):
	pass # Replace with function body.
