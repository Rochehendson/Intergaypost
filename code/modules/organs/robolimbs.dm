var/list/all_robolimbs = list()
var/list/chargen_robolimbs = list()
var/datum/robolimb/basic_robolimb

/proc/populate_robolimb_list()
	basic_robolimb = new()
	for(var/limb_type in typesof(/datum/robolimb))
		var/datum/robolimb/R = new limb_type()
		all_robolimbs[R.company] = R
		if(!R.unavailable_at_chargen)
			chargen_robolimbs[R.company] = R

/datum/robolimb
	var/company = "Metal"                            // Shown when selecting the limb.
	var/desc = "A generic unbranded robotic prosthesis." // Seen when examining a limb.
	var/icon = 'icons/mob/human_races/robotic.dmi'       // Icon base to draw from.
	var/unavailable_at_chargen                           // If set, not available at chargen.
	var/unavailable_at_fab                               // If set, cannot be fabricated.
	var/can_eat
	var/use_eye_icon = "eyes_s"
	var/can_feel_pain
	var/skintone
	var/list/species_cannot_use = list()
	var/list/restricted_to = list()
	var/list/applies_to_part = list() //TODO.

/datum/robolimb/morpheus
	company = "Titanium"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	unavailable_at_fab = 1

/datum/robolimb/veymed
	company = "Synthetic"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	can_eat = 1
	skintone = 1
	unavailable_at_fab = 1
	restricted_to = list(SPECIES_HUMAN)
