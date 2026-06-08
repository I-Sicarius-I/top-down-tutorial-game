extends CanvasLayer

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var hearts_container: HBoxContainer = $Hearts

const HEART_SIZE: int = 20.0

const HEART_FULL = preload("res://assets/sprites/UI/player/heartf.png")
const HEART_HALF = preload("res://assets/sprites/UI/player/heart_half.png")
const HEART_EMPTY = preload("res://assets/sprites/UI/player/heart_empty.png")

var player: CharacterBody2D

func set_player(p) -> void:
	player = p
	
	if player:
		player.health_changed.connect(_update_health)
		_update_health(player.health)
	
	
func _update_health(new_health: float) -> void:
	print('yes')
	
	var hearts = hearts_container.get_children()
	var max_hearts = len(hearts)
	var full = int(new_health / HEART_SIZE)
	var half = 1 if (int(new_health) % HEART_SIZE) > 0 else 0
	var empty = max_hearts - (half + full)
	
	# Update full hearts
	for i in full:
		hearts[i].texture = HEART_FULL
	
	# Update half heart
	if half:
		hearts[full].texture = HEART_HALF
	
	for i in empty:
		hearts[len(hearts) - 1 - i].texture = HEART_EMPTY
	

func fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", to_alpha, 1.5)
	
	await tween.finished
