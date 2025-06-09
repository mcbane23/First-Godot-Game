extends Area2D

func _on_body_entered(body):
	print("+1 gem")
	queue_free()
