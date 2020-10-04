extends Control

const GAME_SCENE = preload("res://screens/Game.tscn")

func _ready():
	$AnimationPlayer.play("Blink")

func _input(event):
	if event.is_action_pressed("mouse_left"):
		var game = GAME_SCENE.instance()
		
		var parent = get_parent()
		var pos_in_parent = get_position_in_parent()
		parent.remove_child(self)
		parent.add_child(game)
		parent.move_child(game, pos_in_parent)
		
		#$".".replace_by(game)

func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.play("Blink")
