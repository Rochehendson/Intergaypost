#define SAVE_RESET -1

/datum/preferences
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/savefile_version = 0

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id
	var/is_bordered = 0

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change

	//character preferences
	var/species_preview                 //Used for the species selection window.

		//Mob preview
	var/icon/preview_icon = null

	var/client/client = null
	var/client_ckey = null

	var/savefile/loaded_preferences
	var/savefile/loaded_character
	var/datum/category_collection/player_setup_collection/player_setup
	var/datum/browser/panel

/datum/preferences/New(client/C)
	if(istype(C))
		client = C
		client_ckey = C.ckey
		SScharacter_setup.preferences_datums[C.ckey] = src

	player_setup = new(src)
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender,species)
	b_type = RANDOM_BLOOD_TYPE

	if(!IsGuestKey(C.key))
		load_path(C.ckey)
		load_preferences()
		load_and_update_character()
	sanitize_preferences()
	..()

/datum/preferences/proc/load_and_update_character(var/slot)
	load_character(slot)
	if(update_setup(loaded_preferences, loaded_character))
		SScharacter_setup.queue_preferences_save(src)
		save_character()

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return

	var/dat = "<html><head><title>TERMINAL CONNECTION</title>"
	dat += "<style type='text/css'>html {overflow: auto;};"
	dat += "body {"
	dat += "overflow:hidden;"
	dat += "font-family: Futura, sans-serif;"
	dat += "font-size: 17px;"
	dat += "background-repeat:repeat-x;"
	dat += "border: 4px ridge #2f303d;"
	dat += "}"
	dat += "a {text-decoration:none;outline: none;border: none;margin:-1px;}"
	dat += "a:focus{outline:none;border: none;}"
	dat += "a:hover {Color:#0d0d0d;background:#ababb3;outline: none;border: none; text-decoration:none;}"
	dat += "a.active { text-decoration:none; Color:#533333;border: none;}"
	dat += "a.inactive:hover {Color:#0d0d0d;background:#bb0000;border: none;}"
	dat += "a.active:hover {Color:#bb0000;background:#0f0f0f;}"
	dat += "a.inactive:hover { text-decoration:none; Color:#0d0d0d; background:#bb0000;border: none;}"
	dat += "a img {     border: 0; }"
	dat += "TABLE.winto {"
	dat += "z-index:-1;"
	dat += "position: absolute;"
	dat += "top: 12;"
	dat += "left:14;"
	dat += "background-position: bottom;"
	dat += "background-repeat:repeat-x;"
	dat += "border: 4px ridge #2f303d;"
	dat += "}"
	dat += "TR {"
	dat += "border: 0px;"
	dat += "}"
	dat += "span.job_class {Color:#000000;}"
	dat += "</style>"
	dat += "</head>"
	dat += "<body bgcolor='#000000' text='#c9c9c9' alink='#a6a6a6' vlink='#a6a6a6' link='#a6a6a6'>"
	dat += "<p align ='right'>"
	dat += "</p>"
	dat += "<br>"
	if(path)
		dat += "<a onfocus ='this.blur()' href='?src=\ref[src];save=1'>Save Slot</a> --- "
		dat += "<a onfocus ='this.blur()' href='?src=\ref[src];resetslot=1'>Reset Slot</a> --- "
		dat += "<a onfocus ='this.blur()' href='?src=\ref[src];load=1'>Load Slot</a><br>"
	dat += "<br>"
	dat += "<br>"
	dat += player_setup.header()
	dat += "<br>"
	dat += "<br>"
	dat += player_setup.content(user)
	dat += "</html></body>"
	user <<browse(dat,"window=player_panel;size=700x700;can_close=1;can_resize=0;border=0;titlebar=1")

/datum/preferences/proc/process_link(mob/user, list/href_list)

	if(!user)	return
	if(isliving(user)) return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.forumurl)
			user << link(config.forumurl)
		else
			to_chat(user, "<span class='danger'>The forum URL is not set in the server configuration.</span>")
			return
	ShowChoices(usr)
	return 1

