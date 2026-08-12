extends CanvasLayer

@onready var score_label = $ScoreLabel


func _ready():
	Score.score_changed.connect(_on_score_changed)
	_on_score_changed(Score.score)


func _on_score_changed(new_score):
	score_label.text = "Score: %d" % new_score
