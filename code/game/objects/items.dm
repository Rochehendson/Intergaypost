/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	w_class = ITEM_SIZE_NORMAL
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/randpixel = 6
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/equipsound = null
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/no_attack_log = 0			//If it's an item we don't want to log attack_logs with, set this to 1
	pass_flags = PASS_FLAG_TABLE
//	causeerrorheresoifixthis
	var/obj/item/master = null
	var/list/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/list/attack_verb = list("hit") //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/lock_picking_level = 0 //used to determine whether something can pick a lock, and how well.
	var/force = 0

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for
	var/default_action_type = /datum/action/item_action // Specify the default type and behavior of the action button for this atom.

	//This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	//It should be used purely for appearance. For gameplay effects caused by items covering body parts, use body_parts_covered.
	var/flags_inv = 0
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags

	var/item_flags = 0 //Miscellaneous flags pertaining to equippable objects.

	var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown_general = 0 // How much clothing is slowing you down. Negative values speeds you up. This is a genera##l slowdown, no matter equipment slot.
	var/slowdown_per_slot[slot_last] // How much clothing is slowing you down. This is an associative list: item slot - slowdown
	var/slowdown_accessory // How much an accessory will slow you down when attached to a worn article of clothing.
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = 0 //1 if item is actively being used to zoom. For scoped guns and binoculars.

	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	var/use_alt_layer = FALSE // Use the slot's alternative layer when rendering on a mob

	//** These specify item/icon overrides for _slots_

	var/list/item_state_slots = list(slot_wear_id_str = "id") //overrides the default item_state for particular slots.

	// Used to specify the icon file to be used when the item is worn. If not set the default icon for that slot will be used.
	// If icon_override or sprite_sheets are set they will take precendence over this, assuming they apply to the slot in question.
	// Only slot_l_hand/slot_r_hand are implemented at the moment. Others to be implemented as needed.
	var/list/item_icons

	//** These specify item/icon overrides for _species_

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		SPECIES_TAJARA = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = list()

	// Species-specific sprite sheets for inventory sprites
	// Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	var/list/sprite_sheets_obj = list()

	var/sharpness = 0 //This is a special snowflake var that lets us cut peoples' heads off.
	var/block_chance = 0 //This is the chance in percent that we will be able to block an attack with this weapon.
	var/base_block_chance = 0
	var/list/parry_sounds = null //List of parry sounds to play when we block.

	var/next_attack_time = 0
	var/weapon_speed_delay = 15
	var/drop_sound = 'sound/items/device_drop.ogg'
	var/swing_sound = null
	var/drawsound = null
	var/wielded = 0
	var/wieldsound = 'sound/weapons/thudswoosh.ogg'
	var/unwieldsound = null
	var/wielded_icon = null
	var/force_unwielded = 0
	var/force_wielded = 0

	///Used when thrown into a mob
	var/mob_throw_hit_sound
	///Sound used when equipping the item into a valid slot
	var/equip_sound
	///Sound uses when picking the item up (into your hands)
	var/list/pickup_sounds = list('sound/items/pickup/gear1.ogg', 'sound/items/pickup/gear2.ogg')

/obj/item/New()
	..()
	if(!swing_sound)
		if(sharp || edge)
			swing_sound = "swing_sound"
		else
			swing_sound = "blunt_swing"
	if(randpixel && (!pixel_x && !pixel_y) && isturf(loc)) //hopefully this will prevent us from messing with mapper-set pixel_x/y
		pixel_x = rand(-randpixel, randpixel)
		pixel_y = rand(-randpixel, randpixel)

/obj/item/Initialize()
	. = ..()
	if(!swing_sound)
		if(sharp || edge)
			swing_sound = "swing_sound"
		else
			swing_sound = "blunt_swing"

/obj/item/Destroy()
	qdel(hidden_uplink)
	hidden_uplink = null
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
		m.update_inv_r_hand()
		m.update_inv_l_hand()
		src.loc = null
	return ..()

/obj/item/device
	icon = 'icons/obj/device.dmi'

/mob/living/proc/do_wield()
	var/obj/item/I = get_active_hand()
	if(!I)
		return
	I.attempt_wield(src)

