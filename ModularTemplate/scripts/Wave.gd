extends Node3D

var enemies : Array[Node3D] = []

func _ready():
	for i in get_children():
		if i is Enemy:
			enemies.append(i)
			i.onDeath.connect(checkEnemies)

signal completeWave

func checkEnemies():
	var complete = true
	for i in enemies:
		if i != null:
			if !i.dead:
				complete = false
	if complete:
		completeWave.emit()
