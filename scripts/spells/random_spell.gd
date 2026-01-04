extends Spell



func cast(caster: Unit):
	var subspell_res = load(caster.locked_spell_paths.pick_random())
	if subspell_res.spell_script:
		var subspell = subspell_res.spell_script.new()  # instantiate makes a node2D?
		add_child(subspell)
		subspell.cast(caster)
		while subspell in get_children():
			await get_tree().process_frame

	queue_free()
