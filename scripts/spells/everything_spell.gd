extends Spell



func cast(caster: Unit):
	var _to_be_casted = caster.spell_book.duplicate()
	for i in range(len(_to_be_casted)):
		var subspell_res = caster.spell_book[i]
		if subspell_res.spell_script and subspell_res.name != "Omegapotence":
			var subspell = subspell_res.spell_script.new()  # instantiate makes a node2D?
			add_child(subspell)
			subspell.cast(caster)
			while subspell in get_children():
				await get_tree().process_frame
	
		#if _to_be_casted[i].temporary:
		#	caster.spell_book.erase(_to_be_casted[i]) # should everything spell use up temp spells or let you cast them infinitely?
	queue_free()
