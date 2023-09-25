extends Light2D



var is_player_nearby = false
var is_lit = false # for health(sanity)
var is_in_healing_distance = false
onready var torch_animation = $AnimatedTorch
onready var light_Timer = $LightTimer
onready var torch_Area = $TorchArea

# Sets torch animation to Unlit, disables torch's light
func _ready():
	torch_animation.set_animation("Unlit")
	set_enabled(false)

#  Set torch animation to Lit and starts timer
func light_torch():
	light_Timer.start()
	is_lit = true
	torch_animation.set_animation("Lit")
	torch_animation.set_playing(true)
	set_enabled(true)

#Player colliding with torch - they are nearby/ close enough to lit it
func _on_TorchArea_body_entered(_body):
	is_player_nearby = true

#Timeout for timer - sets the animation to Unlit (no lights etc.)
func _on_LightTimer_timeout():
	torch_animation.set_animation("Unlit")
	torch_animation.set_playing(false)
	set_enabled(false)
	is_lit = false

#Player is not colliding with the torch. Player is therefor not nearby
func _on_TorchArea_body_exited(_body):
	is_player_nearby = false

#If torch is lit: then start healing, else: do nothing
func _on_HealthArea_body_entered(_body):
	is_in_healing_distance = true

#If it's over time: stop the healing when exiting:
func _on_HealthArea_body_exited(_body):
	is_in_healing_distance = false
	if is_lit:
		GlobalVar.update_can_be_healed(false)
# Check if player has interacted with the torch: then if they can be healed
func _process(_delta): 
	if is_player_nearby && Input.is_action_just_pressed("lit_torch"): 
		light_torch()
	if is_lit && is_in_healing_distance:
		GlobalVar.update_can_be_healed(true)
