extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("You died")
	# The hero handles their own death (game over screen, restart delay).
	if body.has_method("die"):
		body.die()
	else:
		timer.start()


func _on_timer_timeout():
	get_tree().reload_current_scene()
