extends Subsystem

var player : Player

func _ready():
	player = Root.getMainNode().player
func _physics_process(delta):
	if IsSafe():
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		player.verticalMov = input_dir
