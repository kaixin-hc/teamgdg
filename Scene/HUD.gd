extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()
	
func update_timeLeftFormatted(timeLeftFormatted):
	$TimerLabel.text = timeLeftFormatted

	


func _on_message_timer_timeout():
	$MessageLabel.hide()
