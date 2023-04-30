extends Subsystem

const HOR_SENS = 0.003

var _player : Player
func getPlayer() -> Player:
	if _player == null:
		_player = Root.getMainNode().player
	return _player

func _input(event):
	if get_tree().paused:
		return
	if IsSafe():
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			getPlayer().rotate_y(HOR_SENS * event.relative.x * -1)
