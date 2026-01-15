extends Spell



func cast(caster: Unit):
	var _to_be_casted = caster.spell_book.duplicate()
	for i in range(len(_to_be_casted)):
		var subspell_res = caster.spell_book[i]
		if subspell_res.spell_script and subspell_res.name != "Omegapotence":
			var subspell = subspell_res.spell_script.new()  # instantiate makes a node2D?
			add_child(subspell)
			var _did_resolve = subspell.cast(caster)
			while subspell in get_children():
				await get_tree().process_frame
			if _to_be_casted[i].temporary and _did_resolve and not (caster.items.get("strange_spoon", 0) and randf()<0.5):
				caster.spell_book.erase(_to_be_casted[i])
	queue_free()
