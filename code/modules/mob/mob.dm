/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	STOP_PROCESSING(SSmobs, src)
	GLOB.dead_mob_list_ -= src
	GLOB.living_mob_list_ -= src
	unset_machine()
	QDEL_NULL(hud_used)
	if(istype(ability_master))
		QDEL_NULL(ability_master)
	for(var/obj/item/grab/G in grabbed_by)
		QDEL_NULL(G)
	clear_fullscreen()
	if(client)
		remove_screen_obj_references()
		for(var/atom/movable/AM in client.screen)
			var/obj/screen/screenobj = AM
			if(!istype(screenobj) || !screenobj.globalscreen)
				qdel(screenobj)
		client.screen = list()
	if(mind && mind.current == src)
		spellremove(src)
	ghostize(0)
	..()
	return QDEL_HINT_HARDDEL

/mob/proc/remove_screen_obj_references()
	hands = null
	pullin = null
	purged = null
	internals = null
	oxygen = null
	i_select = null
	m_select = null
	toxin = null
	fire = null
	bodytemp = null
	healths = null
	throw_icon = null
	nutrition_icon = null
	pressure = null
	pain = null
	item_use_icon = null
	gun_move_icon = null
	gun_setting_icon = null
	ability_master = null
	zone_sel = null

/mob/Initialize()
	. = ..()
	START_PROCESSING(SSmobs, src)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)	return

	//spaghetti code
	if(type)
		if((type & VISIBLE_MESSAGE) && is_blind())//Vision related
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
		if((type & AUDIBLE_MESSAGE) && is_deaf())//Hearing related
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
				if(((type & VISIBLE_MESSAGE) && is_blind()))
					return

	to_chat(src, msg)


// Show a message to all mobs and objects in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/mob/visible_message(var/message, var/self_message, var/blind_message, var/range = world.view, var/checkghosts = null, var/narrate = FALSE)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T,range, mobs, objs, checkghosts)

	for(var/o in objs)
		var/obj/O = o
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in mobs)
		var/mob/M = m
		if(self_message && M == src)
			M.show_message(self_message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(M.see_invisible >= invisibility || narrate)
			M.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)
			continue
	//Multiz, have shadow do same
	if(bound_overlay)
		bound_overlay.visible_message(message, self_message, blind_message)

// Returns an amount of power drawn from the object (-1 if it's not viable).
// If drain_check is set it will not actually drain power, just return a value.
// If surge is set, it will destroy/damage the recipient and not return any power.
// Not sure where to define this, so it can sit here for the rest of time.
/atom/proc/drain_power(var/drain_check,var/surge, var/amount = 0)
	return -1

// Show a message to all mobs and objects in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/mob/audible_message(var/message, var/self_message, var/deaf_message, var/hearing_distance = world.view, var/checkghosts = null, var/narrate = FALSE)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T, hearing_distance, mobs, objs, checkghosts)

	for(var/m in mobs)
		var/mob/M = m
		if(self_message && M == src)
			M.show_message(self_message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else if(M.see_invisible >= invisibility || narrate) // Cannot view the invisible
			M.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else
			M.show_message(message, AUDIBLE_MESSAGE)

	for(var/o in objs)
		var/obj/O = o
		O.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)

/mob/proc/findname(msg)
	for(var/mob/M in SSmobs.mob_list)
		if (M.real_name == msg)
			return M
	return 0

/mob/proc/movement_delay()
	. = -0.5
	if(istype(loc, /turf))
		var/turf/T = loc
		. += T.movement_delay
	if(pulling)
		if(istype(pulling, /obj))
			var/obj/O = pulling
			. += between(0, O.w_class, ITEM_SIZE_GARGANTUAN) / 5
		else if(istype(pulling, /mob))
			var/mob/M = pulling
			. += max(0, M.mob_size) / MOB_MEDIUM
		else
			. += 1

/mob/proc/Life()
//	if(organStructure)
//		organStructure.ProcessOrgans()
	return

#define UNBUCKLED 0
#define PARTIALLY_BUCKLED 1
#define FULLY_BUCKLED 2
/mob/proc/buckled()
	// Preliminary work for a future buckle rewrite,
	// where one might be fully restrained (like an elecrical chair), or merely secured (shuttle chair, keeping you safe but not otherwise restrained from acting)
	if(!buckled)
		return UNBUCKLED
	return restrained() ? FULLY_BUCKLED : PARTIALLY_BUCKLED

