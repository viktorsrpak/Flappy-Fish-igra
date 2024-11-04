extends Node

@export var pipe_scene : PackedScene
@onready var start_button: Button = $StartButton
@onready var restart_button: Button = $RestartButton
@onready var high_score_label: Label = $HighScoreLabel

var game_running : bool = false
var game_over : bool = false
var scroll : float = 0.0
var score : int = 0
var high_score : int = 0
const SCROLL_SPEED : float = 200.0
var screen_size : Vector2
var ground_height : int
var pipes : Array = []
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

func _ready():
	screen_size = get_window().size
	$StartButton.z_index = 1
	$RestartButton.z_index = 1
	$HighScoreLabel.z_index = 1
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$StartButton.show()
	$RestartButton.hide()
	$ScoreLabel.text = "SCORE: " + str(score)
	high_score_label.text = "HIGH SCORE: " + str(high_score)
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipes()
	$Fish.reset()

func _input(event):
	if not game_over:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not game_running:
				start_game()
			else:
				if $Fish.flying:
					$Fish.flap()
					check_top()

func start_game():
	game_running = true
	$Fish.flying = true
	$Fish.flap()
	$PipeTimer.start()
	$StartButton.hide()
	$RestartButton.hide()

func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED * delta
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED * delta

func _on_pipe_timer_timeout():
	generate_pipes()

func generate_pipes():
	if pipe_scene != null:
		var pipe = pipe_scene.instantiate()
		pipe.position.x = screen_size.x + PIPE_DELAY
		pipe.position.y = (screen_size.y - ground_height) / 2.0 + randi_range(-PIPE_RANGE, PIPE_RANGE)
		pipe.hit.connect(fish_hit)
		pipe.scored.connect(scored)
		add_child(pipe)
		pipes.append(pipe)
	else:
		print("Greška: Pipe nije postavljen.")

func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)

func check_top():
	if $Fish.position.y < 0:
		$Fish.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$RestartButton.show()
	$Fish.flying = false
	game_running = false
	game_over = true
	update_high_score()

func update_high_score():
	if score > high_score:
		high_score = score
		high_score_label.text = "HIGH SCORE: " + str(high_score)

func fish_hit():
	$Fish.falling = true
	stop_game()

func _on_ground_hit():
	$Fish.falling = false
	stop_game()

func _on_start_button_pressed() -> void:
	start_game()

func _on_restart_button_button_down() -> void:
	new_game()
