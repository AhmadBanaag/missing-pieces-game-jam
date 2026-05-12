extends Area2D

func die():
	get_tree().reload_current_scene()


func _on_body_entered(body):
		die()