/mob/proc/is_blind()
	return ((sdisabilities & BLIND) || blinded || incapacitated(INCAPACITATION_KNOCKOUT))

/mob/proc/is_deaf()
	return ((sdisabilities & DEAF) || ear_deaf || incapacitated(INCAPACITATION_KNOCKOUT))

/mob/proc/is_physically_disabled()
	return incapacitated(INCAPACITATION_DISABLED)

/mob/proc/cannot_stand()
	return incapacitated(INCAPACITATION_KNOCKDOWN)

/mob/proc/incapacitated(var/incapacitation_flags = INCAPACITATION_DEFAULT)

	if ((incapacitation_flags & INCAPACITATION_STUNNED) && stunned)
		return 1

	if ((incapacitation_flags & INCAPACITATION_FORCELYING) && (resting || pinned.len))
		return 1

	if ((incapacitation_flags & INCAPACITATION_KNOCKOUT) && (stat || paralysis || sleeping || (status_flags & FAKEDEATH)))
		return 1

	if((incapacitation_flags & INCAPACITATION_RESTRAINED) && restrained())
		return 1

	if((incapacitation_flags & (INCAPACITATION_BUCKLED_PARTIALLY|INCAPACITATION_BUCKLED_FULLY)))
		var/buckling = buckled()
		if(buckling >= PARTIALLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_PARTIALLY))
			return 1
		if(buckling == FULLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_FULLY))
			return 1

	return 0

#undef UNBUCKLED
#undef PARTIALLY_BUCKLED
#undef FULLY_BUCKLED

/mob/proc/restrained()
	return

/mob/proc/reset_view(atom/A)
	if (client)
		A = A ? A : eyeobj
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return


/mob/proc/show_inv(mob/user as mob)
	return

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if((is_blind(src) || usr.stat) && !isobserver(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return 1

	face_atom(A)
	A.examine(src)

/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(!src || !isturf(src.loc) || !(A in view(src.loc)))
		return 0
	if(istype(A, /obj/effect/decal/point))
		return 0

	var/tile = get_turf(A)
	if (!tile)
		return 0

	var/obj/P = new /obj/effect/decal/point(tile)
	P.invisibility = invisibility
	spawn(20)
		if(P)
			P.pixel_x = A.pixel_x
			P.pixel_y = A.pixel_y
		qdel(P)

	face_atom(A)
	return 1

//Gets the mob grab conga line.
/mob/proc/ret_grab(list/L)
	if (!istype(l_hand, /obj/item/grab) && !istype(r_hand, /obj/item/grab))
		return L
	if (!L)
		L = list(src)
	for(var/A in list(l_hand,r_hand))
		if (istype(A, /obj/item/grab))
			var/obj/item/grab/G = A
			if (!(G.affecting in L))
				L += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L)
	return L

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc,/obj/mecha)) return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
		else
			attack_empty_hand(BP_L_HAND)
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()
		else
			attack_empty_hand(BP_R_HAND)

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "AddNote"
	set category = "IC"

	if(!client) return

	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",rhtml_decode(flavor_text)) as message|null, extra = 0)
	if(msg != null)
		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		to_chat(src, "<h2 class='alert'>OOC Warning:</h2>")
		to_chat(src, "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>")

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(length(msg) <= 40)
			return "<span class='notice'>[msg]</span>"
		else
			return "<span class='notice'>[copytext_preserve_html(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a></span>"

/*
/mob/verb/help()
	set name = "Help"
	src << browse('html/help.html', "window=help")
	return
*/

/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	set hidden = 1
	getFiles(
		'html/88x31.png',
		'html/bug-minus.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/map-pencil.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/scales.png',
		'html/spell-check.png',
		'html/wrench-screwdriver.png',
		'html/changelog.css',
		'html/changelog.html'
		)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		prefs.save_preferences()
		winset(src, "rpane.changelog", "background-color=none;font-style=;")
		SScharacter_setup.queue_preferences_save(prefs)

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	unset_machine()
	reset_view(null)

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["flavor_more"])
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, cp1251_to_utf8(replacetext(flavor_text, "\n", "<BR>"))), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()

