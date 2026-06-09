extends Area2D

@onready var collected_sound: AudioStreamPlayer2D = $CollectedSound

const HEALTH_EFFECT: float = 20.

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.heal(HEALTH_EFFECT)
		
		collected_sound.play()
		$CollisionShape2D.set_deferred("disable", true)
		$Sprite2D.set_deferred("visible", false)
		
		await collected_sound.finished

		queue_free()
