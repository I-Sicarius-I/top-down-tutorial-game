extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const SPEED = 300.0
var last_direction := Vector2.RIGHT


# ----------------------------------------------------
# MOVEMENT & ANIMATION
# ----------------------------------------------------
func _physics_process(_delta: float) -> void:
	process_movement()
	move_and_slide()
	process_animation()

func process_movement() -> void:
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)
		
func play_animation(prefix: String, direction: Vector2) -> void:
	
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
		sprite.play(prefix + "_right")
	elif direction.y < 0:
		sprite.play(prefix + "_up")
	elif direction.y > 0:
		sprite.play(prefix + "_down")