//	..()
	return

/mob/proc/pull_damage()
	return 0

/mob/living/carbon/human/pull_damage()
	if(!lying || getBruteLoss() + getFireLoss() < 100)
		return 0
	for(var/thing in organs)
		var/obj/item/organ/external/e = thing
		if(!e || e.is_stump())
			continue
		if((e.status & ORGAN_BROKEN) && !e.splinted)
			return 1
		if(e.status & ORGAN_BLEEDING)
			return 1
	return 0

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(istype(M,/mob/living/silicon/ai)) return
	show_inv(usr)

/mob/verb/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null
		if(pullin)
			pullin.icon_state = "pull0"

/mob/proc/start_pulling(var/atom/movable/AM)

	if ( !AM || !usr || src==AM || !isturf(src.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	if (AM.anchored)
		to_chat(src, "<span class='warning'>It won't budge!</span>")
		return

	var/mob/M = AM
	if(ismob(AM))

		if(!can_pull_mobs || !can_pull_size)
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		if((mob_size < M.mob_size) && (can_pull_mobs != MOB_PULL_LARGER))
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		if((mob_size == M.mob_size) && (can_pull_mobs == MOB_PULL_SMALLER))
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		// If your size is larger than theirs and you have some
		// kind of mob pull value AT ALL, you will be able to pull
		// them, so don't bother checking that explicitly.

		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = usr

	else if(isobj(AM))
		var/obj/I = AM
		if(!can_pull_size || can_pull_size < I.w_class)
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return

	src.pulling = AM
	AM.pulledby = src

	if(pullin)
		pullin.icon_state = "pull1"

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.pull_damage())
			to_chat(src, "<span class='danger'>Pulling \the [H] in their current condition would probably be a bad idea.</span>")
	//Attempted fix for people flying away through space when cuffed and dragged.
	if(ismob(AM))
		var/mob/pulled = AM
		pulled.inertia_dir = 0

/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/is_dead()
	return stat == DEAD

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI"))
		return 1
	return istype(src, /mob/living/silicon)

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/get_gender()
	return gender

/mob/proc/see(message)
	if(!is_active())
		return 0
	to_chat(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/Stat()
	..()
	. = (is_client_active(10 MINUTES))
	if(!.)
		return

	if(statpanel("Status"))
		if(GAME_STATE >= RUNLEVEL_LOBBY)
			//stat("Local Time", stationtime2text())
			//stat("Local Date", stationdate2text())
			stat("Round Duration", roundduration2text())
		if(client.holder || isghost(client.mob))
			stat("Location:", "([x], [y], [z]) [loc]")

	if(client.holder)
		if(statpanel("MC"))
			stat("CPU:","[world.cpu]")
			stat("Instances:","[world.contents.len]")
			stat(null)
			if(Master)
				Master.stat_entry()
			else
				stat("Master Controller:", "ERROR")
			if(Failsafe)
				Failsafe.stat_entry()
			else if (Master.initializing)
				stat("Failsafe Controller:", "Waiting for MC")
			else
				stat("Failsafe Controller:", "ERROR")
			if(Master)
				stat(null)
				for(var/datum/controller/subsystem/SS in Master.subsystems)
					SS.stat_entry()

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			if(statpanel("Turf"))
				stat(listed_turf)
				for(var/atom/A in listed_turf)
					if(!A.mouse_opacity)
						continue
					if(A.invisibility > see_invisible)
						continue
					if(is_type_in_list(A, shouldnt_see))
						continue
					stat(A)


// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(anchored)						return 0
	if(transforming)					return 0
	return 1

// Not sure what to call this. Used to check if humans are wearing an AI-controlled exosuit and hence don't need to fall over yet.
/mob/proc/can_stand_overridden()
	return 0

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	var/oriDir = dir

	if(!resting && cannot_stand() && can_stand_overridden())
		lying = 0
		canmove = 1
	else if(buckled)
		anchored = 1
		canmove = 0
		if(istype(buckled))
			if(buckled.buckle_lying == -1)
				lying = incapacitated(INCAPACITATION_KNOCKDOWN)
			else
				lying = buckled.buckle_lying
			if(buckled.buckle_movable)
				anchored = 0
				canmove = 1
	else
		lying = incapacitated(INCAPACITATION_KNOCKDOWN)
		canmove = !incapacitated(INCAPACITATION_DISABLED)
		//playsound(src, "pratfall", 50)

	if(lying)
		set_density(0)
	else
		set_density(initial(density))
	reset_layer()

	for(var/obj/item/grab/G in grabbed_by)
		if(G.stop_move())
			canmove = 0

		if(G.force_stand())
			lying = 0

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn
	if( update_icon )	//forces a full overlay update
		update_icon = 0
		regenerate_icons()
	else if(lying != lying_prev || hanging != hanging_prev)
		update_icons()
	// Only update the vision cone of the direction after turning around is different than what we had before.
	if(oriDir != dir)
		update_vision_cone()
	return canmove

/mob/proc/reset_layer()
	if(lying)
		layer = LYING_MOB_LAYER
	else
		reset_plane_and_layer()

/mob/proc/facedir(var/ndir)
	if(!canface() || client.moving || world.time < client.move_delay)
		return 0
	set_dir(ndir)
	if(buckled && buckled.buckle_movable)
		buckled.set_dir(ndir)
	client.move_delay += movement_delay()
	return 1


/mob/verb/eastface()
	set hidden = 1
	return facedir(client.client_dir(EAST))


/mob/verb/westface()
	set hidden = 1
	return facedir(client.client_dir(WEST))


/mob/verb/northface()
	set hidden = 1
	return facedir(client.client_dir(NORTH))


/mob/verb/southface()
	set hidden = 1
	return facedir(client.client_dir(SOUTH))


//This might need a rename but it should replace the can this mob use things check
/mob/proc/IsAdvancedToolUser()
	return 0

/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		facing_dir = null
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		if(l_hand) unEquip(l_hand)
		if(r_hand) unEquip(r_hand)
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
	return

/mob/proc/Weaken(amount)
	if(status_flags & CANWEAKEN)
		facing_dir = null
		weakened = max(max(weakened,amount),0)
		update_canmove()	//updates lying, canmove and icons
		resting = 1
		if(l_hand) unEquip(l_hand)
		if(r_hand) unEquip(r_hand)
	return

/mob/proc/SetWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(weakened + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		facing_dir = null
		paralysis = max(max(paralysis,amount),0)
		if(l_hand) unEquip(l_hand)
		if(r_hand) unEquip(r_hand)
		resting = 1
	return

/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount,0)
	return

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount,0)
	return

/mob/proc/Sleeping(amount)
	facing_dir = null
	sleeping = max(max(sleeping,amount),0)
	if(l_hand) unEquip(l_hand)
	if(r_hand) unEquip(r_hand)
	resting =1
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

/mob/proc/Resting(amount)
	facing_dir = null
	resting = max(max(resting,amount),0)
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	return

/mob/proc/get_species()
	return ""

/mob/proc/get_visible_implants(var/class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

/mob/proc/embedded_needs_process()
	return (embedded.len > 0)
/mob/proc/remove_implant(var/obj/item/implant, var/surgical_removal = FALSE)
	if(!LAZYLEN(get_visible_implants(0))) //Yanking out last object - removing verb.
		verbs -= /mob/proc/yank_out_object
	for(var/obj/item/weapon/O in pinned)
		if(O == implant)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	implant.dropInto(loc)
	implant.add_blood(src)
	implant.update_icon()
	if(istype(implant,/obj/item/weapon/implant))
		var/obj/item/weapon/implant/imp = implant
		imp.removed()
	. = TRUE

/mob/living/silicon/robot/remove_implant(var/obj/item/implant, var/surgical_removal = FALSE)
	embedded -= implant
	adjustBruteLoss(5)
	adjustFireLoss(10)
	. = ..()

/mob/living/carbon/human/remove_implant(var/obj/item/implant, var/surgical_removal = FALSE, var/obj/item/organ/external/affected)
	if(!affected) //Grab the organ holding the implant.
		for(var/obj/item/organ/external/organ in organs)
			for(var/obj/item/O in organ.implants)
				if(O == implant)
					affected = organ
					break
	if(affected)
		affected.implants -= implant
		for(var/datum/wound/wound in affected.wounds)
			wound.embedded_objects -= implant
		if(!surgical_removal)
			shock_stage+=20
			if(prob(implant.w_class * 5) && affected.sever_artery()) //I'M SO ANEMIC I COULD JUST -DIE-.
				custom_pain("Something tears wetly in your [affected.name] as [implant] is pulled free!", 50, affecting = affected)
	. = ..()

mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || !usr.canClick())
		return
	usr.setClickCooldown(20)

	if(usr.stat == 1)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	valid_objects = get_visible_implants(0)
	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove.")
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on [selection] in your body.</span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on [selection] in [S]'s body.</span>")
	if(!do_mob(U, S, 30))
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>")
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>")
	valid_objects = get_visible_implants(0)
	if(valid_objects.len == 1) //Yanking out last object - removing verb.
		src.verbs -= /mob/proc/yank_out_object

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/affected

		for(var/obj/item/organ/external/organ in H.organs) //Grab the organ holding the implant.
			for(var/obj/item/O in organ.implants)
				if(O == selection)
					affected = organ

		affected.implants -= selection
		for(var/datum/wound/wound in affected.wounds)
			wound.embedded_objects -= selection

		H.shock_stage+=20
		affected.take_external_damage((selection.w_class * 3), 0, DAM_EDGE, "Embedded object extraction")

		if(prob(selection.w_class * 5) && affected.sever_artery()) //I'M SO ANEMIC I COULD JUST -DIE-.
			H.custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 50, affecting = affected)

		if (ishuman(U))
			var/mob/living/carbon/human/human_user = U
			human_user.bloody_hands(H)

	else if(issilicon(src))
		var/mob/living/silicon/robot/R = src
		R.embedded -= selection
		R.adjustBruteLoss(5)
		R.adjustFireLoss(10)

	selection.forceMove(get_turf(src))
	if(!(U.l_hand && U.r_hand))
		U.put_in_hands(selection)

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	return 1

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/update_icon()
	return

