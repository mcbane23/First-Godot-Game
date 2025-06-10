extends Node2D

@export var player_controller : PlayerController
@export var animation_player : AnimatedSprite2D

func _process(delta):
	# handle player turning
	if player_controller.direction == 1:
		animation_player.flip_h = false
	elif player_controller.direction == -1:
		animation_player.flip_h = true

	# plays movement animation
	if player_controller.velocity.y < 0.0 :
		animation_player.play("jump")
	elif player_controller.velocity.y > 0.0 :
		animation_player.play("fall")
	elif abs(player_controller.velocity.x) > 0.0 :
		animation_player.play("walk")
	else:
		animation_player.play("idle")
