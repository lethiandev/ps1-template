extends Control

export(PackedScene) var next_scene: PackedScene

func _ready() -> void:
	$AnimationPlayer.play("intro")
	yield(get_tree().create_timer(8.0), "timeout")
	$AnimationPlayer.play("switch")
	yield(get_tree().create_timer(8.0), "timeout")
	_goto_next_scene()

func _goto_next_scene() -> void:
	if next_scene and next_scene.can_instance():
		get_tree().change_scene_to(next_scene)
