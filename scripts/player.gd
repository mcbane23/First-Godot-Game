extends CharacterBody2D
class_name PlayerController

#@onready var animation_player = $AnimationPlayer2

@export var speed = 10
@export var jump_power = 10

var speed_multiplier = 30
var jump_multiplier = -30
var direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("game_jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier
		#animation_player.play("jump");
		
	# Handle attack.
	#if Input.is_action_just_pressed("game_attack"):
		#animation_player.play("attack");
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("game_left", "game_right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()
