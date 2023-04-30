extends Subsystem

var player : Player

var dashCooldown = 1.0
var dash = 0.0

func _ready():
	player = Root.getMainNode().player
func _process(delta):
	if IsSafe():
		if dash > 0:
			dash -= delta
		else:
			if Input.is_action_just_pressed("dash"):
				var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
				if input_dir:
					player.dashAccel = input_dir
					dash = dashCooldown
