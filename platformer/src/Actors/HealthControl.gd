extends Control

#healthover
#health_under
#health
export (Color) var healthy_color = Color.green
export (Color) var caution_color = Color.yellow
export (Color) var critical_color = Color.red
var caution_zone = 0.6
var critical_zone = 0.4
# seconds to heal a bit of health
var time = 5
#onready var health_bar = $Healthbar
onready var heal_timer = $HealTimer
onready var health_timer = $HealthTimer
onready var health_bar = $Healthbar


func _ready():
	health_bar.tint_progress = healthy_color

#Heals the player by 1 every seconds for time_left:
func heal(time_left):
	if(time > 0):
		health_timer.paused = true
		time = time_left
		time -= 1
		heal_timer.start()
		if health_bar.value > 0:
			health_bar.value += 5
	if(time == 0):
		health_timer.paused = false
		
func stop_heal():
	heal_timer.paused = false


#Assign color to healthbar based on health lost:
func _assign_color(health):
	if health < health_bar.max_value * critical_zone:
		health_bar.tint_progress = critical_color
	elif health < health_bar.max_value * caution_zone:
		health_bar.tint_progress = caution_color
	else:
		health_bar.tint_progress = healthy_color

#This drains the health by 5 every second
func _on_HealthTimer_timeout():
	if health_bar.value > 0:
		health_bar.value -= 5

func _on_Timer_timeout():
	heal(time)


func _process(_delta):
	if GlobalVar.get_can_be_healed() && heal_timer.is_stopped():
		heal(time)
	if health_bar.value == 0:
		GlobalVar.update_is_game_over(true)


func _on_Healthbar_value_changed(value):
	_assign_color(value)
