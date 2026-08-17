extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var health_bar = $HealthBar
@onready var health_value = $HealthBar/HealthValue
@onready var game_over_label = $GameOverLabel


func _ready():
	Score.score_changed.connect(_on_score_changed)
	_on_score_changed(Score.score)

	game_over_label.hide()

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	_on_player_health_changed(player.health, player.max_health)


func _on_score_changed(new_score):
	score_label.text = "Score: %d" % new_score


func _on_player_health_changed(current, maximum):
	health_bar.max_value = maximum
	health_bar.value = current
	health_value.text = "%d / %d" % [ceil(current), ceil(maximum)]


func _on_player_died():
	game_over_label.show()
