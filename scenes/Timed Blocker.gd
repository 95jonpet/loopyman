extends Area2D

const ACTIVE_SPRITE = preload("res://sprites/timed_blocker_active.png")
const INACTIVE_SPRITE = preload("res://sprites/timed_blocker_inactive.png")

export var active: bool = false

signal entity_killed(entity)

func _ready():
	update_instance()

func _on_Timed_Blocker_body_entered(body: PhysicsBody2D):
	if body.is_in_group("vehicle"):
		emit_signal("entity_killed", body)

func _on_Timer_timeout():
	active = !active
	$TriggerSound.play()
	update_instance()

func start_timer():
	$Timer.start()

func stop_timer():
	$Timer.stop()

func update_instance():
	$Sprite.texture = ACTIVE_SPRITE if active else INACTIVE_SPRITE
	set_deferred("monitoring", active)
