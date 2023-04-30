extends Node2D

class_name Subsystem

var equipped : bool = false
var damaged : bool = false

var topLevelValue : bool = false
var oldTopValue : bool = false

func GetModule() -> Module:
	var n : Node = self
	while !(n is Module) and not n == null:
		n = n.get_parent()
	return n

func _process(delta):
	topLevelValue = IsTopLevel()
	if topLevelValue != oldTopValue:
		if topLevelValue:
			if self.has_method("OnTop"):
				self.call("OnTop")
		else:
			if self.has_method("OffTop"):
				self.call("OffTop")
	oldTopValue = topLevelValue

func IsSafe() -> bool:
	return equipped and !damaged

func IsTopLevel() -> bool:
	if !IsSafe():
		return false
	if !(self.get_parent() is Subsystem):
		return true
	else:
		var parentSubsystem : Subsystem = get_parent()
		return parentSubsystem.damaged

func EquipSubsystem():
	equipped = true
	if self.has_method("OnEquip"):
		self.call("OnEquip")
	onEquip.emit()
signal onEquip

func UnequipSubsystem():
	equipped = false
	if self.has_method("OnUnequip"):
		self.call("OnUnequip")
	onUnequip.emit()
signal onUnequip

func DamageSubsystem():
	damaged = true
	if self.has_method("OnDamage"):
		self.call("OnDamage")
	onDamaged.emit()
signal onDamaged

func HealSubsystem():
	damaged = false
	if self.has_method("OnHeal"):
		self.call("OnHeal")
	onHeal.emit()
signal onHeal

