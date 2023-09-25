extends Node

var player
var is_player_close = false
var enter_climbing = false
var climb = false
var exit_climbing = false
var original_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# I know this is insanely ugly, but I don't care B)
func _process(delta):
	if is_player_close == true:
		$Label.show()
		if Input.is_action_just_pressed("jump"):
			enter_climbing = true
			player.is_climbing = true
	if exit_climbing == true:
		player.global_position.x += delta * 50.0
		if player.global_position.x > original_pos + 30.0:
			exit_climbing = false
			enter_climbing = false
			climb = false
			is_player_close = false
			player.is_climbing = false
			player._velocity.y = 0.0
			player.fall_speed = 0.0
	elif enter_climbing == true:
		if climb == true:
			player.global_translate(Vector2(0.0, -1.0))
			if player.global_position.y < 310.0:
				exit_climbing = true
				original_pos = player.global_position.x
		else:
			player.global_position.x = player.global_position.move_toward(self.global_position, delta * 100.0).x
			if abs(player.global_position.x - self.global_position.x) < 1.2:
				climb = true


func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		player = body
		is_player_close = true


func _on_Area2D_body_exited(body):
	is_player_close = false
	$Label.hide()
