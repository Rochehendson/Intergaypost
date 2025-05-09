
/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_LIVER
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 60

/obj/item/organ/internal/liver/robotize()
	. = ..()
	icon_state = "liver-prosthetic"

/obj/item/organ/internal/liver/Process()

	..()
	if(!owner)
		return

	handle_thirst()

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='danger'>Your skin itches.</span>")
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	//Detox can heal small amounts of damage
	if (damage < max_damage && !owner.chem_effects[CE_TOXIN])
		heal_damage(0.2 * owner.chem_effects[CE_ANTITOX])

	// Get the effectiveness of the liver.
	var/filter_effect = 3
	if(is_bruised())
		filter_effect -= 1
	if(is_broken())
		filter_effect -= 2
	// Robotic organs filter better but don't get benefits from dylovene for filtering.
	if(robotic >= ORGAN_ROBOT)
		filter_effect += 1
	else if(owner.chem_effects[CE_ANTITOX])
		filter_effect += 1
	// If you're not filtering well, you're going to take damage. Even more if you have alcohol in you.
	if(filter_effect < 2)
		owner.adjustToxLoss(0.5 * max(2 - filter_effect, 0) * (1 + owner.chem_effects[CE_ALCOHOL_TOXIC] + 0.5 * owner.chem_effects[CE_ALCOHOL]))

	if(owner.chem_effects[CE_ALCOHOL_TOXIC])
		take_internal_damage(owner.chem_effects[CE_ALCOHOL_TOXIC], prob(90)) // Chance to warn them

	// Heal a bit if needed and we're not busy. This allows recovery from low amounts of toxloss.
	if(!owner.chem_effects[CE_ALCOHOL] && !owner.chem_effects[CE_TOXIN] && !owner.radiation && damage > 0)
		if(damage < min_broken_damage)
			heal_damage(0.2)
		if(damage < min_bruised_damage)
			heal_damage(0.3)

	//Blood regeneration if there is some space
	owner.regenerate_blood(0.1 + owner.chem_effects[CE_BLOODRESTORE])

	// Blood loss or liver damage make you lose nutriments
	var/blood_volume = owner.get_blood_volume()
	if(blood_volume < BLOOD_VOLUME_SAFE || is_bruised())
		if(owner.nutrition >= 300)
			owner.adjust_nutrition(-30)
		else if(owner.nutrition >= 200)
			owner.adjust_nutrition(-20)

/obj/item/organ/internal/liver/proc/handle_thirst()
	owner.adjust_thirst(-THIRST_FACTOR)
	switch(owner.thirst)
		if(THIRST_LEVEL_FILLED to THIRST_LEVEL_MAX)
			owner.add_event("thirst", /datum/happiness_event/thirst/filled)
		if(THIRST_LEVEL_MEDIUM to THIRST_LEVEL_FILLED)
			owner.add_event("thirst", /datum/happiness_event/thirst/watered)
		if(THIRST_LEVEL_THIRSTY to THIRST_LEVEL_MEDIUM)
			owner.clear_event("thirst")
		if(THIRST_LEVEL_DEHYDRATED to THIRST_LEVEL_THIRSTY)
			owner.add_event("thirst", /datum/happiness_event/thirst/thirsty)
			if(prob(1))
				to_chat(owner, "<span class='warning'>You could really use a drink!</span>")
			else if(prob(1))
				to_chat(owner, "<span class='warning'>Your mouth feels really dry...</span>")
		if(0 to THIRST_LEVEL_DEHYDRATED)
			owner.add_event("thirst", /datum/happiness_event/thirst/dehydrated)
			if(prob(2))
				to_chat(owner, "<span class='danger'><font size = 3>You faint from dehydration.</span></font>")
				owner.Paralyse(3)
			else if(prob(3))
				to_chat(owner, "<span class='danger'><font size = 3>You fall down because of your thirst.</span></font>")
				owner.Weaken(1)
				owner.Stun(1)
			if(prob(2))
				to_chat(owner, "<span class='danger'><font size = 3>You lick around your mouth as a craving for water sets in.</span></font>")
				take_internal_damage(1)