/mob/living/carbon/
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/list/datum/disease2/disease/virus2 = list()
	var/list/antibodies = list()
	var/list/datum/happiness_event/events = list()


	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	//Surgery info
	var/datum/surgery_status/op_stage = new/datum/surgery_status
	//Active emote/pose
	var/pose = null
	var/list/chem_effects = list()
	var/list/chem_doses = list()
	var/datum/reagents/metabolism/bloodstr = null
	var/datum/reagents/metabolism/touching = null
	var/losebreath = 0 //if we failed to breathe last tick

	var/coughedtime = null

	var/cpr_time = 1.0
	var/lastpuke = 0
	var/nutrition = 400

	var/obj/item/weapon/tank/internal = null//Human/Monkey


	//these two help govern taste. The first is the last time a taste message was shown to the plaer.
	//the second is the message in question.
	var/last_taste_time = 0
	var/last_taste_text = ""

	//For sad, thirsty, and dirty lads.
	var/thirst = THIRST_LEVEL_FILLED
	var/hygiene = HYGIENE_LEVEL_NORMAL
	var/my_hygiene_factor = HYGIENE_FACTOR
	// organ-related variables, see organ.dm and human_organs.dm
	var/list/internal_organs = list()
	var/list/organs = list()
	var/list/organs_by_name = list() // map organ names to organs
	var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

	var/list/stasis_sources = list()
	var/stasis_value
	var/social_class = null
	var/in_bed = null
