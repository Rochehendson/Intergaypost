/datum/virtue
	var/name = "Default Trait"
	var/description = "A default trait. If you see this someone fucked up."

/datum/virtue/chastity
	name = "chastity"

/datum/virtue/temperance
	name = "temperance"

/datum/virtue/charity
	name = "charity"

/datum/virtue/diligence
	name = "diligence"

/datum/virtue/patience
	name = "patience"

/datum/virtue/kindness
	name = "kindness"

/datum/virtue/humility
	name = "humility"

/mob/living/proc/has_virtue(var/datum/virtue/this_virtue)
	return istype(virtue, this_virtue)

/mob/living/proc/set_virtue(var/datum/virtue/set_virtue)
	virtue = set_virtue

/mob/living/proc/remove_virtue()
	virtue = null
