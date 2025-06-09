extends CanvasLayer
@onready var left = $Left
@onready var right = $Right
@onready var jump = $Jump
@onready var attack = $Attack


func _on_left_pressed():
	left.modulate.a = 0.5


func _on_left_released():
	left.modulate.a = 1


func _on_right_pressed():
	right.modulate.a = 0.5


func _on_right_released():
	right.modulate.a = 1


func _on_jump_pressed():
	jump.modulate.a = 0.5


func _on_jump_released():
	jump.modulate.a = 1


func _on_attack_pressed():
	attack.modulate.a = 0.5


func _on_attack_released():
	attack.modulate.a = 1