/mob/living/carbon/human/proc/fixeye_proc()
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/C = usr
	C.face_direction()
	if(C.facing_dir)
		C.fixeye.icon_state = "fixeye_on"
	else
		C.fixeye.icon_state = "fixeye"


/mob/living/carbon/human/verb/fixeye_hotkey()
	set name = ".fixeye"
	set hidden = 1

	fixeye_proc()

/obj/targeting_overlay
	name = ""
	icon = 'icons/effects/Targeted.dmi'
	icon_state = "locking"
	anchored = 1
	density = 0
	opacity = 0
	layer = ABOVE_HUMAN_LAYER
	simulated = 0
	mouse_opacity = 0

	var/mob/owner       // Who do we belong to?

/obj/targeting_overlay/New(var/newowner)
	..()
	owner = newowner

/obj/targeting_overlay/Process()
	if(!owner)
		qdel(src)
		return
	..()
	update_target()

/mob/MiddleClick(mob/M)
	var/mob/targeted = M
	var/mob/targeting = usr
	var/obj/targeting_overlay/TO
	if (!(targeted in able_mobs_in_oview(M)))
		to_chat(targeting, "<span class='warning'>I can't focus on [M].</span>")
		qdel(TO)
		return
	else
		start_targeting(targeted)

/mob/proc/start_targeting(mob/M)
	var/mob/targeted = M
	var/obj/targeting_overlay/TO
	if(get_dist(usr,src) <= 10)
		usr.face_atom(targeted)
		TO.update_target()

