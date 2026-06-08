extends CharacterBody2D

signal died
signal health_changed(new_health: float)

@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword_audio: AudioStreamPlayer2D = $SwingSword
@onready var take_damage_audio: AudioStreamPlayer2D = $TakeDamage
@onready var damage_cooldown: Timer = $DamageCooldown


var hitbox_offset: Vector2
const SPEED = 300.0
var last_direction : Vector2 = Vector2.RIGHT
var is_attacking : bool = false

var max_health: float = 100.
var is_alive: bool = true
var health: float
var damage : float = 10.

func _ready():
	# Initialize hitbox offset
	hitbox_offset = attack_hitbox.position
	
	# load health from singleton
	health = PlayerStats.health
	max_health = PlayerStats.max_health
	
# ----------------------------------------------------
# MOVEMENT & ANIMATION
# ----------------------------------------------------
func _physics_process(_delta: float) -> void:
	# Disable hitbox until attack is triggered
	attack_hitbox.monitoring = false
	
	if is_alive:
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()
			
		# Skip movement if attacking
		if is_attacking:
			velocity = Vector2.ZERO
			return
		
		
		process_movement()
		move_and_slide()
		process_animation()

func process_movement() -> void:
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:
	if is_attacking:
		return 
		
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
		
# -------------------------------------------------------------
# ATTACKING
# -------------------------------------------------------------

func attack() -> void:
	is_attacking = true
	attack_hitbox.monitoring = true
	swing_sword_audio.play()
	play_animation("attack", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		

# -------------------------------------------------------------
# HITBOX
# -------------------------------------------------------------

func update_hitbox_offset() -> void:
	
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			attack_hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			attack_hitbox.position = Vector2(x, y)
		Vector2.UP:
			attack_hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			attack_hitbox.position = Vector2(-y, x)


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Slime"):
		body.take_damage(damage, position)
		print("%s: [%.2f / %.2f]" % [body.name, body.health, body.max_health])
		
		
		
# --------------------------------------------------------------
# HEALTH
# --------------------------------------------------------------

func take_damage(amount: float) -> void:
	if is_alive:
		if damage_cooldown.time_left > 0:
			return 
			
		health -= amount
		PlayerStats.health = health
		emit_signal("health_changed", health)
		take_damage_audio.play()
		print("Health: [%.2f/%.2f]" % [health, max_health])
	
		if health <= 0:
			_die()
	
		# Invincibility frames
		damage_cooldown.start()

func _die() -> void:
	sprite.play("dying")
	is_alive = false
	
	await sprite.animation_finished
	died.emit()
