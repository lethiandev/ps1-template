extends Control

export(PackedScene) var next_scene: PackedScene

func _ready() -> void:
	$AnimationPlayer.play("intro")
	yield(get_tree().create_timer(9.3), "timeout")
	$AnimationPlayer.play("switch")
	yield(get_tree().create_timer(7.8), "timeout")
	_goto_next_scene()

func _goto_next_scene() -> void:
	if next_scene and next_scene.can_instance():
		get_tree().change_scene_to(next_scene)
