extends Node2D

@export var player_controller : PlayerController
@export var animation_player : AnimatedSprite2D

func _process(delta):
	# handle player turning
	if player_controller.facing == 1:
		animation_player.flip_h = false
	elif player_controller.facing == -1:
		animation_player.flip_h = true

	if player_controller.is_dead:
		animation_player.play("fall")
		return

	# the sword swing owns the sprite for as long as it lasts
	if player_controller.is_attacking:
		if animation_player.animation != "attack":
			animation_player.play("attack")
		return

	# plays movement animation
	if player_controller.velocity.y < 0.0 :
		animation_player.play("jump")
	elif player_controller.velocity.y > 0.0 :
		animation_player.play("fall")
	elif abs(player_controller.velocity.x) > 0.0 :
		animation_player.play("walk")
	else:
		animation_player.play("idle")
