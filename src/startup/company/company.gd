extends Node

func show() -> void:
	$AnimationPlayer.play("fade-in")

func hide() -> void:
	$AnimationPlayer.play("init")
