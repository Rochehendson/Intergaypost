/obj/item/organ/internal/guts
	name = "guts"
	icon_state = "intestines"
	parent_organ = BP_GROIN
	organ_tag = BP_GUTS
	gender = PLURAL
	w_class = ITEM_SIZE_NORMAL
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	var/list/stomach_contents = list()

/obj/item/organ/internal/guts/Process()
	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			spawn owner.emote("me", 1, "coughs up blood!")
			owner.drip(10)
			if(prob(35))
				owner.emote("vomit")
			if(prob(10))
				owner.handle_shit()

	if(is_broken())
		if(prob(10))
			spawn owner.emote("me", 1, "coughs up blood!")
			owner.drip(10)
			if(prob(35))
				owner.emote("vomit")
			if(prob(10))
				owner.handle_shit()