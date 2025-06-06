/obj/item/organ/internal/voicebox/nabber
	robotic = ORGAN_ROBOT
	status = 0
	name = "vocal synthesiser"
	icon_state = "voicebox"
	parent_organ = BP_CHEST
	organ_tag = BP_VOICE
	will_assist_languages = list(LANGUAGE_GALCOM, LANGUAGE_LUNAR, LANGUAGE_GUTTER, LANGUAGE_SOL_COMMON, LANGUAGE_EAL, LANGUAGE_INDEPENDENT, LANGUAGE_SPACER)


/obj/item/organ/internal/voicebox/nabber/New()
	for(var/L in will_assist_languages)
		assists_languages += all_languages[L]
	robotize()


/obj/item/organ/internal/eyes/nabber
	name = "compound eyes"
	innate_flash_protection = FLASH_PROTECTION_VULNERABLE
	phoron_guard = 1
	var/eyes_shielded

/obj/item/organ/internal/eyes/nabber/additional_flash_effects(var/intensity)
	if(is_usable())
		take_internal_damage(max(0, 6 * (intensity)))
		return 1
	else
		return -1

/obj/item/organ/internal/eyes/nabber/verb/shield_eyes()
	set category = "Abilities"
	set name = "Toggle Eyeshields"
	set src in usr

	eyes_shielded = !eyes_shielded

	if(eyes_shielded)
		to_chat(owner, "<span class='notice'>Nearly opaque lenses slide down to shield your eyes.</span>")
		innate_flash_protection = FLASH_PROTECTION_MAJOR
		owner.eye_blind = 20
		owner.update_icons()
	else
		to_chat(owner, "<span class='notice'>Your protective lenses retract out of the way.</span>")
		innate_flash_protection = FLASH_PROTECTION_VULNERABLE
		owner.eye_blind = min(2, owner.eye_blind)
		Process()
		owner.update_icons()

/obj/item/organ/internal/eyes/nabber/Process()
	if(eyes_shielded)
		owner.eye_blind = 20
	..()

/obj/item/organ/internal/phoron
	name = "phoron storage"
	icon_state = "stomach"
	organ_tag = BP_PHORON
	parent_organ = BP_CHEST
	var/dexalin_level = 10
	var/phoron_level = 0.5

/obj/item/organ/internal/phoron/Process()
	if(owner)
		var amount = 0.1
		if(is_broken())
			amount *= 0.5
		else if(is_bruised())
			amount *= 0.1

		var/dexalin_volume_raw = owner.reagents.get_reagent_amount(/datum/reagent/dexalin)
		var/phoron_volume_raw = owner.reagents.get_reagent_amount(/datum/reagent/toxin/phoron)

		if((dexalin_volume_raw < dexalin_level || !dexalin_volume_raw) && (phoron_volume_raw < phoron_level || !phoron_volume_raw))
			owner.reagents.add_reagent(/datum/reagent/toxin/phoron, amount)
	..()

/obj/item/organ/internal/liver/nabber
	name = "acetone reactor"
	var/acetone_level = 20


/obj/item/organ/internal/liver/nabber/Process()
	if(owner)
		var amount = 0.8
		if(is_broken())
			amount *= 0.5
		else if(is_bruised())
			amount *= 0.1

		var/acetone_volume_raw = owner.reagents.get_reagent_amount(/datum/reagent/acetone)
		var/breath_fail_ratio = 1
		var/obj/item/organ/internal/lungs/nabber/totally_not_lungs_I_swear = owner.internal_organs_by_name[BP_TRACH]
		if(totally_not_lungs_I_swear)
			breath_fail_ratio = totally_not_lungs_I_swear.breath_fail_ratio
		if((acetone_volume_raw < acetone_level || !acetone_volume_raw) && breath_fail_ratio < 0.25)
			owner.reagents.add_reagent(/datum/reagent/acetone, amount)
	..()

// These are not actually lungs and shouldn't be thought of as such despite the claims of the parent.
/obj/item/organ/internal/lungs/nabber
	name = "tracheae"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = BP_TRACH
	parent_organ = BP_GROIN

	active_breathing = 0

	min_breath_pressure = 30

	safe_toxins_max = 10

/obj/item/organ/internal/lungs/nabber/handle_failed_breath()
	var/mob/living/carbon/human/H = owner

	H.adjustOxyLoss(-(HUMAN_MAX_OXYLOSS * owner.chem_effects[CE_OXYGENATED]))

	if(breath_fail_ratio < 0.25 && owner.chem_effects[CE_OXYGENATED])
		H.oxygen_alert = 0
	if(breath_fail_ratio >= 0.25 && (damage || world.time > last_failed_breath + 2 MINUTES))
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS * breath_fail_ratio)
		if(owner.chem_effects[CE_OXYGENATED])
			H.oxygen_alert = 1
		else
			H.oxygen_alert = 2


/obj/item/organ/internal/heart/nabber
	open = 1

/obj/item/organ/internal/brain/nabber
	var/lowblood_tally = 0
	var/lowblood_mult = 2
	name = "distributed nervous system"
	parent_organ = BP_CHEST


/obj/item/organ/internal/brain/nabber/Process()
	if(!owner || !owner.should_have_organ(BP_HEART))
		return

	// No heart? You are going to have a very bad time. Not 100% lethal because heart transplants should be a thing.
	var/blood_volume = owner.get_blood_circulation()
	if(!owner.internal_organs_by_name[BP_HEART])
		if(blood_volume > BLOOD_VOLUME_SURVIVE)
			blood_volume = BLOOD_VOLUME_SURVIVE
		owner.Paralyse(3)

	//Effects of bloodloss
	switch(blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			lowblood_tally = 1 * lowblood_mult
			if(prob(1))
				to_chat(owner, "<span class='warning'>You're finding it difficult to move.</span>")
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			lowblood_tally = 3 * lowblood_mult
			if(prob(1))
				to_chat(owner, "<span class='warning'>Moving has become very difficult.</span>")
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			lowblood_tally = 5 * lowblood_mult
			if(prob(15))
				to_chat(owner, "<span class='warning'>You're almost unable to move!</span>")
		if(-(INFINITY) to BLOOD_VOLUME_SURVIVE)
			lowblood_tally = 6 * lowblood_mult
			if(prob(10))
				to_chat(owner, "<span class='warning'>Your body is barely functioning and is starting to shut down.</span>")
				owner.Paralyse(1)
			for(var/obj/item/organ/internal/I in owner.internal_organs)
				if(prob(5))
					I.take_internal_damage(5)
	..()

/obj/item/organ/external/chest/nabber
	name = "thorax"

/obj/item/organ/external/groin/nabber
	name = "abdomen"
	icon_position = UNDER

/obj/item/organ/external/arm/nabber
	name = "left arm"
	amputation_point = "coxa"
	icon_position = LEFT

/obj/item/organ/external/arm/right/nabber
	name = "right arm"
	amputation_point = "coxa"
	icon_position = RIGHT

/obj/item/organ/external/leg/nabber
	name = "left tail side"
	icon_position = LEFT

/obj/item/organ/external/leg/right/nabber
	name = "right tail side"

/obj/item/organ/external/foot/nabber
	name = "left tail tip"
	icon_position = LEFT

/obj/item/organ/external/foot/right/nabber
	name = "right tail tip"
	icon_position = RIGHT

/obj/item/organ/external/hand/nabber
	name = "left grasper"
	icon_position = LEFT

/obj/item/organ/external/hand/right/nabber
	name = "right grasper"
	icon_position = RIGHT

/obj/item/organ/external/head/nabber
	name = "head"
	vital = 0
	has_lips = 0