/obj/item/proc/unwield(mob/user)
	if(!wielded || !user)
		return
	wielded = 0
	if(force_unwielded)
		force = force_unwielded
	else
		force = (force / 1.5)
	var/sf = findtext(name," (Wielded)")
	if(sf)
		name = copytext(name,1,sf)
	else //something wrong
		name = "[initial(name)]"
	update_unwield_icon()
	update_icon()
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()

	user.visible_message("<span class='warning'>[user] stops squeezing his other hand.")
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
	if(O && istype(O))
		O.unwield()
	return

/obj/item/proc/wield(mob/user)
	if(wielded)
		return
	if(!is_held_twohanded(user))
		return
	if(user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	wielded = 1
	if(force_wielded)
		force = force_wielded
	else
		force = (force * 1.5)
	name = "wielded [name]"
	update_wield_icon()
	update_icon()//Legacy
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	user.visible_message("<span class='warning'>[user] squeezes the [initial(name)] with both hands.")
	if(wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second grip on the [name]"
	user.put_in_inactive_hand(O)
	return

/obj/item/proc/update_wield_icon()
	if(wielded && wielded_icon)
		item_state = wielded_icon

/obj/item/proc/update_unwield_icon()//That way it doesn't interupt any other special icon_states.
	if(!wielded && wielded_icon)
		item_state = "[initial(item_state)]"

//For general weapons.
/obj/item/proc/attempt_wield(mob/user)
	if(wielded) //Trying to unwield it
		unwield(user)
	else //Trying to wield it
		wield(user)

//Checks if the item is being held by a mob, and if so, updates the held icons
/obj/item/proc/update_twohanding()
	update_held_icon()

/obj/item/proc/update_held_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		if(M.l_hand == src)
			M.update_inv_l_hand()
		else if(M.r_hand == src)
			M.update_inv_r_hand()

/obj/item/proc/is_held_twohanded(mob/living/M)
	var/check_hand
	if(M.l_hand == src && !M.r_hand)
		check_hand = BP_R_HAND //item in left hand, check right hand
	else if(M.r_hand == src && !M.l_hand)
		check_hand = BP_L_HAND //item in right hand, check left hand
	else
		return FALSE

	//would check is_broken() and is_malfunctioning() here too but is_malfunctioning()
	//is probabilistic so we can't do that and it would be unfair to just check one.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
		if(istype(hand) && hand.is_usable())
			return TRUE
	return FALSE


/obj/item/weapon/twohanded/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = ITEM_SIZE_NO_CONTAINER
	obj_flags = ATOM_FLAG_NO_BLOOD | OBJ_FLAG_ABSTRACT

/obj/item/weapon/twohanded/offhand/unwield()
	wielded = FALSE
	if(!QDELETED(src))
		qdel(src)

/obj/item/weapon/twohanded/offhand/wield()
	if(wielded)//Only delete if we're wielded
		wielded = FALSE
		if(!QDELETED(src))
			qdel(src)

/obj/item/weapon/twohanded/offhand/dropped(mob/living/user)
	..()
	var/obj/item/I = user.get_active_hand()
	var/obj/item/II = user.get_inactive_hand()
	loc = null
	if(I)
		I.unwield(user)
	if(II)
		II.unwield(user)
	if(!QDELETED(src))
		qdel(src)

/mob/living/verb/wield_hotkey()//For the hotkeys. Not sure where this should be put. But it pertains to two-handing so *shrug*.
	set name = ".wield"
	set hidden = 1
	do_wield()

/obj/item/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
		if(3)
			if (prob(5))
				qdel(src)

/*
/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T
*/

/obj/item/examine()
	set src in view()

	var/TheReach
	if(istype(src, /obj/item/weapon))
		var/obj/item/weapon/W = src
		if(W.w_class >= 1)
			TheReach = "Size: "
			switch(W.w_class)
				if(1)
					TheReach += "•"
				if(2)
					TheReach += "••"
				if(3)
					TheReach += "•••"
				if(4)
					TheReach += "••••"
				if(5)
					TheReach += "•••••"
				if(6)
					TheReach += "••••••"

	if(!isobserver(usr))
		usr.visible_message("<span class='looksatbold'>[usr.name]</span> <span class='looksat'>looks at [src].</span>")
		if(get_dist(usr,src) > 5)//Don't get descriptions of things far away.
			to_chat(usr, "<span class='passivebold'>It's too far away to see clearly.</span>")
			return

	var/randtext = null
	//var/valuetext = "No idea."

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.stats[STAT_IQ] <= 5)
			randtext = pick("Yoh!","Doh!","Haha")
/*
		if(H.check_perk(/datum/perk/ref/value))
			valuetext = "[src.item_worth]"
*/

		to_chat(H, "<div class='firstdivexamine'><div class='box'><span class='statustext'>This is a [src.blood_DNA ? "bloody " : ""][icon2html(src, usr)]</span> <span class='uppertext'>[src.name]. [randtext]</span>\n<span class='statustext'>[src.desc]</span>\n[TheReach]</div></div>")

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (hasorgans(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable() || temp && temp.status & ORGAN_BROKEN)
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!</span>")
			return
		if(!temp)
			to_chat(user, "<span class='notice'>You try to use your hand, but realize it is no longer attached!</span>")
			return

	var/old_loc = src.loc

	if (istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src)
	src.pickup(user)
	src.throwing = 0
	if (src.loc == user)
		if(!user.unEquip(src))
			return
	else
		if(isliving(src.loc))
			return
	if(user.put_in_active_hand(src))
		if (isturf(old_loc))
			var/obj/effect/temporary/item_pickup_ghost/ghost = new(old_loc, src)
			ghost.animate_towards(user)
		if(randpixel)
			pixel_x = rand(-randpixel, randpixel)
			pixel_y = rand(-randpixel/2, randpixel/2)
			pixel_z = 0
		else if(randpixel == 0)
			pixel_x = 0
			pixel_y = 0
	return

/obj/item/attack_ai(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect all items
				if(isturf(src.loc))
					S.gather_all(src.loc, user)
			else if(S.can_be_inserted(src, user))
				S.handle_item_insertion(src)

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return Clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return Clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0

/obj/item/throw_impact(atom/hit_atom)
	..()
	if(isliving(hit_atom)) //Living mobs handle hit sounds differently.
		var/volume = get_volume_by_throwforce_and_or_w_class()
		if (throwforce > 0)
			if (mob_throw_hit_sound)
				playsound(hit_atom, mob_throw_hit_sound, volume, TRUE, -1)
			else if(hitsound)
				playsound(hit_atom, hitsound, volume, TRUE, -1)
			else
				playsound(hit_atom, 'sound/weapons/genhit.ogg', volume, TRUE, -1)
		else
			playsound(hit_atom, 'sound/weapons/throwtap.ogg', 1, volume, -1)
	else
		playsound(src, drop_sound, 50)


// apparently called whenever an item is removed from a slot, container, or anything else.
/obj/item/proc/dropped(mob/user as mob)
	if(randpixel)
		pixel_z = randpixel //an idea borrowed from some of the older pixel_y randomizations. Intended to make items appear to drop at a character
	if(zoom)
		zoom(user) //binoculars, scope, etc

	update_twohanding()
	if(user)
		if(user.l_hand)
			user.l_hand.update_twohanding()
		if(user.r_hand)
			user.r_hand.update_twohanding()
	if(wielded)
		unwield(user)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

/obj/item/proc/mill()
	return

/obj/item/proc/press()
	return


// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	hud_layerise()
	if(user.client)	user.client.screen |= src
	if(user.pulling == src) user.stop_pulling()

	//Update two-handing status
	var/mob/M = loc
	if(!istype(M))
		return
	if(M.l_hand)
		M.l_hand.update_twohanding()
	if(M.r_hand)
		M.r_hand.update_twohanding()

	if((slot_flags & slot))
		if(equip_sound)
			playsound(src, equip_sound, 50)
		else
			playsound(src, drop_sound, 50)
	else if(slot == slot_l_hand || slot == slot_r_hand)
		playsound(src, pick(pickup_sounds), 50)


	if(wielded)
		unwield(user)



//Defines which slots correspond to which slot flags
var/list/global/slot_flags_enumeration = list(
	"[slot_wear_mask]" = SLOT_MASK,
	"[slot_back]" = SLOT_BACK,
	"[slot_wear_suit]" = SLOT_OCLOTHING,
	"[slot_gloves]" = SLOT_GLOVES,
	"[slot_shoes]" = SLOT_FEET,
	"[slot_belt]" = SLOT_BELT,
	"[slot_glasses]" = SLOT_EYES,
	"[slot_head]" = SLOT_HEAD,
	"[slot_l_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_r_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_w_uniform]" = SLOT_ICLOTHING,
	"[slot_wear_id]" = SLOT_ID,
	"[slot_wear_amulet]" = SLOT_AMULET,
	"[slot_tie]" = SLOT_TIE,
	)

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
//Should probably move the bulk of this into mob code some time, as most of it is related to the definition of slots and not item-specific
//set force to ignore blocking overwear and occupied slots
/obj/item/proc/mob_can_equip(M as mob, slot, disable_warning = 0, force = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!ishuman(M)) return 0

	var/mob/living/carbon/human/H = M
	var/list/mob_equip = list()
	if(H.species.hud && H.species.hud.equip_slots)
		mob_equip = H.species.hud.equip_slots

	if(H.species && !(slot in mob_equip))
		return 0

	//First check if the item can be equipped to the desired slot.
	if("[slot]" in slot_flags_enumeration)
		var/req_flags = slot_flags_enumeration["[slot]"]
		if(!(req_flags & slot_flags))
			return 0

	if(!force)
		//Next check that the slot is free
		if(H.get_equipped_item(slot))
			return 0

		//Next check if the slot is accessible.
		var/mob/_user = disable_warning? null : H
		if(!H.slot_is_accessible(slot, src, _user))
			return 0

	//Lastly, check special rules for the desired slot.
	switch(slot)
		if(slot_l_ear, slot_r_ear)
			var/slot_other_ear = (slot == slot_l_ear)? slot_r_ear : slot_l_ear
			if( (w_class > ITEM_SIZE_TINY) && !(slot_flags & SLOT_EARS) )
				return 0
			if( (slot_flags & SLOT_TWOEARS) && H.get_equipped_item(slot_other_ear) )
				return 0
		if(slot_belt)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>Nuh-uh. I need a jumpsuit before I can attach this [name].</span>")
				return 0
		if(slot_l_store, slot_r_store)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>Nuh-uh. I need a jumpsuit before I can attach this [name].</span>")
				return 0
			if(slot_flags & SLOT_DENYPOCKET)
				return 0
			if( w_class > ITEM_SIZE_SMALL && !(slot_flags & SLOT_POCKET) )
				return 0
			if(get_storage_cost() == ITEM_SIZE_NO_CONTAINER)
				return 0 //pockets act like storage and should respect ITEM_SIZE_NO_CONTAINER. Suit storage might be fine as is
		if(slot_s_store)
			if(!H.wear_suit && (slot_wear_suit in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>No. I need a suit before I can attach this [name].</span>")
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(usr, "<span class='warning'>You somehow have a suit with no defined allowed items for suit storage, stop that.</span>")
				return 0
			if( !(istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed)) )
				return 0
		if(slot_handcuffed)
			if(!istype(src, /obj/item/weapon/handcuffs))
				return 0
		if(slot_in_backpack) //used entirely for equipping spawned mobs or at round start
			var/allow = 0
			if(H.back && istype(H.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = H.back
				if(B.can_be_inserted(src,M,1))
					allow = 1
			if(!allow)
				return 0
		if(slot_tie)
			if((!H.w_uniform && (slot_w_uniform in mob_equip)) && (!H.wear_suit && (slot_wear_suit in mob_equip)))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I don't have anything to attach \the [src] to.</span>")
				return 0
			var/obj/item/clothing/under/uniform = H.w_uniform
			var/obj/item/clothing/suit/suit = H.wear_suit
			if((uniform && !uniform.can_attach_accessory(src)) && (suit && !suit.can_attach_accessory(src)))
				if (!disable_warning)
					to_chat(H, "<span class='warning'>Nope, can't equip \the [src].</span>")
				return 0
	return 1

/obj/item/proc/mob_can_unequip(mob/M, slot, disable_warning = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!canremove)
		return 0
	if(!M.slot_is_accessible(slot, src, disable_warning? null : M))
		return 0
	return 1

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(usr.incapacitated(INCAPACITATION_STUNNED) || usr.incapacitated(INCAPACITATION_KNOCKOUT) || usr.stat || usr.restrained() || !Adjacent(usr))//!usr.canmove
		return //If they're stunned, or knocked out, then they can't pick shit up. But if they're just lying down they can.
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	attack_self(usr)

/obj/item/weapon/proc/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	var/defense_mode_modifier = user.c_intent == I_DEFEND ? 15 : 0 //If they are blocking, make parrying fairly easy
	return base_block_chance + user.skills["melee"] + defense_mode_modifier

//RETURN VALUES
//handle_shield should return a positive value to indicate that the attack is blocked and should be prevented.
//If a negative value is returned, it should be treated as a special return value for bullet_act() and handled appropriately.
//For non-projectile attacks this usually means the attack is blocked.
//Otherwise should return 0 to indicate that the attack is not affected in any way.
/obj/item/weapon/proc/handle_shield(mob/living/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(block_chance <= 0)
		return 0
	if(user.incapacitated())
		return 0
	if(isnull(parry_sounds))
		parry_sounds = list('sound/weapons/blunt_parry1.ogg', 'sound/weapons/blunt_parry2.ogg', 'sound/weapons/blunt_parry3.ogg')
	if(default_sword_parry(user, damage, attacker, damage_source))
		return 1
	return 0

//The point of this is for weapons that blocks puts significant stress on your hand, making it hard to hold (Sword, crowbar)
//It's in  a different funtion so we can make it more difficult then the default parry check, which is used for shields, which anoyone can use to parry.
/obj/item/proc/default_sword_parry(mob/living/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(default_parry_check(user, attacker, damage_source) && (user.get_active_hand() == src))//You gotta be holding onto that sheesh bro
		if(prob((user.skills["melee"]/2) + block_chance)) //a check on block chance
			user.visible_message("<span class='danger'>\The [user] parries [attack_text] with \the [src]!</span>")
			if(parry_sounds)
				playsound(user.loc, pick(parry_sounds), 50, 1)
			user.adjustStaminaLoss(10)
			health -= 0.5
			if(!user.statcheck(user.stats[STAT_ST], damage/2, "I couldn't keep the grip on my weapon!", STAT_ST))
				user.visible_message("<span class='danger'><font size =3>\The [src] flies out of \the [user]'s hand!</font></span>")
				user.drop_from_inventory(src)
				throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), throw_speed)//Throw that sheesh away
			return 1
	return 0

/proc/default_parry_check(mob/living/user, mob/attacker, atom/damage_source)
	//parry only melee attacks
	if(istype(damage_source, /obj/item/projectile) || (attacker && get_dist(user, attacker) > 1) || user.incapacitated())
		return 0

	var/defense_mode_modifier = user.c_intent == I_DEFEND ? 25 : 0 //If they are blocking, make parrying fairly easy

	if(!user.combat_mode)//If you're not in combat mode you will have a harder time parrying
		defense_mode_modifier -= 20

	if(user.staminaloss >= 100) //Less stamina makes it harder to block
		defense_mode_modifier -= 25

	if(user.defense_intent != I_PARRY)//If you're not on parry intent, you won't parry.
		return 0

	if(user.zoomed == 1)//If you're looking in the distance, you're not parrying.
		return 0

	user.adjustStaminaLoss(10)

	if(!user.skillcheck(user.skills["melee"], 45 - defense_mode_modifier, 0, "Melee")) //Need to be decent at melee fighting to parry everything
		return 0

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if(!check_shield_arc(user, bad_arc, damage_source, attacker))
		return 0

	return 1

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H))
		for(var/obj/item/protection in list(H.head, H.wear_mask, H.glasses))
			if(protection && (protection.body_parts_covered & EYES))
				// you can't stab someone in the eyes wearing a mask!
				to_chat(user, "<span class='warning'>You're going to need to remove the eye covering first.</span>")
				return

	if(!M.has_eyes())
		to_chat(user, "<span class='warning'>You cannot locate any eyes on [M]!</span>")
		return

	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)

	src.add_fingerprint(user)
	if((CLUMSY in user.mutations) && prob(50))
		M = user
		to_chat(M, "<span class='warning'>You stab yourself in the eye, you poor fool.</span>")
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)

	if(istype(H))

		var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]

		if(H != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("<span class='danger'>[M] has been stabbed in the eye with [src] by [user].</span>", 1)
			to_chat(M, "<span class='danger'>[user] stabs you in the eye with [src]!</span>")
			to_chat(user, "<span class='danger'>You stab [M] in the eye with [src]!</span>")
		else
			user.visible_message( \
				"<span class='danger'>[user] has stabbed themself with [src]!</span>", \
				"<span class='danger'>You stab yourself in the eyes with [src]!</span>" \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(eyes.robotic < ORGAN_ROBOT) //robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You go blind!</span>")

		var/obj/item/organ/external/affecting = H.get_organ(eyes.parent_organ)
		affecting.take_external_damage(7)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0

/obj/item/reveal_blood()
	if(was_bloodied && !fluorescent)
		fluorescent = 1
		blood_color = COLOR_LUMINOL
		blood_overlay.color = COLOR_LUMINOL
		update_icon()

/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	if(istype(src, /obj/item/weapon/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(!blood_DNA.len)
		blood_overlay.color = blood_color
		overlays += blood_overlay

	//if this blood isn't already in the list, add it
	if(istype(M))
		if(blood_DNA[M.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

GLOBAL_LIST_EMPTY(blood_overlay_cache)

/obj/item/proc/generate_blood_overlay(force = FALSE)
	if(blood_overlay && !force)
		return
	if(GLOB.blood_overlay_cache["[icon]" + icon_state])
		blood_overlay = GLOB.blood_overlay_cache["[icon]" + icon_state]
		return
	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
	blood_overlay = image(I)
	blood_overlay.appearance_flags |= NO_CLIENT_COLOR|RESET_COLOR
	GLOB.blood_overlay_cache["[icon]" + icon_state] = blood_overlay

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>I want to take a closer look...</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && I.simulated)
		I.showoff(src)

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/
//Looking through a scope or binoculars should /not/ improve your periphereal vision. Still, increase viewsize a tiny bit so that sniping isn't as restricted to NSEW
/obj/item/proc/zoom(mob/user, var/tileoffset = 14,var/viewsize = 9) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!user.client)
		return

	var/devicename
	if(zoomdevicename)
		devicename = zoomdevicename
	else
		devicename = src.name

	var/cannotzoom

	var/mob/living/carbon/human/H = user
	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, "<span class='warning'>I cannot focus through \the [devicename].</span>")
		cannotzoom = 1
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, "<span class='warning'>My visor is in the way of looking through the [devicename].</span>")
		cannotzoom = 1
	else if(!zoom && usr.get_active_hand() != src)
		to_chat(user, "<span class='warning'>I am too distracted to look through \the [devicename]. Perhaps I should focus my hands on it instead.</span>")
		cannotzoom = 1

	if(!zoom && !cannotzoom)
		if(user.hud_used.hud_shown)
			user.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
		user.client.view = viewsize
		zoom = 1

		var/tilesize = 32
		var/viewoffset = tilesize * tileoffset

		switch(user.dir)
			if (NORTH)
				user.client.pixel_x = 0
				user.client.pixel_y = viewoffset
			if (SOUTH)
				user.client.pixel_x = 0
				user.client.pixel_y = -viewoffset
			if (EAST)
				user.client.pixel_x = viewoffset
				user.client.pixel_y = 0
			if (WEST)
				user.client.pixel_x = -viewoffset
				user.client.pixel_y = 0

		user.visible_message("\The [user] peers through the [zoomdevicename ? "[zoomdevicename] of [src]" : "[src]"].")
		if(ishuman(user))
			var/mob/living/carbon/human/HM = user
			HM.SetFov(0)

	else
		user.client.view = world.view
		if(!user.hud_used.hud_shown)
			user.toggle_zoom_hud()
		zoom = 0

		user.client.pixel_x = 0
		user.client.pixel_y = 0

		if(!cannotzoom)
			user.visible_message("[zoomdevicename ? "\The [user] looks up from [src]" : "\The [user] lowers [src]"].")
		if(ishuman(user))
			var/mob/living/carbon/human/HM = user
			HM.SetFov(1)

	return

/obj/item/proc/pwr_drain()
	return 0 // Process Kill

/obj/item/proc/use_spritesheet(var/bodytype, var/slot, var/icon_state)
	if(!sprite_sheets || !sprite_sheets[bodytype])
		return 0
	if(slot == slot_r_hand_str || slot == slot_l_hand_str)
		return 0

	if(icon_state in icon_states(sprite_sheets[bodytype]))
		return 1

	return (slot != slot_wear_suit_str && slot != slot_head_str)

/obj/item/proc/get_icon_state(mob/user_mob, slot)
	var/mob_state
	if(item_state_slots && item_state_slots[slot])
		mob_state = item_state_slots[slot]
	else if (item_state)
		mob_state = item_state
	else
		mob_state = icon_state
	return mob_state

/obj/item/proc/dir_shift(var/icon/given_icon, var/dir_given, var/x = 0, var/y = 0)
	var/icon/I = new(given_icon, dir = dir_given)
	I.Shift(EAST, x)
	I.Shift(NORTH, y)
	given_icon.Insert(I, dir = dir_given)
	return given_icon

/obj/item/proc/get_mob_overlay(mob/user_mob, slot)
	var/bodytype = "Default"
	var/mob/living/carbon/human/user_human
	if(ishuman(user_mob))
		user_human = user_mob
		bodytype = user_human.species.get_bodytype(user_human)

	var/mob_state = get_icon_state(user_mob, slot)

	var/mob_icon
	var/spritesheet = FALSE
	if(icon_override)
		mob_icon = icon_override
		if(slot == 	slot_l_hand_str || slot == slot_l_ear_str)
			mob_state = "[mob_state]_l"
		if(slot == 	slot_r_hand_str || slot == slot_r_ear_str)
			mob_state = "[mob_state]_r"
	else if(use_spritesheet(bodytype, slot, mob_state))
		if(slot == slot_l_ear)
			mob_state = "[mob_state]_l"
		if(slot == slot_r_ear)
			mob_state = "[mob_state]_r"
		spritesheet = TRUE
		mob_icon = sprite_sheets[bodytype]
	else if(item_icons && item_icons[slot])
		mob_icon = item_icons[slot]
	else
		if(user_human && user_human.gender == FEMALE && user_human.species.name == SPECIES_HUMAN)
			mob_icon = slim_onmob_icons[slot]
		else
			mob_icon = default_onmob_icons[slot]

	var/image/ret_overlay = overlay_image(mob_icon,mob_state,color,RESET_COLOR)
	if(user_human && user_human.species && user_human.species.equip_adjust.len && !spritesheet)
		var/list/equip_adjusts = user_human.species.equip_adjust
		if(equip_adjusts[slot])
			var/image_key = "[user_human.species] [mob_icon] [mob_state] [color]"
			ret_overlay = user_human.species.equip_overlays[image_key]
			if(!ret_overlay)
				var/icon/final_I = new(mob_icon, icon_state = mob_state)
				var/list/shifts = equip_adjusts[slot]
				if(shifts && shifts.len)
					var/shift_facing
					for(shift_facing in shifts)
						var/list/facing_list = shifts[shift_facing]
						final_I = dir_shift(final_I, text2dir(shift_facing), facing_list["x"], facing_list["y"])
				ret_overlay = overlay_image(final_I, color, flags = RESET_COLOR)

				user_human.species.equip_overlays[image_key] = ret_overlay

	return ret_overlay

/obj/item/get_examine_line(mob/user)
	if(blood_DNA)
		. = "<span class='warning'>[icon2html(src, user)] [gender==PLURAL?"some":"a"] [(blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained [src]</span>"
	else
		. = "[icon2html(src, user)] \a [src]"//Kicking an item

/obj/item/kick_act(var/mob/living/user)
	if(!..())
		return
	var/turf/target = get_turf(src.loc)
	var/range = throw_range
	var/throw_dir = get_dir(user, src)
	for(var/i = 1; i < range; i++)
		var/turf/new_turf = get_step(target, throw_dir)
		target = new_turf
		if(new_turf.density)
			break
	throw_at(target, rand(1,3), throw_speed)
	user.visible_message("[user] kicks \the [src.name].")


/obj/item/throw_impact(atom/hit_atom)
	..()
	if(drop_sound)
		playsound(src, drop_sound, 50, 0)


/obj/item/proc/drawsound(mob/user)
	if(drawsound)
		user.visible_message("<span class = 'warning'><b>[user] grabs a weapon!</b></span>")
		playsound(user, drawsound, 50, 1)
