extends CanvasLayer

signal scene_changed(new_scene)
signal scene_replaced(new_scene)
signal scene_unloaded()

onready var animation_player = $AnimationPlayer
onready var black = $Control/Black

var changing_scene: bool = false

func change_scene(path: String, old_level: Node, label: String = "", delay: float = 0.5, fade_out: bool = true):
	if changing_scene:
		return
	
	changing_scene = true
	$Control/Label.text = label
	if delay:
		yield(get_tree().create_timer(delay), "timeout")
	if fade_out:
		animation_player.play("Fade")
		yield(animation_player, "animation_finished")
	else:
		animation_player.play("Fade")
		animation_player.seek(animation_player.get_animation("Fade").length)
	emit_signal("scene_unloaded")
	
	var new_level = load(path).instance()
	var parent = old_level.get_parent()
	var pos_in_parent = old_level.get_position_in_parent()
	parent.call_deferred("remove_child", old_level)
	yield(old_level, "tree_exited")
	parent.call_deferred("add_child", new_level)
	yield(new_level, "tree_entered")
	parent.move_child(new_level, pos_in_parent)
	emit_signal("scene_replaced", new_level)
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	animation_player.play_backwards("Fade")
	yield(animation_player, "animation_finished")
	changing_scene = false
	emit_signal("scene_changed", new_level)
