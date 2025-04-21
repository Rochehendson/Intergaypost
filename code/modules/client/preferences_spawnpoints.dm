GLOBAL_VAR(spawntypes)

/proc/spawntypes()
	if(!GLOB.spawntypes)
		GLOB.spawntypes = list()
		for(var/type in typesof(/datum/spawnpoint)-/datum/spawnpoint)
			var/datum/spawnpoint/S = type
			var/display_name = initial(S.display_name)
			if((display_name in GLOB.using_map.allowed_spawns) || initial(S.always_visible))
				GLOB.spawntypes[display_name] = new S
	return GLOB.spawntypes

/datum/spawnpoint
	var/msg		  //Message to display on the arrivals computer.
	var/list/turfs   //List of turfs to spawn on.
	var/display_name //Name used in preference setup.
	var/always_visible = FALSE	// Whether this spawn point is always visible in selection, ignoring map-specific settings.
	var/list/restrict_job = null
	var/list/disallow_job = null

/datum/spawnpoint/proc/check_job_spawning(job)
	if(restrict_job && !(job in restrict_job))
		return 0

	if(disallow_job && (job in disallow_job))
		return 0

	return 1

//Called after mob is created, moved to a turf and equipped.
/datum/spawnpoint/proc/after_join(mob/victim)
	return

#ifdef UNIT_TEST
/datum/spawnpoint/Del()
	crash_with("Spawn deleted: [log_info_line(src)]")
	..()

/datum/spawnpoint/Destroy()
	crash_with("Spawn destroyed: [log_info_line(src)]")
	. = ..()
#endif

/datum/spawnpoint/arrivals
	display_name = "Arrivals Shuttle"
	msg = "has arrived on the station"

/datum/spawnpoint/arrivals/New()
	..()
	turfs = GLOB.latejoin

/datum/spawnpoint/gateway
	display_name = "Gateway"
	msg = "has completed translation from offsite gateway"

/datum/spawnpoint/gateway/New()
	..()
	turfs = GLOB.latejoin_gateway

/datum/spawnpoint/cryo
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	disallow_job = list("Robot", "Captain", "Vessel Overseer", "Maintainer", "Head Scientist", "General Researcher", "Major", "Enforcer", "Medical Officer", "Executive Officer")

/datum/spawnpoint/cryo/New()
	..()
	turfs = GLOB.latejoin_cryo

/datum/spawnpoint/cryo/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), rand(23,32) SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cryocaptain
	display_name = "Cryogenic Storage Captain"
	msg = "has completed cryogenic awakening"
	restrict_job = list("Captain")

/datum/spawnpoint/cryocaptain/New()
	..()
	turfs = GLOB.latejoin_cryocaptain

/datum/spawnpoint/cryocaptain/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	for(var/obj/machinery/cryopod/C in A)
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_captain_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), 24 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cryoengineering
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	restrict_job = list("Vessel Overseer", "Maintainer")

/datum/spawnpoint/cryoengineering/New()
	..()
	turfs = GLOB.latejoin_cryoengineering

/datum/spawnpoint/cryoengineering/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), rand(23,32) SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cryoscience
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	restrict_job = list("Head Scientist", "General Researcher")

/datum/spawnpoint/cryoscience/New()
	..()
	turfs = GLOB.latejoin_cryoscience

/datum/spawnpoint/cryoscience/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), rand(23,32) SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cryosecurity
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	restrict_job = list("Major", "Enforcer")

/datum/spawnpoint/cryosecurity/New()
	..()
	turfs = GLOB.latejoin_cryosecurity

/datum/spawnpoint/cryosecurity/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), rand(23,32) SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cryomedical
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	restrict_job = list("Medical Officer")

/datum/spawnpoint/cryomedical/New()
	..()
	turfs = GLOB.latejoin_cryomedical

/datum/spawnpoint/cryomedical/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), rand(23,32) SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cryohop
	display_name = "Cryogenic Storage"
	msg = "has completed cryogenic awakening"
	restrict_job = list("Executive Officer")

/datum/spawnpoint/cryohop/New()
	..()
	turfs = GLOB.latejoin_cryohop

/datum/spawnpoint/cryohop/after_join(mob/living/carbon/human/victim, obj/machinery/computer/cryopod/control_computer)
	if(!istype(victim))
		return
	var/area/A = get_area(victim)
	var/role_alt_title = victim.mind ? victim.mind.role_alt_title : "Unknown"
	for(var/obj/machinery/cryopod/C in A)
		if(control_computer)
			control_computer.frozen_crew += "[victim.real_name], [role_alt_title] - [stationtime2text()]"
		if(!C.occupant)
			C.set_occupant(victim, 1)
			victim.Sleeping(7)
			victim.resting = 0
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_advice), 25 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/give_cryo_effect), 30 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			victim.add_event("cryo", /datum/happiness_event/cryo)
			addtimer(CALLBACK(C, /obj/machinery/cryopod/proc/go_out_forced), 26 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			//victim.add_cryo_filter_effect()
			//addtimer(CALLBACK(victim, /mob/living/proc/remove_cryo_filter_effect), 40 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
			return
	for(var/obj/machinery/light/L in A)
		L.flicker(10)

/datum/spawnpoint/cyborg
	display_name = "Cyborg Storage"
	msg = "has been activated from storage"
	restrict_job = list("Cyborg")

/datum/spawnpoint/cyborg/New()
	..()
	turfs = GLOB.latejoin_cyborg

/datum/spawnpoint/default
	display_name = DEFAULT_SPAWNPOINT_ID
	msg = "has arrived on the station"
	always_visible = TRUE