extends Node2D

export var grid_size: int = 16
export var line_color: Color = "#4A5568"
const MOVEMENT_NODE = preload("res://scenes/Movement Node.tscn")
const VEHICLE = preload("res://scenes/Vehicle.tscn")

var loops_completed: int = 0
var level_number: int = 1;
var final_level_number: int = 10;
var vehicle = null
onready var level: Node = $Level

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left") && can_place_movement_node():
			var spawn_position = grid_snap(event.position * 0.25)
			
			var space_state = get_world_2d().direct_space_state
			var first_movement_node = $"Movement Nodes".get_child(0) if $"Movement Nodes".get_child_count() > 0 else null
			var last_movement_node = $"Movement Nodes".get_child($"Movement Nodes".get_child_count() - 1) if $"Movement Nodes".get_child_count() > 0 else null
			var raycast_exclusions = [last_movement_node] if last_movement_node else []
			var raycast_from_previous = space_state.intersect_ray(last_movement_node.global_position if last_movement_node else spawn_position, spawn_position, raycast_exclusions)
			var raycast_to_first = space_state.intersect_ray(spawn_position, first_movement_node.global_position if first_movement_node else spawn_position, [first_movement_node])
			if !space_state.intersect_point(spawn_position) && !raycast_from_previous && ($"Movement Nodes".get_child_count() != level.node_count - 1 || !raycast_to_first) && (!first_movement_node || first_movement_node.global_position != spawn_position):
				var movement_node = MOVEMENT_NODE.instance()
				$NodePlacedSound.play()
				movement_node.position = spawn_position
				$"Movement Nodes".add_child(movement_node)
				
				if $"Movement Nodes".get_child_count() == level.node_count:
					for timedEnitity in get_tree().get_nodes_in_group("timed_entities"):
						timedEnitity.start_timer()
					spawn_vehicle()
			else:
				$ActionDeniedSound.play()
	elif event.is_action_pressed("restart"):
		restart_level()
	elif event.is_action_pressed("skip_level"):
		go_to_next_level()

func _process(_delta):
	$"Loop Count Label".text = str("Level ", level_number, ": ", level.hint_text)
	$"Loop Count Label".hide()
	$"Description Label".text = level.description
	$"Description Label".hide()
	$Control/Loops.text = str(loops_completed, "/", level.required_loops_completed)
	$Control/Nodes.text = str($"Movement Nodes".get_child_count(), "/", level.node_count)
	
	if level.coin_count:
		$Control/Coins.text = str(level.coin_count - get_tree().get_nodes_in_group("required_pickups").size(), "/", level.coin_count)
		$Control/CoinsSymbol.show()
	else:
		$Control/Coins.text = ""
		$Control/CoinsSymbol.hide()
	
	update()

func _ready():
	assert(SceneChanger.connect("scene_replaced", self, "set_level") == OK)
	assert(SceneChanger.connect("scene_unloaded", self, "scene_unloaded") == OK)

func _draw():
	if can_place_movement_node():
		draw_grid_around_mouse()
	
	draw_movement_node_connections()

func _on_entity_killed(entity: Node):
	if entity == vehicle:
		game_over()

func _on_Vehicle_loop_completed():
	loops_completed += 1
	if loops_completed >= level.required_loops_completed && get_tree().get_nodes_in_group("required_pickups").size() == 0:
		go_to_next_level()

func can_place_movement_node():
	return $"Movement Nodes".get_child_count() < level.node_count

func game_over():
	$GameOverSound.play()
	if vehicle:
		vehicle.stop()
	for timedEnitity in get_tree().get_nodes_in_group("timed_entities"):
		timedEnitity.stop_timer()
	restart_level()

func go_to_next_level():
	if vehicle:
		vehicle.queue_free()
	
	level_number = (level_number + 1) if level_number < final_level_number else 1
	var next_level = str("res://levels/Level_", level_number, ".tscn")
	$LevelCompletedSound.play()
	SceneChanger.change_scene(next_level, level, str("Level ", level_number))

func grid_snap(position: Vector2) -> Vector2:
	return Vector2(round(position.x / grid_size) * grid_size, round(position.y / grid_size) * grid_size)

func draw_grid_around_mouse():
	var center = grid_snap(get_viewport().get_mouse_position() * 0.25)
	var x_offset = Vector2(grid_size, 0)
	var y_offset = Vector2(0, grid_size)
	
	# Draw center cross.
	draw_line(center - x_offset * 0.5, center + x_offset * 0.5, "#718096")
	draw_line(center - y_offset * 0.5, center + y_offset * 0.5, "#718096")
	
	# Draw extended center cross.
	draw_line(center + x_offset * 0.5, center + x_offset * 1.5, "#4A5568")
	draw_line(center - x_offset * 0.5, center - x_offset * 1.5, "#4A5568")
	draw_line(center + y_offset * 0.5, center + y_offset * 1.5, "#4A5568")
	draw_line(center - y_offset * 0.5, center - y_offset * 1.5, "#4A5568")
	
	# Draw outer edges.
	draw_line(center - x_offset - y_offset * 1.5, center - x_offset + y_offset * 1.5, "#4A5568")
	draw_line(center + x_offset - y_offset * 1.5, center + x_offset + y_offset * 1.5, "#4A5568")
	draw_line(center - x_offset * 1.5 - y_offset, center + x_offset * 1.5 - y_offset, "#4A5568")
	draw_line(center - x_offset * 1.5 + y_offset, center + x_offset * 1.5 + y_offset, "#4A5568")

func draw_movement_node_connections():
	if $"Movement Nodes".get_child_count() > 1:
		var children = $"Movement Nodes".get_children()
		var previous = children[len(children) - 1] if !can_place_movement_node() else children[0]
		for child in children:
			draw_line(previous.position, child.position, line_color, 2)
			previous = child

func set_level(new_level):
	level = new_level
	$Control/LevelName.text = str("Level ", level_number)
	for killingEntity in get_tree().get_nodes_in_group("killing_entities"):
		killingEntity.connect("entity_killed", self, "_on_entity_killed")

func reset_level():
	loops_completed = 0
	if vehicle:
		vehicle.queue_free()
	for child in $"Movement Nodes".get_children():
		child.queue_free()

func restart_level():
	var level_path = str("res://levels/Level_", level_number, ".tscn")
	SceneChanger.change_scene(level_path, level)

func scene_unloaded():
	reset_level()

func spawn_vehicle():
	vehicle = VEHICLE.instance()
	add_child(vehicle)
	vehicle.connect("loop_completed", self, "_on_Vehicle_loop_completed")
	vehicle.connect("node_reached", $NodePassedSound, "play")
	vehicle.connect("loop_completed", $LoopCompletedSound, "play")
	vehicle.start_moving_toward_next_node()
	vehicle.show()
