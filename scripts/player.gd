extends CharacterBody2D
class_name PlayerController

signal health_changed(current, maximum)
signal died

@export var speed = 10
@export var jump_power = 10

@export_group("Combat")
## Hit points the hero starts a life with.
@export var max_health := 100.0
## Damage a single sword swing deals to an enemy.
@export var attack_damage := 15.0
## How long the swing lasts, in seconds. Matches the "attack" animation.
@export var attack_duration := 0.35
## Extra recovery after the swing before the hero may attack again.
@export var attack_recovery := 0.15
## Seconds the hero cannot be hurt again after taking a hit.
@export var invulnerability_time := 0.8
## How hard a hit throws the hero away from whatever hurt them.
@export var knockback_force := 220.0

# The part of the swing that actually connects, in seconds from its start.
const HIT_WINDOW_START = 0.08
const HIT_WINDOW_END = 0.22
# How long the death animation plays before the level restarts.
const RESTART_DELAY = 1.5

var speed_multiplier = 30
var jump_multiplier = -30
var direction = 0
# Last direction the hero faced, so the sword swings the right way when standing still.
var facing = 1
var health := max_health
var is_attacking := false
var is_dead := false

var _attack_time := 0.0
var _recovery_time := 0.0
var _invulnerable_time := 0.0
# Enemies already hit by the current swing, so one swing damages each enemy once.
var _hit_this_swing: Array = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var _attack_offset = attack_shape.position.x


func _ready():
	health = max_health
	health_changed.emit(health, max_health)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)
		move_and_slide()
		return

	_update_timers(delta)

	# Handle jump.
	if Input.is_action_just_pressed("game_jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("game_left", "game_right")
	if direction:
		facing = 1 if direction > 0 else -1
		# Swinging the sword slows the hero down instead of stopping them dead.
		var move_speed = speed * speed_multiplier
		if is_attacking:
			move_speed *= 0.4
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	if Input.is_action_just_pressed("game_attack"):
		_start_attack()

	_update_attack(delta)

	move_and_slide()


func _update_timers(delta):
	_recovery_time = max(_recovery_time - delta, 0.0)

	if _invulnerable_time > 0.0:
		_invulnerable_time = max(_invulnerable_time - delta, 0.0)
		# Blink while the hero cannot be hurt again.
		modulate.a = 0.4 if int(_invulnerable_time * 20) % 2 == 0 else 1.0
		if _invulnerable_time == 0.0:
			modulate.a = 1.0


func _start_attack():
	if is_attacking or _recovery_time > 0.0:
		return

	is_attacking = true
	_attack_time = 0.0
	_hit_this_swing.clear()
	attack_shape.position.x = _attack_offset * facing


func _update_attack(delta):
	if not is_attacking:
		return

	_attack_time += delta
	if _attack_time >= HIT_WINDOW_START and _attack_time <= HIT_WINDOW_END:
		_damage_enemies_in_range()

	if _attack_time >= attack_duration:
		is_attacking = false
		_recovery_time = attack_recovery


func _damage_enemies_in_range():
	for area in attack_area.get_overlapping_areas():
		var enemy = area.get_parent()
		if enemy == null or not enemy.has_method("take_damage"):
			continue
		if enemy in _hit_this_swing:
			continue
		_hit_this_swing.append(enemy)
		enemy.take_damage(attack_damage)


## Hurts the hero. `from_position` decides which way the knockback throws them.
func take_damage(amount: float, from_position := Vector2.ZERO):
	if is_dead or _invulnerable_time > 0.0:
		return

	health = max(health - amount, 0.0)
	health_changed.emit(health, max_health)

	if health <= 0.0:
		die()
		return

	_invulnerable_time = invulnerability_time

	var away = 0.0
	if from_position != Vector2.ZERO:
		away = signf(global_position.x - from_position.x)
	if away == 0.0:
		away = -facing
	velocity.x = away * knockback_force
	velocity.y = -knockback_force * 0.6


## Kills the hero outright, whatever their health is (used by the fall-out zone).
func die():
	if is_dead:
		return

	is_dead = true
	is_attacking = false
	health = 0.0
	health_changed.emit(health, max_health)
	modulate = Color(1, 0.4, 0.4, 0.7)
	died.emit()
	_restart_level()


func _restart_level():
	await get_tree().create_timer(RESTART_DELAY).timeout
	get_tree().reload_current_scene()
