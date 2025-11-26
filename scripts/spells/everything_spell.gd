extends Spell



func cast(caster: Unit):
	for i in range(len(caster.spell_book)):
		var subspell_res = caster.spell_book[i]
		if subspell_res.spell_script and subspell_res.name != "Omegapotence":
			var subspell = subspell_res.spell_script.new()  # instantiate makes a node2D?
			add_child(subspell)
			subspell.cast(caster)
			while subspell in get_children():
				await get_tree().process_frame
	
	queue_free()
