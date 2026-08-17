extends Node2D
class_name Enemy

signal died

## Patrol speed in pixels per second.
@export var speed := 120.0

@export_group("Combat")
## Hits the enemy can soak up before it dies.
@export var max_health := 30.0
## Damage dealt to the hero on contact. Tougher enemies hit harder.
@export var contact_damage := 10.0
## Seconds between two contact hits, so touching an enemy is not instant death.
@export var contact_cooldown := 1.0
## Score awarded for landing a hit on this enemy.
@export var points_per_hit := 10
## Extra score awarded for killing it. Tougher enemies are worth more.
@export var points_per_kill := 50

var direction = 1
var health := max_health
var is_dead := false

var _contact_time := 0.0
var _flash_tween: Tween

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ledge_right = $LedgeRight
@onready var ledge_left = $LedgeLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var health_bar = $HealthBar


func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	# The bar only shows up once the enemy has actually been hurt.
	health_bar.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead:
		return

	# Turn around at walls, and at the edge of the ground being walked on.
	if ray_cast_right.is_colliding() or (direction > 0 and not ledge_right.is_colliding()):
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding() or (direction < 0 and not ledge_left.is_colliding()):
		direction = 1
		animated_sprite.flip_h = false

	position.x += delta * speed * direction


func _physics_process(delta):
	if is_dead:
		return

	_contact_time = max(_contact_time - delta, 0.0)
	if _contact_time > 0.0:
		return

	for body in hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(contact_damage, global_position)
			_contact_time = contact_cooldown
			break


## Takes a swing from the hero, and scores it.
func take_damage(amount: float, _from_position := Vector2.ZERO):
	if is_dead:
		return

	health = max(health - amount, 0.0)
	health_bar.value = health
	health_bar.show()
	Score.add_enemy_hit(points_per_hit)
	_flash()

	if health <= 0.0:
		_die()


func _flash():
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(animated_sprite, "modulate", Color(1, 0.4, 0.4), 0.05)
	_flash_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.15)


func _die():
	is_dead = true
	# Stop the hit flash so it cannot undo the fade-out below.
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	animated_sprite.modulate = Color.WHITE
	Score.add_enemy_kill(points_per_kill)
	died.emit()

	set_physics_process(false)
	# Deferred: collision state cannot be changed while physics is resolving.
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	health_bar.hide()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.4)
	tween.tween_property(self, "position:y", position.y - 20.0, 0.4)
	tween.chain().tween_callback(queue_free)
