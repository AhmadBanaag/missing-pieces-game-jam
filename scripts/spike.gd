extends Area2D

func die() -> void:
	GameSfx.play_death()
	get_tree().call_deferred("reload_current_scene")


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		die()
