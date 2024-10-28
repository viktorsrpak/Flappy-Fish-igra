extends Area2D

signal hit
signal scored

func _on_body_entered(_body):  # Prefiksirano s "_"
	hit.emit()

func _on_score_area_body_entered(_body):  # Prefiksirano s "_"
	scored.emit()
