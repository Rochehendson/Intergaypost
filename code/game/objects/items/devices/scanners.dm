/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/


/obj/item/device/healthanalyzer
	name = "health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	icon_state = "health_off"
	item_state = "analyzer"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	matter = list(DEFAULT_WALL_MATERIAL = 200)
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)
	var/mode = 1
	var/enabled = 0

/obj/item/device/healthanalyzer/do_surgery(mob/living/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	scan_mob(M, user) //default surgery behaviour is just to scan as usual
	return 1

/obj/item/device/healthanalyzer/update_icon()
	if(enabled)
		icon_state = "health"
	else
		icon_state = "health_off"

/obj/item/device/healthanalyzer/AltClick(var/mob/user)
	if(CanPhysicallyInteract(user))
		if(enabled)
			enabled = 0
			playsound(usr, 'sound/effects/mechanic_enable.ogg', 50, 0)
			to_chat(user, "<span class='warning'>I turn off the [name].</span>")
		else
			enabled = 1
			playsound(usr, 'sound/effects/mechanic_enable.ogg', 50, 0)
			to_chat(user, "<span class='warning'>I enable the [name].</span>")
		update_icon()

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	scan_mob(M, user)

/obj/item/device/healthanalyzer/proc/scan_mob(var/mob/living/carbon/human/H, var/mob/living/user)

	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You are not nimble enough to use this device.</span>")
		return

	if ((CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='notice'>\The [user] runs \the [src] over the floor.")
		to_chat(user, "<span class='notice'><b>Scan results for the floor:</b></span>")
		to_chat(user, "Overall Status: Floored</span>")
		return

	if (!istype(H) || H.isSynthetic())
		to_chat(user, "<span class='warning'>\The [src] is designed for organic humanoid patients only.</span>")
		return

	if(!enabled)
		to_chat(user, "<span class='warning'>How clumsy! I forgot that the [name] is not enabled.</span>")
		return

	if(user.skillcheck(user.skills[SKILL_MED], 70, null, "Medical") || user.statcheck(user.stats[STAT_IQ], 12, null, STAT_IQ))
		user.visible_message("<span class='notice'>\The [user] runs \the [src] over \the [H].</span>")
		playsound(src, 'sound/items/scanner_medical.ogg', 50)
		to_chat(user, medical_scan_results(H, mode))
	else
		to_chat(user, "<span class='warning'>You do not know how to operate this device.</span>")
		return

proc/medical_scan_results(var/mob/living/carbon/human/H, var/verbose)
	. = list()
	. += "<div class='firstdiv'><div class='box'>"
	. += "<span class='notice'><b>Scan results for \the [H]:</b></span>\n"
	. += "<hr class='linexd'>"
	// Brain activity.
	var/brain_result = "normal"
	if(H.should_have_organ(BP_BRAIN))
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if(!brain || H.stat == DEAD || (H.status_flags & FAKEDEATH))
			brain_result = "<span class='danger'>none, patient is braindead</span>"
		else if(H.stat != DEAD)
			if(H.has_brain_worms())
				brain_result = "<span class='danger'>ERROR - aberrant/unknown brainwave patterns, advanced scanner recommended</span>"
			else
				switch(brain.get_current_damage_threshold())
					if(0)
						brain_result = "<span class='notice'>normal</span>"
					if(1 to 2)
						brain_result = "<span class='notice'>minor brain damage</span>"
					if(3 to 5)
						brain_result = "<span class='warning'>weak</span>"
					if(6 to 8)
						brain_result = "<span class='danger'>extremely weak</span>"
					if(9 to INFINITY)
						brain_result = "<span class='danger'>fading</span>"
					else
						brain_result = "<span class='danger'>ERROR - Hardware fault</span>"
	else
		brain_result = "<span class='danger'>ERROR - Nonstandard biology</span>"
	. += "<span class='notice'>Brain activity:</span> [brain_result].\n"

	if(H.stat == DEAD || (H.status_flags & FAKEDEATH))
		. += "\n<span class='notice'><b>Time of Death:</b> [time2text(worldtime2stationtime(H.timeofdeath), "hh:mm")]</span>"

	if (H.internal_organs_by_name[BP_STACK])
		. += "\n<span class='notice'>Subject has a neural lace implant.</span>"

	// Pulse rate.
	var/pulse_result = "normal"
	if(H.should_have_organ(BP_HEART))
		if(H.status_flags & FAKEDEATH)
			pulse_result = 0
		else
			pulse_result = H.get_pulse(1)
	else
		pulse_result = "<span class='danger'>ERROR - Nonstandard biology</span>"

	. += "\n<span class='notice'>Pulse rate: [pulse_result]bpm.</span>"

	// Blood pressure. Based on the idea of a normal blood pressure being 120 over 80.
	if(H.get_blood_volume() <= 70)
		. += "\n<span class='danger'>Severe blood loss detected.</span>"
	. += "\n<b>Blood pressure:</b> [H.get_blood_pressure()] ([H.get_blood_oxygenation()]% blood oxygenation)"

	// Body temperature.
	//. += "\n<span class='notice'>Body temperature: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span>"

	// Radiation.
	switch(H.radiation)
		//if(-INFINITY to 0)
			//. += "\n<span class='notice'>No radiation detected.</span>"
		if(1 to 30)
			. += "\n<span class='notice'>Patient shows minor traces of radiation exposure.</span>"
		if(31 to 60)
			. += "\n<span class='notice'>Patient is suffering from mild radiation poisoning.</span>"
		if(61 to 90)
			. += "\n<span class='warning'>Patient is suffering from advanced radiation poisoning.</span>"
		if(91 to 120)
			. += "\n<span class='warning'>Patient is suffering from severe radiation poisoning.</span>"
		if(121 to 240)
			. += "\n<span class='danger'>Patient is suffering from extreme radiation poisoning. Immediate treatment recommended.</span>"
		if(241 to INFINITY)
			. += "\n<span class='danger'>Patient is suffering from acute radiation poisoning. Immediate treatment recommended.</span>"

	// Traumatic shock.
	if(H.is_asystole())
		. += "\n<span class='danger'>Patient is suffering from cardiovascular shock. Administer CPR immediately.</span>"
	else if(H.shock_stage > 80)
		. += "\n<span class='warning'>Patient is at serious risk of going into shock. Pain relief recommended.</span>"

	// Other general warnings.
	if(H.getOxyLoss() > 50)
		. += "\n<font color='blue'><b>Severe oxygen deprivation detected.</b></font>"
	if(H.getToxLoss() > 50)
		. += "\n<font color='green'><b>Major systemic organ failure detected.</b></font>"
	if(H.getFireLoss() > 50)
		. += "\n<font color='#ffa500'><b>Severe burn damage detected.</b></font>"
	if(H.getBruteLoss() > 50)
		. += "\n<font color='red'><b>Severe anatomical damage detected.</b></font>"

	for(var/name in H.organs_by_name)
		var/obj/item/organ/external/e = H.organs_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.status & ORGAN_BROKEN)
			if(((e.name == BP_L_ARM) || (e.name == BP_R_ARM) || (e.name == BP_L_LEG) || (e.name == BP_R_LEG)) && (!e.splinted))
				. += "<span class='warning'>\nUnsecured fracture in subject [limb]. Splinting recommended for transport.</span>"
		if(e.has_infected_wound())
			. += "<span class='warning'>\nInfected wound detected in subject [limb]. Disinfection recommended.</span>"

	for(var/name in H.organs_by_name)
		var/obj/item/organ/external/e = H.organs_by_name[name]
		if(e && e.status & ORGAN_BROKEN)
			. += "\n<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span>"
			break

	var/found_bleed
	var/found_tendon
	var/found_disloc
	for(var/obj/item/organ/external/e in H.organs)
		if(e)
			if(!found_disloc && e.dislocated == 2)
				. += "\n<span class='warning'>Dislocation detected. Advanced scanner required for location.</span>"
				found_disloc = TRUE
			if(!found_bleed && (e.status & ORGAN_ARTERY_CUT))
				. += "\n<span class='warning'>Arterial bleeding detected. Advanced scanner required for location.</span>"
				found_bleed = TRUE
			if(!found_tendon && (e.status & ORGAN_TENDON_CUT))
				. += "\n<span class='warning'>Tendon or ligament damage detected. Advanced scanner required for location.</span>"
				found_tendon = TRUE
		if(found_disloc && found_bleed && found_tendon)
			break

	if(verbose)

		// Limb status.
		//. += "\n<span class='notice'><b>Specific limb damage:</b></span>"

		var/list/damaged = H.get_damaged_organs(1,1)
		if(damaged.len)
			for(var/obj/item/organ/external/org in damaged)
				var/limb_result = "\n[capitalize(org.name)][(org.robotic >= ORGAN_ROBOT) ? " (Cybernetic)" : ""]:"
				if(org.brute_dam > 0)
					limb_result = "\n[limb_result] \[<font color = 'red'><b>[get_wound_severity(org.brute_ratio, org.vital)] physical trauma</b></font>\]"
				if(org.burn_dam > 0)
					limb_result = "\n[limb_result] \[<font color = '#ffa500'><b>[get_wound_severity(org.burn_ratio, org.vital)] burns</b></font>\]"
				if(org.status & ORGAN_BLEEDING)
					limb_result = "\n[limb_result] \[<span class='danger'>bleeding</span>\]"
				. += limb_result
		else
			. += "\nNo detectable limb injuries."

/*
	// Reagent data.
	. += "\n<span class='notice'><b>Reagent scan:</b></span>"

	var/print_reagent_default_message = TRUE
	if(H.reagents.total_volume)
		var/unknown = 0
		var/reagentdata[0]
		for(var/A in H.reagents.reagent_list)
			var/datum/reagent/R = A
			if(R.scannable)
				print_reagent_default_message = FALSE
				reagentdata[R.type] = "\n<span class='notice'>    [round(H.reagents.get_reagent_amount(R.type), 1)]u [R.name]</span>"
			else
				unknown++
		if(reagentdata.len)
			print_reagent_default_message = FALSE
			. += "\n<span class='notice'>Beneficial reagents detected in subject's blood:</span>"
			for(var/d in reagentdata)
				. += reagentdata[d]
		if(unknown)
			print_reagent_default_message = FALSE
			. += "\n<span class='warning'>Warning: Unknown substance[(unknown>1)?"s":""] detected in subject's blood.</span>"

	var/datum/reagents/ingested = H.get_ingested_reagents()
	if(ingested && ingested.total_volume)
		var/unknown = 0
		for(var/datum/reagent/R in ingested.reagent_list)
			if(R.scannable)
				print_reagent_default_message = FALSE
				. += "\n<span class='notice'>[R.name] found in subject's stomach.</span>"
			else
				++unknown
		if(unknown)
			print_reagent_default_message = FALSE
			. += "\n<span class='warning'>Non-medical reagent[(unknown > 1)?"s":""] found in subject's stomach.</span>"

	if(H.chem_doses.len)
		var/list/chemtraces = list()
		for(var/T in H.chem_doses)
			var/datum/reagent/R = T
			if(initial(R.scannable))
				chemtraces += "\n[initial(R.name)] ([H.chem_doses[T]])"
		if(chemtraces.len)
			. += "\n<span class='notice'>Metabolism products of [english_list(chemtraces)] found in subject's system.</span>"

	if(H.virus2.len)
		for (var/ID in H.virus2)
			if (ID in virusDB)
				print_reagent_default_message = FALSE
				var/datum/computer_file/data/virus_record/V = virusDB[ID]
				. += "\n<span class='warning'>Warning: Pathogen [V.fields["name"]] detected in subject's blood. Known antigen : [V.fields["antigen"]]</span>"

	if(print_reagent_default_message)
		. += "\nNo results."
*/

	. += "</div></div>"
	. = jointext(.,"")

// Calculates severity based on the ratios defined external limbs.
proc/get_wound_severity(var/damage_ratio, var/vital = 0)
	var/degree

	switch(damage_ratio)
		if(0 to 0.1)
			degree = "minor"
		if(0.1 to 0.25)
			degree = "moderate"
		if(0.25 to 0.5)
			degree = "significant"
		if(0.5 to 0.75)
			degree = "severe"
		if(0.75 to 1)
			degree = "extreme"
		else
			if(vital)
				degree = "critical"
			else
				degree = "irreparable"

	return degree

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	if(mode)
		to_chat(usr, "The scanner now shows specific limb damage.")
	else
		to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/device/analyzer
	name = "analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)
	var/advanced_mode = 0

/obj/item/device/analyzer/verb/verbosity(mob/user)
	set name = "Toggle Advanced Gas Analysis"
	set category = "Object"
	set src in usr

	if (!user.incapacitated())
		advanced_mode = !advanced_mode
		to_chat(user, "You toggle advanced gas analysis [advanced_mode ? "on" : "off"].")

/obj/item/device/analyzer/attack_self(mob/user)

	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return

	analyze_gases(user.loc, user,advanced_mode)
	return 1

/obj/item/device/analyzer/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	if(istype(O) && O.simulated)
		analyze_gases(O, user, advanced_mode)

/obj/item/device/mass_spectrometer
	name = "mass spectrometer"
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/New()
	..()
	create_reagents(5)

/obj/item/device/mass_spectrometer/on_reagent_change()
	update_icon()

/obj/item/device/mass_spectrometer/update_icon()
	icon_state = initial(icon_state)
	if(reagents.total_volume)
		icon_state += "_s"

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		var/list/blood_doses = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.type != /datum/reagent/blood)
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample</span>")
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				blood_doses = params2list(R.data["dose_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/T in blood_traces)
			var/datum/reagent/R = T
			if(details)
				dat += "[initial(R.name)] ([blood_traces[T]] units) "
			else
				dat += "[initial(R.name)] "
		if(details)
			dat += "\nMetabolism Products of Chemicals Found:"
			for(var/T in blood_doses)
				var/datum/reagent/R = T
				dat += "[initial(R.name)] ([blood_doses[T]] units) "
		to_chat(user, "[dat]")
		reagents.clear_reagents()
	return

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.incapacitated())
		return
	if (!user.IsAdvancedToolUser())
		return
	if(!istype(O))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				dat += "\n \t <span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")

	return

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)

