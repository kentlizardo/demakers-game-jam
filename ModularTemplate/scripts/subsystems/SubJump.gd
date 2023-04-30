extends Subsystem

var player : Player

func _ready():
	player = Root.getMainNode().player

func OnTop():
	player.canJump = true

func OffTop():
	player.canJump = false
