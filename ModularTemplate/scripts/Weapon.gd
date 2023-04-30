extends Node3D

class_name Weapon

const fire = preload("res://res/sfx/fire.wav")
@onready
var weaponAudio : AudioStreamPlayer3D = get_parent().get_node("WeaponAudio")

@export
var Projectile : PackedScene
@export
var SecondaryProjectile : PackedScene

@export
var ClipSize : int = 1
@export
var ConsumeOnUse : int = 1
@export
var ConsumeOnSecondaryUse : int = 0
@export
var ReloadTime : float = 0.0
@export
var WaitForAnimations : bool = false
@export
var EndLag : float = 0.0

@export
var secondary : String = ""

@export
var animPlayer : AnimationPlayer

@onready
var lag = 0.0
@onready
var ammo = ClipSize

var allMeshes : Array[MeshInstance3D] = []
func _ready():
	_addMeshes(self)
	SetMeshesVisible(false)

func _addMeshes(node : Node):
	if node is MeshInstance3D:
		allMeshes.append(node)
	var children = node.get_children()
	if children.size() > 0:
		for i in children:
			_addMeshes(i)

func SetMeshesVisible(visible : bool):
	for i in allMeshes:
		i.visible = visible

func _process(delta):
	if lag > 0:
		lag -= delta

func Shoot(isSecondary : bool) -> bool:
	var an : String = "attack"
	if isSecondary:
		if secondary == "":
			return false;
		an = secondary
	if WaitForAnimations:
		if animPlayer.is_playing():
			return false;
	if lag <= 0:
		if !isSecondary:
			if ConsumeOnUse > 0:
				if ammo < ConsumeOnUse:
					lag += ReloadTime
					animPlayer.stop()
					animPlayer.play("reload")
					ammo += ClipSize
					return false;
				else:
					ammo -= ConsumeOnUse
		else:
			if ConsumeOnSecondaryUse > 0:
				if ammo < ConsumeOnSecondaryUse:
					lag += ReloadTime
					animPlayer.stop()
					animPlayer.play("reload")
					ammo += ClipSize
					return false;
				else:
					ammo -= ConsumeOnSecondaryUse
		var aim : Node3D = Root.getMainNode().player.get_node("LookPivot/Aim")
		weaponAudio.stream = fire
		weaponAudio.play()
		print_debug(self.owner)
		if isSecondary:
			if SecondaryProjectile != null:
				var obj = SecondaryProjectile.instantiate()
				owner.add_child(obj)
				obj.owner = self.owner
				obj.Launch(aim)
		else:
			if Projectile != null:
				var obj = Projectile.instantiate()
				owner.add_child(obj)
				obj.owner = self.owner
				obj.Launch(aim)
		animPlayer.stop()
		animPlayer.play(an)
		lag += EndLag
		return true
	return false
