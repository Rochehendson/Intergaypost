/mob/living/carbon/human/examine(mob/user)
	if(!isobserver(user))
		user.visible_message("<span class='looksatbold'>[usr]</span> <span class='looksat'>looks at [src].</span>")

		if(get_dist(user,src) > 5)//Don't get descriptions of things far away.
			to_chat(user, "<span class='info'>It's too far away to see clearly.</span>")
			return

	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE

	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDEFACE

	//no accuately spotting headsets from across the room.
	if(get_dist(user, src) > 3)
		skipears = 1

	var/list/msg = list("<div class='firstdivexamineplyr'><div class='boxexamineplyr'><span class='statustext'><span class='info'>It's nice seeing ")

	var/datum/gender/T = gender_datums[get_gender()]
	if(skipjumpsuit && skipface) //big suits/masks/helmets make it hard to tell their gender
		T = gender_datums[PLURAL]

	if(!T)
		// Just in case someone VVs the gender to something strange. It'll runtime anyway when it hits usages, better to CRASH() now with a helpful message.
		CRASH("Gender datum was null; key was '[(skipjumpsuit && skipface) ? PLURAL : gender]'")

	msg += "<span class='uppertext'>[src.name].</span>\n"

	var/is_synth = isSynthetic()
	if(!(skipjumpsuit && skipface))
		var/species_name = "\improper "
		if(is_synth)
			species_name += "Cyborg "
		species_name += "[species.name]"
