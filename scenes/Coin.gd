extends Area2D

func _on_Coin_body_entered(body: Node):
	if body.is_in_group("vehicle"):
		$Particles2D.set_deferred("emitting", true)
		$Sprite.hide()
		set_deferred("monitoring", false)
		$PickupSound.play()
