extends Subsystem

const VER_SENS = 0.003

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
			getPlayer().lookPivot.rotate_x(VER_SENS * event.relative.y * -1)
			var rotD = getPlayer().lookPivot.rotation_degrees
			rotD.x = clampf(rotD.x, -70, 70)
			getPlayer().lookPivot.rotation_degrees = rotD

func OnUnequip():
	getPlayer().lookPivot.rotation.x = 0.0

func OnDamage():
	getPlayer().lookPivot.rotation.x = 0.0
