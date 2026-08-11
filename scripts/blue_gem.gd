extends Area2D

func _on_body_entered(body):
	Score.add_gem()
	queue_free()
