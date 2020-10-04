extends KinematicBody2D

signal loop_completed()
signal node_reached(node)
signal killed()

export var speed = 32
onready var movement_nodes = $"../Movement Nodes"
var last_node_index: int = 0

func _on_Tween_tween_completed(_object, _key):
	if last_node_index == 0:
		emit_signal("loop_completed")
	else:
		emit_signal("node_reached")
	
	start_moving_toward_next_node()

func start_moving_toward_next_node():
	var next_node_index = last_node_index + 1 if last_node_index < movement_nodes.get_child_count() - 1 else 0
	var last_node = movement_nodes.get_child(last_node_index)
	var next_node = movement_nodes.get_child(next_node_index)
	last_node_index = next_node_index
	
	var duration = last_node.position.distance_to(next_node.position) / speed
	
	# Change direction to face next node.
	$Sprite.rotation = next_node.position.angle_to_point(last_node.position)
	
	# Start moving toward next node..
	$Tween.interpolate_property(self, "position", last_node.position, next_node.position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func kill():
	stop()
	emit_signal("killed")

func stop():
	$Tween.stop_all()