//		msg += ", <b><font color='[species.get_flesh_colour(src)]'> \a [species_name]!</font></b>"
	var/extra_species_text = species.get_additional_examine_text(src)
	if(extra_species_text)
		msg += "[extra_species_text]<br>"

	msg += "<br>"


	if((!skipface || wear_id || wear_amulet) && src != user)
		var/mob/living/carbon/human/H = user
		var/classdesc = get_social_description(H)
		if(src?.mind?.assigned_role)
			msg += "[T.He]'s known by everyone as the <b>[src.mind.assigned_role]</b>.\n"
		msg += "[T.He] [T.is] [get_social_class()]. [classdesc]\n\n"

	msg += "<hr class='linexd'>"

	//uniform
	if(w_uniform && !skipjumpsuit)
		msg += "[T.He] [T.is] wearing [w_uniform.get_examine_line(user)].\n"

	//head
	if(head)
		msg += "[T.He] [T.is] wearing [head.get_examine_line(user)] on [T.his] head.\n"

	//suit/armour
	if(wear_suit)
		msg += "[T.He] [T.is] wearing [wear_suit.get_examine_line(user)].\n"
		//suit/armour storage
		if(s_store && !skipsuitstorage)
			msg += "[T.He] [T.is] carrying [s_store.get_examine_line(user)] on [T.his] [wear_suit.name].\n"

	//back
	if(back)
		msg += "[T.He] [T.has] [back.get_examine_line(user)] on [T.his] back.\n"

	//left hand
	if(l_hand)
		msg += "[T.He] [T.is] holding [l_hand.get_examine_line(user)] in [T.his] left hand.\n"

	//right hand
	if(r_hand)
		msg += "[T.He] [T.is] holding [r_hand.get_examine_line(user)] in [T.his] right hand.\n"

	//gloves
	if(gloves && !skipgloves)
		msg += "[T.He] [T.has] [gloves.get_examine_line(user)] on [T.his] hands.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[T.He] [T.has] [(hand_blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained hands!</span>\n"

	//belt
	if(belt)
		msg += "[T.He] [T.has] [belt.get_examine_line(user)] about [T.his] waist.\n"

	//shoes
	if(shoes && !skipshoes)
		msg += "[T.He] [T.is] wearing [shoes.get_examine_line(user)] on [T.his] feet.\n"
	else if(feet_blood_DNA)
		msg += "<span class='warning'>[T.He] [T.has] [(feet_blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained feet!</span>\n"

	//mask
	if(wear_mask && !skipmask)
		msg += "[T.He] [T.has] [wear_mask.get_examine_line(user)] on [T.his] face.\n"

	//eyes
	if(glasses && !skipeyes)
		msg += "[T.He] [T.has] [glasses.get_examine_line(user)] covering [T.his] eyes.\n"

	//left ear
	if(l_ear && !skipears)
		msg += "[T.He] [T.has] [l_ear.get_examine_line(user)] on [T.his] left ear.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[T.He] [T.has] [r_ear.get_examine_line(user)] on [T.his] right ear.\n"

	//ID
	if(wear_id)
		msg += "[T.He] [T.is] wearing [wear_id.get_examine_line(user)].\n"

	if(wear_amulet)
		msg += "[T.He] [T.is] wearing [wear_amulet.get_examine_line(user)] on his neck.\n"

	msg += "<hr class='linexd'>"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[T.He] [T.is] \icon[handcuffed] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[T.He] [T.is] \icon[handcuffed] handcuffed!</span>\n"

	//buckled
	if(buckled)
		msg += "<span class='warning'>[T.He] [T.is] \icon[buckled] buckled to [buckled]!</span>\n"
	if(stats[STAT_ST] > user.stats[STAT_ST] && stats[STAT_ST] < (user.stats[STAT_ST] + 5))
		msg += "[T.He] looks stronger than you.\n"

	if(stats[STAT_ST] > (user.stats[STAT_ST]+ 5))
		msg += "<b>[T.He] looks a lot stronger than you.</b>\n"

	if(stats[STAT_ST] < user.stats[STAT_ST])
		msg += "[T.He] looks weaker than you.\n"

	//Jitters
	if(is_jittery)
		if(jitteriness >= 300)
			msg += "<span class='warning'><B>[T.He] [T.is] convulsing violently!</B></span>\n"
		else if(jitteriness >= 200)
			msg += "<span class='warning'>[T.He] [T.is] extremely jittery.</span>\n"
		else if(jitteriness >= 100)
			msg += "<span class='warning'>[T.He] [T.is] twitching ever so slightly.</span>\n"

	//Disfigured face
	if(!skipface) //Disfigurement only matters for the head currently.
		var/obj/item/organ/external/head/E = get_organ(BP_HEAD)
		if(E && E.disfigured) //Check to see if we even have a head and if the head's disfigured.
			if(E.species) //Check to make sure we have a species
				msg += E.species.disfigure_msg(src)
			else //Just in case they lack a species for whatever reason.
				msg += "<span class='warning'>[T.His] face is horribly mangled!</span>\n"
		if(branded)//For brands.
			msg += "<span class='warning'><b>\"[branded]\" IS BRANDED ON THEIR FACE!</b></span>"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.religion == LEGAL_RELIGION && H != src && branded == "HERETIC")
					msg += "<span class='notice'> Viewing such a spectacle fills you with pleasure.</span>"
					H.add_event("punishedheretic", /datum/happiness_event/punished_heretic)
				else
					msg += "<span class='notice'> It is a horrid reminder of what could happen to you.</span>"
				if(H != src)
					src.add_event("lookedupon", /datum/happiness_event/humiliated)
			msg += "\n"
		if(tongueless)
			msg += "<span class='danger'>[T.He] [T.is] missing [T.his] tongue!</span>\n"

	//splints
	for(var/organ in list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM))
		var/obj/item/organ/external/o = get_organ(organ)
		if(o && o.splinted && o.splinted.loc == o)
			msg += "<span class='warning'>[T.He] [T.has] \a [o.splinted] on [T.his] [o.name]!</span>\n"

	if(mSmallsize in mutations)
		msg += "[T.He] [T.is] small halfling!\n"

	var/distance = 0
	if(isghost(user) || user.stat == DEAD) // ghosts can see anything
		distance = 1
	else
		distance = get_dist(user,src)
	if (src.stat)
		msg += "<span class='warning'>[T.He] [T.is]n't responding to anything around [T.him] and seems to be unconscious.</span>\n"
		if((stat == DEAD || is_asystole() || src.losebreath) && distance <= 3)
			msg += "<span class='warning'>[T.He] [T.does] not appear to be breathing.</span>\n"
		if(ishuman(user) && !user.incapacitated() && Adjacent(user))
			spawn(0)
				user.visible_message("<b>\The [user]</b> checks \the [src]'s pulse.", "You check \the [src]'s pulse.")
				if(do_after(user, 15, src))
					if(pulse() == PULSE_NONE)
						to_chat(user, "<span class='deadsay'>[T.He] [T.has] no pulse.</span>")
					else
						to_chat(user, "<span class='deadsay'>[T.He] [T.has] a pulse!</span>")

	if(fire_stacks)
		msg += "[T.He] looks flammable.\n"

	if(on_fire)
		msg += "<span class='warning'>[T.He] [T.is] on fire!.</span>\n"

	msg += "<span class='warning'>"


	if(nutrition < 100)
		msg += "[T.He] [T.is] severely malnourished.\n"
	else if(nutrition >= 500)
		msg += "[T.He] [T.is] quite chubby.\n"

	for(var/datum/relation/family/R in matchmaker.get_relationships(user.mind))
		if(name == R.connected_relation.relation_holder.current.name)
			msg += "[name] is our [R.name]\n"
	msg += "</span>"

	var/ssd_msg = species.get_ssd(src)
	if(ssd_msg && (!should_have_organ(BP_BRAIN) || has_brain()) && stat != DEAD)
		if(!key)
			msg += "<span class='deadsay'>[T.He] [T.is] [ssd_msg]. It doesn't look like [T.he] [T.is] waking up anytime soon.</span>\n"
		else if(!client)
			msg += "<span class='deadsay'>[T.He] [T.is] [ssd_msg].</span>\n"

	var/mhealth = (getBruteLoss() + getFireLoss())//How injured they look. Not not nescessarily how hurt they actually are.

	if(mhealth >= 25 && mhealth < 50)//Is the person a little hurt?
		msg += "<span class='warning'><b>[T.He] looks a bit hurt.\n</b></span>"

	if(mhealth >= 50 && mhealth < 75)//Hurt.
		msg += "<span class='warning'><b>[T.He] looks hurt.</b></span>\n"

	if(mhealth >= 75)//Or incredibly hurt.
		msg += "<span class='warning'><b>[T.He] looks deadly hurt.</b>\n</span>"

	var/list/wound_flavor_text = list()
	var/applying_pressure = ""
	var/list/shown_objects = list()

	for(var/organ_tag in species.has_limbs)

		var/list/organ_data = species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]
		var/obj/item/organ/external/E = organs_by_name[organ_tag]

		if(!E)
			wound_flavor_text[organ_descriptor] = "<b>[T.He] [T.is] missing [T.his] [organ_descriptor].</b>\n"
			continue

		wound_flavor_text[E.name] = ""

		if(E.applied_pressure == src)
			applying_pressure = "<span class='info'>[T.He] [T.is] applying pressure to [T.his] [E.name].</span><br>"

		var/obj/item/clothing/hidden
		var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
		for(var/obj/item/clothing/C in clothing_items)
			if(istype(C) && (C.body_parts_covered & E.body_part))
				hidden = C
				break

		if(hidden && user != src)
			if(E.status & ORGAN_BLEEDING && !(hidden.item_flags & ITEM_FLAG_THICKMATERIAL)) //not through a spacesuit
				wound_flavor_text[hidden.name] = "<span class='danger'>[T.He] [T.has] blood soaking through [hidden]!</span><br>"
		else
			if(E.is_stump())
				wound_flavor_text[E.name] += "<b>[T.He] [T.has] a stump where [T.his] [organ_descriptor] should be.</b>\n"
				//if((E.wounds.len || E.open) && E.parent)
					//wound_flavor_text[E.name] += "[T.He] [T.has] [E.get_wounds_desc()] on [T.his] [E.parent.name].<br>"
			else
				if(!is_synth && E.robotic >= ORGAN_ROBOT && (E.parent && E.parent.robotic < ORGAN_ROBOT))
					wound_flavor_text[E.name] = "[T.He] [T.has] a [E.name].\n"
				var/wounddesc = E.get_wounds_desc()
				if(wounddesc != "nothing")
					wound_flavor_text[E.name] += "[T.He] [T.has] [wounddesc] on [T.his] [E.name].<br>"
