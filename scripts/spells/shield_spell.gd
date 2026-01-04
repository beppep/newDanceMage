extends Spell


func _ready():
	super()
	life_time = 8
	
	
func cast(caster: Unit):
	caster.shield = 1
