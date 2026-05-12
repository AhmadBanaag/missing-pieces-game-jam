extends Area2D

func die():
	get_tree().call_deferred("reload_current_scene")


func _on_body_entered(body):
	if body.name == "player":
		die()
