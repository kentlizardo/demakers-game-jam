extends Node3D

class_name Level

@export
var spawnPoint : Node3D
@export
var nextLevel : Level

signal LevelComplete

func Complete():
	LevelComplete.emit()
