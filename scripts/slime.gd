extends CharacterBody2D

@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Node2D = $HealthBar
@onready var attack_timer: Timer = $AttackTimer

const SPEED := 100
const KNOCKBACK_FORCE: int = 100
const DROP_CHANCE: float = 0.5

var target = null
var target_in_range = false
var is_alive: bool= true
var health: float = 100.
var max_health: float = health
var base_damage: float = 10.

@onready var health_pickup_scene = preload("res://scenes/health_pickup.tscn")


func _physics_process(delta: float) -> void:
	
	if is_alive and target:
		_attack(delta)

	

func _attack(delta: float) -> void:
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * SPEED * delta
	animated_sprite_2d.play("attack")
	
func take_damage(damage: float, attacker_position: Vector2)	-> void:
	health -= damage
	health_bar.update_health(health)
	
	if health <= 0.:
		_die()
	else:
		take_damage_sound.play()
		
		# Knockback
		var knockback_direction = (global_position - attacker_position).normalized()
		var target_position = global_position + knockback_direction * KNOCKBACK_FORCE
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "global_position", target_position, 0.5)
		

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("dying")
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	print(global_position, " ", global_position)
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	# Drop health pickup
	if randf() <= DROP_CHANCE:
		drop_item()
	
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = body
		print("Detected %s" % [target.name])


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:	
		target = null
		animated_sprite_2d.play("idle")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = true
		body.take_damage(base_damage)
		attack_timer.start()
		 # Replace with function body.


func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(base_damage)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		attack_timer.stop()
		target_in_range = false # Replace with function body.

func drop_item() -> void:
	var item = health_pickup_scene.instantiate()
	
	var level_root = get_parent().get_parent()
	var item_node = level_root.get_node("Items")
	
	item_node.call_deferred("add_child", item)
	item.global_position = global_position / 4.
	
	if item.global_position == global_position or item.global_position == global_position:
		print("wtf")
