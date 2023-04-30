extends Subsystem

func OnTop():
	var backlight : Light3D = get_node("/root/Main/Root3D/BackLight")
	backlight.visible = true;
	pass

func OffTop():
	var backlight : Light3D = get_node("/root/Main/Root3D/BackLight")
	backlight.visible = false;
	pass
