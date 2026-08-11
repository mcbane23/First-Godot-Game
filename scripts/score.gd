extends Node

const points_per_gem = 100

signal score_changed(new_score)

var score = 0


func add_gem():
	score += points_per_gem
	score_changed.emit(score)


func reset():
	score = 0
	score_changed.emit(score)
