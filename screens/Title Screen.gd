extends Control

const GAME_SCENE = preload("res://screens/Game.tscn")

func _ready():
	$AnimationPlayer.play("Blink")

func _input(event):
	if event.is_action_pressed("mouse_left"):
		var game = GAME_SCENE.instance()
		$".".replace_by(game)

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play("Blink")