/datum/preferences/Topic(href, list/href_list)
	if(..())
		return 1

	if(href_list["save"])
		save_preferences()
		save_character()
	else if(href_list["reload"])
		load_preferences()
		load_character()
		sanitize_preferences()
	else if(href_list["load"])
		if(!IsGuestKey(usr.key))
			open_load_dialog(usr)
			return 1
	else if(href_list["changeslot"])
		load_character(text2num(href_list["changeslot"]))
		sanitize_preferences()
		close_load_dialog(usr)
	else if(href_list["resetslot"])
		if(real_name != input("This will reset the current slot. Enter the character's full name to confirm."))
			return 0
		load_character(SAVE_RESET)
		sanitize_preferences()

	ShowChoices(usr)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	// Sanitizing rather than saving as someone might still be editing when copy_to occurs.
	player_setup.sanitize_setup()
	character.set_species(species)
	if(be_random_name)
		real_name = random_name(gender,species)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(GLOB.last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(GLOB.last_names)]"

	character.fully_replace_character_name(real_name)

	character.gender = gender
	character.age = age
	character.b_type = b_type

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.h_style = h_style
	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.f_style = f_style
	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.r_skin = r_skin
	character.g_skin = g_skin
	character.b_skin = b_skin

	character.s_tone = s_tone
	character.s_base = s_base

	character.h_style = h_style
	character.f_style = f_style

	// Replace any missing limbs.
	for(var/name in BP_ALL_LIMBS)
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O && organ_data[name] != "amputated")
			var/list/organ_data = character.species.has_limbs[name]
			if(!islist(organ_data)) continue
			var/limb_path = organ_data["path"]
			O = new limb_path(character)

	// Destroy/cyborgize organs and limbs. The order is important for preserving low-level choices for robolimb sprites being overridden.
	for(var/name in BP_BY_DEPTH)
		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O)
			continue
		O.status = 0
		O.robotic = 0
		O.model = null
		if(status == "amputated")
			character.organs_by_name[O.organ_tag] = null
			character.organs -= O
			if(O.children) // This might need to become recursive.
				for(var/obj/item/organ/external/child in O.children)
					character.organs_by_name[child.organ_tag] = null
					character.organs -= child
		else if(status == "cyborg")
			if(rlimb_data[name])
				O.robotize(rlimb_data[name])
			else
				O.robotize()
		else //normal organ
			O.force_icon = null
			O.SetName(initial(O.name))
			O.desc = initial(O.desc)
	//For species that don't care about your silly prefs
	character.species.handle_limbs_setup(character)
	if(!is_preview_copy)
		for(var/name in list(BP_HEART,BP_EYES,BP_BRAIN,BP_LUNGS,BP_LIVER,BP_KIDNEYS))
			var/status = organ_data[name]
			if(!status)
				continue
			var/obj/item/organ/I = character.internal_organs_by_name[name]
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.robotize()

	QDEL_NULL_LIST(character.worn_underwear)
	character.worn_underwear = list()

	for(var/underwear_category_name in all_underwear)
		var/datum/category_group/underwear/underwear_category = GLOB.underwear.categories_by_name[underwear_category_name]
		if(underwear_category)
			var/underwear_item_name = all_underwear[underwear_category_name]
			var/datum/category_item/underwear/UWD = underwear_category.items_by_name[underwear_item_name]
			var/metadata = all_underwear_metadata[underwear_category_name]
			var/obj/item/underwear/UW = UWD.create_underwear(metadata)
			if(UW)
				UW.ForceEquipUnderwear(character, FALSE)
		else
			all_underwear -= underwear_category_name

	character.backpack_setup = new(backpack, backpack_metadata["[backpack]"])

	character.force_update_limbs()
	character.update_mutations(0)
	character.update_body(0)
	character.update_underwear(0)
	character.update_hair(0)
	character.update_icons()

	character.char_branch = mil_branches.get_branch(char_branch)
	character.char_rank = mil_branches.get_rank(char_branch, char_rank)

	if(is_preview_copy)
		return

	character.flavor_texts["general"] = flavor_texts["general"]
	character.flavor_texts["head"] = flavor_texts["head"]
	character.flavor_texts["face"] = flavor_texts["face"]
	character.flavor_texts["eyes"] = flavor_texts["eyes"]
	character.flavor_texts["torso"] = flavor_texts["torso"]
	character.flavor_texts["arms"] = flavor_texts["arms"]
	character.flavor_texts["hands"] = flavor_texts["hands"]
	character.flavor_texts["legs"] = flavor_texts["legs"]
	character.flavor_texts["feet"] = flavor_texts["feet"]

	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.home_system = home_system
	character.citizenship = citizenship
	character.personal_faction = faction
	character.religion = religion

	if(!character.isSynthetic())
		character.set_nutrition(rand(140,360))
		character.set_thirst(rand(200,360))

	return


/datum/preferences/proc/open_load_dialog(mob/user)
	var/dat  = list()
	dat += "<body>"
	dat += "<tt><center>"

	var/savefile/S = new /savefile(path)
	if(S)
		dat += "<b>Select a character slot to load</b><hr>"
		var/name
		for(var/i=1, i<= config.character_slots, i++)
			S.cd = GLOB.using_map.character_load_path(S, i)
			S["real_name"] >> name
			if(!name)	name = "Character[i]"
			if(i==default_slot)
				name = "<b>[name]</b>"
			dat += "<a href='byond://?src=\ref[src];changeslot=[i]'>[name]</a><br>"

	dat += "<hr>"
	dat += "</center></tt>"
	panel = new(user, "Character Slots", "Character Slots", 300, 390, src)
	panel.set_content(jointext(dat,null))
	panel.open()

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")
	panel.close()