/obj/item/device/price_scanner
	name = "price scanner"
	desc = "Using an up-to-date database of various costs and prices, this device estimates the market price of an item up to 0.001% accuracy."
	icon_state = "price_scanner"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 4)
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 3
	matter = list(DEFAULT_WALL_MATERIAL = 25, "glass" = 25)

/obj/item/device/price_scanner/afterattack(atom/movable/target, mob/user as mob, proximity)
	if(!proximity)
		return

	var/value = get_value(target)
	user.visible_message("\The [user] scans \the [target] with \the [src]")
	user.show_message("Price estimation of \the [target]: [value ? value : "N/A"] Thalers")

/obj/item/device/slime_scanner
	name = "xenolife scanner"
	desc = "Multipurpose organic life scanner. With spectral breath analyzer you can find out what snacks Ian had! Or what gasses alien life breathes."
	icon_state = "xenobio"
	item_state = "analyzer"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	matter = list(DEFAULT_WALL_MATERIAL = 30,"glass" = 20)

/obj/item/device/slime_scanner/proc/list_gases(var/gases)
	. = list()
	for(var/g in gases)
		. += "[gas_data.name[g]] ([gases[g]]%)"
	return english_list(.)

/obj/item/device/slime_scanner/afterattack(mob/target, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(target))
		return

	user.visible_message("\The [user] scans \the [target] with \the [src]")
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		user.show_message("<span class='notice'>Data for [H]:</span>")
		user.show_message("Species:\t[H.species]")
		user.show_message("Breathes:\t[gas_data.name[H.species.breath_type]]")
		user.show_message("Exhales:\t[gas_data.name[H.species.exhale_type]]")
		user.show_message("Known toxins:\t[gas_data.name[H.species.poison_type]]")
		user.show_message("Temperature comfort zone:\t[H.species.cold_discomfort_level] K to [H.species.heat_discomfort_level] K")
		user.show_message("Pressure comfort zone:\t[H.species.warning_low_pressure] kPa to [H.species.warning_high_pressure] kPa")
	else if(istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = target
		user.show_message("<span class='notice'>Data for [A]:</span>")
		user.show_message("Species:\t[initial(A.name)]")
		user.show_message("Breathes:\t[list_gases(A.min_gas)]")
		user.show_message("Known toxins:\t[list_gases(A.max_gas)]")
		user.show_message("Temperature comfort zone:\t[A.minbodytemp] K to [A.maxbodytemp] K")
	else if(istype(target, /mob/living/carbon/slime/))
		var/mob/living/carbon/slime/T = target
		user.show_message("<span class='notice'>Slime scan result for \the [T]:</span>")
		user.show_message("[T.colour] [T.is_adult ? "adult" : "baby"] slime")
		user.show_message("Nutrition:\t[T.nutrition]/[T.get_max_nutrition()]")
		if(T.nutrition < T.get_starve_nutrition())
			user.show_message("<span class='alert'>Warning:\tthe slime is starving!</span>")
		else if (T.nutrition < T.get_hunger_nutrition())
			user.show_message("<span class='warning'>Warning:\tthe slime is hungry.</span>")
		user.show_message("Electric charge strength:\t[T.powerlevel]")
		user.show_message("Health:\t[round(T.health / T.maxHealth)]%")

		var/list/mutations = T.GetMutations()

		if(!mutations.len)
			user.show_message("This slime will never mutate.")
		else
			var/list/mutationChances = list()
			for(var/i in mutations)
				if(i == T.colour)
					continue
				if(mutationChances[i])
					mutationChances[i] += T.mutation_chance / mutations.len
				else
					mutationChances[i] = T.mutation_chance / mutations.len

			var/list/mutationTexts = list("[T.colour] ([100 - T.mutation_chance]%)")
			for(var/i in mutationChances)
				mutationTexts += "[i] ([mutationChances[i]]%)"

			user.show_message("Possible colours on splitting:\t[english_list(mutationTexts)]")

		if (T.cores > 1)
			user.show_message("Anomalous slime core amount detected.")
		user.show_message("Growth progress:\t[T.amount_grown]/10.")
	else
		user.show_message("Incompatible life form, analysis failed.")