/obj/targeting_overlay/proc/update_target(mob/M)
	return
	//var/mob/targeted = M
	//var/obj/targeting_overlay = new(targeted.loc)

/mob/proc/face_direction()
	set_face_dir()

/mob/proc/set_face_dir(var/newdir)
	if(!isnull(facing_dir) && newdir == facing_dir)
		facing_dir = null
	else if(newdir)
		set_dir(newdir)
		facing_dir = newdir
	else if(facing_dir)
		facing_dir = null
	else
		set_dir(dir)
		facing_dir = dir

/mob/set_dir()
	if(facing_dir)
		if(!canface() || lying || buckled || restrained())
			facing_dir = null
		else if(dir != facing_dir)
			return ..(facing_dir)
	else
		return ..()

/mob/proc/set_stat(var/new_stat)
	. = stat != new_stat
	stat = new_stat

/mob/verb/northfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(NORTH))

/mob/verb/southfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(SOUTH))

/mob/verb/eastfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(EAST))

/mob/verb/westfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(WEST))

/mob/proc/adjustEarDamage()
	return

/mob/proc/setEarDamage()
	return

//Throwing stuff

/mob/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(src.throw_icon) //in case we don't have the HUD and we use the hotkey
		src.throw_icon.icon_state = "act_throw_off"

