extends Node

const points_per_gem = 100

signal score_changed(new_score)

var score = 0


func add_gem():
	_add(points_per_gem)


## Awards points for landing a hit on an enemy.
func add_enemy_hit(points := 10):
	_add(points)


## Awards the bonus for finishing an enemy off.
func add_enemy_kill(points := 50):
	_add(points)


func reset():
	score = 0
	score_changed.emit(score)


func _add(points):
	score += points
	score_changed.emit(score)
