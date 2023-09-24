extends Control

#healthover
#health_under
#health
export (Color) var healthy_color = Color.green
export (Color) var caustion_color = Color.yellow
export (Color) var critical_color = Color.red

onready var health_bar = $Healthbar

#func _on_health_updated(health,amount):
#	health_bar.value = health

func _on_max_health_updated(max_health):
	health_bar.max_value = max_health

#func update_healthbar(value):
#	healthbar.texture_progress = bar_green
#	if value < healthbar.max_value * 0.7:
#		healthbar.texture_progress = bar_yellow
#	if value < healthbar.max_value * 0.35:
#		healthbar.texture_progress = bar_red
#	if value < healthbar.max_value:
#		show()
#	healthbar.value = value
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HealthTimer_timeout():
	print_debug("Time's out")
	if health_bar.value > 0:
		health_bar.value -= 5