/mob/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(src.throw_icon)
		src.throw_icon.icon_state = "act_throw_on"

/mob/proc/toggle_antag_pool()
	set name = "Toggle Add-Antag Candidacy"
	set desc = "Toggles whether or not you will be considered a candidate by an add-antag vote."
	set category = "OOC"
	if(isghostmind(src.mind) || isnewplayer(src))
		if(SSticker.looking_for_antags)
			if(src.mind in SSticker.antag_pool)
				SSticker.antag_pool -= src.mind
				to_chat(usr, "You have left the antag pool.")
			else
				SSticker.antag_pool += src.mind
				to_chat(usr, "You have joined the antag pool. Make sure you have the needed role set to high!")
		else
			to_chat(usr, "The game is not currently looking for antags.")
	else
		to_chat(usr, "You must be observing or in the lobby to join the antag pool.")
/mob/proc/is_invisible_to(var/mob/viewer)
	return (!alpha || !mouse_opacity || viewer.see_invisible < invisibility)

/mob/living/proc/report_stamina()
	var/msg = "You should not see this!"
	if(getStaminaLoss())
		switch((getStaminaLoss()))
			if(150 to INFINITY)
				msg = "I can barely move."
			if(100 to 150)
				msg = "I need to catch my breath!"
			if(50 to 100)
				msg = "I'm getting a little winded."
			else
				msg = "I feel like I could run forever!"
	to_chat(src, msg)
	return

/client/proc/check_has_body_select()
	return mob && mob.hud_used && istype(mob.zone_sel, /obj/screen/zone_sel)

/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = 1
	toggle_zone_sel(list(BP_HEAD,BP_EYES,BP_MOUTH))

/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = 1
	toggle_zone_sel(list(BP_R_ARM,BP_R_HAND))

/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = 1
	toggle_zone_sel(list(BP_L_ARM,BP_L_HAND))

/client/verb/body_chest()
	set name = "body-chest"
	set hidden = 1
	toggle_zone_sel(list(BP_CHEST))

/client/verb/body_groin()
	set name = "body-groin"
	set hidden = 1
	toggle_zone_sel(list(BP_GROIN))

/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = 1
	toggle_zone_sel(list(BP_R_LEG,BP_R_FOOT))

/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = 1
	toggle_zone_sel(list(BP_L_LEG,BP_L_FOOT))

/client/proc/toggle_zone_sel(list/zones)
	if(!check_has_body_select())
		return
	var/obj/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(next_in_list(mob.zone_sel.selecting,zones))

proc/uh(var/S)
	var/regex/upper = new("\[A-Z\]", "g")
	var/regex/lower = new("\[a-z\]", "g")
	S = upper.Replace(S,"U")	 //All uppercases become "U"
	S = lower.Replace(S, "h")	 //replaces all lowercase letters with "h"
	S = replacetext(S," h"," u") //makes it so we words start with "u" most of the time.
	return S

/mob/proc/handle_drowning()
	return FALSE

/mob/proc/can_drown()
	return 0

/mob/is_fluid_pushable(var/amt)
	if(..() && !buckled && (lying || !Check_Shoegrip()) && (amt >= mob_size * (lying ? 5 : 10)))
		if(!lying)
			Weaken(1)
			if(lying && prob(20))
				to_chat(src, "<span class='danger'>You are pushed down by the flood!</span>")
		return TRUE
	return FALSE

/mob/proc/return_pointer(var/client/client)
	usr.client.mouse_pointer_icon = 'icons/misc/pointer_cursor.dmi'