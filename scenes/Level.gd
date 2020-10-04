extends Node2D

export var hint_text: String
export var description: String = ""
export var node_count: int
export var required_loops_completed: int = 1

var coin_count: int = 0

func _ready():
	coin_count = get_tree().get_nodes_in_group("required_pickups").size()

func _on_Level_0_tree_entered():
	SceneChanger.change_scene("res://levels/Level_1.tscn", $".", "Level 1", 0, false)
