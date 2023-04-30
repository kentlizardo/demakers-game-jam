extends Subsystem

@export
var weapon_prefabs : Array[PackedScene]

var weapons : Array[Weapon] = []

func _ready():
	for i in weapon_prefabs:
		weapons.append(instantiateWeapon(i))

func instantiateWeapon(prefab : PackedScene) -> Weapon:
	var newWeapon : Weapon = prefab.instantiate()
	var weaponPivot = Root.getMainNode().player.weaponPivot
	weaponPivot.add_child.call_deferred(newWeapon)
	newWeapon.set_owner.call_deferred(self.owner)
	return newWeapon

func OnTop():
	Root.getMainNode().player.equipWeaponStockPile(self, weapons)

func OffTop():
	Root.getMainNode().player.unequipWeaponStockPile(self)
