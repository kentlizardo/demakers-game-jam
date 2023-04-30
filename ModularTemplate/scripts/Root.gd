extends Node

@onready
var mainWindow : Window = get_window()

var _mainNode : Main
func getMainNode() -> Main:
	if _mainNode == null:
		_mainNode = get_node("/root/Main")
	return _mainNode

func _ready():
	mainWindow.transparent_bg = true