/*
		if(!hidden || distance <=1)
			if(E.dislocated > 0)
				wound_flavor_text[E.name] += "[T.His] [E.joint] is dislocated!<br>"
			if(((E.status & ORGAN_BROKEN) && E.brute_dam > E.min_broken_damage) || (E.status & ORGAN_MUTATED))
				wound_flavor_text[E.name] += "[T.His] [E.name] is broken!<br>"
*/

		for(var/datum/wound/wound in E.wounds)
			if(wound.embedded_objects.len)
				shown_objects += wound.embedded_objects
				wound_flavor_text["[E.name]"] += "The [wound.desc] on [T.his] [E.name] has \a [english_list(wound.embedded_objects, and_text = " and \a ", comma_text = ", \a ")] sticking out of it!<br>"

/*
	msg += "<span class='warning'>"
	for(var/limb in wound_flavor_text)
		msg += wound_flavor_text[limb]
	msg += "</span>"
*/

	for(var/obj/implant in get_visible_implants(0))
		if(implant in shown_objects)
			continue
		msg += "<span class='danger'>[src] [T.has] \a [implant.name] sticking out of [T.his] flesh!</span>\n"
	if(digitalcamo)
		msg += "[T.He] [T.is] repulsively uncanny!\n"

	var/obj/item/organ/external/head/O = locate(/obj/item/organ/external/head) in organs
	if(O && O.get_teeth() < O.max_teeth)
		msg += "<span class='warning'><B>[O.get_teeth() <= 0 ? "All" : "[O.max_teeth - O.get_teeth()]"] of [T.his] teeth are missing!</B></span>\n"

	if(pale)
		msg += "\n<span class='combatglow'><b>They look pale.</b></span>\n"

	if(!skipface)
		if(happiness <= MOOD_LEVEL_SAD2)
			msg += "<span class='warning'>[T.He] looks sad.</span>\n"

	if(decaylevel == 1)
		msg += "[T.He] [T.is] starting to smell.\n"
	if(decaylevel == 2)
		msg += "[T.He] [T.is] bloated and smells disgusting.\n"
	if(decaylevel == 3)
		msg += "[T.He] [T.is] rotting and blackened, the skin sloughing off. The smell is indescribably foul.\n"
	if(decaylevel == 4)
		msg += "[T.He] [T.is] mostly dessicated now, with only bones remaining of what used to be a person.\n"

	if(hasHUD(user,"security"))
		var/perpname = "wot"
		var/criminal = "None"

		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetIdCard()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
		else
			perpname = name

		if(perpname)
			var/datum/computer_file/crew_record/R = get_crewmember_record(perpname)
			if(R)
				criminal = R.get_criminalStatus()

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='byond://?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='byond://?src=\ref[src];secrecord=`'>\[View\]</a>\n"

	if(hasHUD(user,"medical"))
		var/perpname = "wot"
		var/medical = "None"

		if(wear_id)
			if(istype(wear_id,/obj/item/weapon/card/id))
				perpname = wear_id:registered_name
			else if(istype(wear_id,/obj/item/device/pda))
				var/obj/item/device/pda/tempPda = wear_id
				perpname = tempPda.owner
		else
			perpname = src.name

		var/datum/computer_file/crew_record/R = get_crewmember_record(perpname)
		if(R)
			medical = R.get_status()

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='byond://?src=\ref[src];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='byond://?src=\ref[src];medrecord=`'>\[View\]</a>\n"

	msg += "</span></div></div>"
	msg += applying_pressure

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "[T.He] [pose]"

	to_chat(user, jointext(msg, null))

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M as mob, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		switch(hudtype)
			if("security")
				if(istype(H.glasses,/obj/item/clothing/glasses))
					var/obj/item/clothing/glasses/G = H.glasses
					return istype(G.hud, /obj/item/clothing/glasses/hud/security) || istype(G, /obj/item/clothing/glasses/hud/security)
				else
					return FALSE
			if("medical")
				if(istype(H.glasses,/obj/item/clothing/glasses))
					var/obj/item/clothing/glasses/G = H.glasses
					return istype(G.hud, /obj/item/clothing/glasses/hud/health) || istype(G, /obj/item/clothing/glasses/hud/health)
				else
					return FALSE
			else
				return 0
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		switch(hudtype)
			if("security")
				return istype(R.module_state_1, /obj/item/borg/sight/hud/sec) || istype(R.module_state_2, /obj/item/borg/sight/hud/sec) || istype(R.module_state_3, /obj/item/borg/sight/hud/sec)
			if("medical")
				return istype(R.module_state_1, /obj/item/borg/sight/hud/med) || istype(R.module_state_2, /obj/item/borg/sight/hud/med) || istype(R.module_state_3, /obj/item/borg/sight/hud/med)
			else
				return 0
	else
		return 0

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. [get_visible_gender() == MALE ? "He" : get_visible_gender() == FEMALE ? "She" : "They"] [get_visible_gender() == NEUTER ? "are" : "is"]...", "Pose", null)  as text)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	var/list/HTML = list()
	HTML += "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Update Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='byond://?src=\ref[src];flavor_change=done'>\[Done\]</a>"
	HTML += "<tt>"
	src << browse(jointext(HTML,null), "window=flavor_changes;size=430x300")

