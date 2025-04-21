/datum/nuisance
	var/name = "Default Sin"
	var/description = "A default sin."

/datum/nuisance/drugdealer
	name = "drug dealing"
	description = "I like dealing drugs."

/mob/living/proc/has_nuisance(var/datum/nuisance/this_nuisance)
	return istype(nuisance, this_nuisance)

/mob/living/proc/set_nuisance(var/datum/sin/set_nuisance)
	nuisance = set_nuisance

/mob/living/proc/remove_nuisance()
	nuisance = null
