/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	plane = HUD_PLANE
	layer = HUD_BASE_LAYER
	appearance_flags = NO_CLIENT_COLOR
	unacidable = 1
	var/obj/master = null    //A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.
	var/globalscreen = FALSE //Global screens are not qdeled when the holding mob is destroyed.

/obj/screen/Destroy()
	master = null
	return ..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	var/list/object_overlays = list() // Required for inventory/screen overlays.

/obj/screen/close
	name = "close"
	icon = 'icons/mob/screen1_small.dmi'
	icon_state = "x"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			playsound(loc, S.close_sound, 75, 1)
			S.close(usr)
	return 1


/obj/screen/item_action
	var/obj/item/owner

/obj/screen/item_action/Destroy()
	..()
	owner = null

/obj/screen/item_action/Click()
	if(!usr || !owner)
		return 1
	if(!usr.canClick())
		return

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return 1

	if(!(owner in usr))
		return 1

	owner.ui_action_click()
	return 1

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click()
	if(!usr.canClick())
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			usr.ClickOn(master)
	return 1

/obj/screen/happiness_icon/Click()
	var/mob/living/carbon/C = usr
	C.print_happiness(C)

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_CHEST

/obj/screen/zone_sel/Click(location, control,params)
	var/clicksound = list('sound/misc/UISwitch1.ogg', 'sound/misc/UISwitch2.ogg', 'sound/misc/PopupMenu.ogg')
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change
	//var/old_src_aim = src_aim

	switch(icon_y)
		if(5 to 8) //Feet
			switch(icon_x)
				if(7 to 15)
					selecting = BP_R_FOOT
				if(18 to 26)
					selecting = BP_L_FOOT
				else
					return 1
		if(9 to 27) //Legs
			switch(icon_x)
				if(10 to 16)
					selecting = BP_R_LEG
				if(18 to 23)
					selecting = BP_L_LEG
				else
					return 1
		if(28 to 34) //Hands and groin
			switch(icon_x)
				if(4 to 8)
					selecting = BP_R_HAND
				if(12 to 21)
					selecting = BP_GROIN
				if(24 to 29)
					selecting = BP_L_HAND
				else
					return 1
		if(31 to 49) //Chest and arms to shoulders
			switch(icon_x)
				if(7 to 11)
					selecting = BP_R_ARM
				if(12 to 21)
					selecting = BP_CHEST
				if(22 to 26)
					selecting = BP_L_ARM
				else
					return 1

		if(50 to 52)//Neck
			switch(icon_x)
				if(14 to 19)
					selecting = BP_THROAT

		if(53 to 60) //Head, but we need to check for eye or mouth
			switch(icon_x)
				if(10 to 23)
					selecting = BP_HEAD
		if(69 to 72)
			switch(icon_x)
				if(13 to 20)
					selecting = BP_MOUTH

		if(77 to 81)
			switch(icon_x)
				if(11 to 22)
					selecting = BP_EYES


	if(old_selecting != selecting)
		update_icon()
	playsound(usr, pick(clicksound), 30, 0)
	return 1

/obj/screen/zone_sel/proc/set_selected_zone(bodypart)
	var/old_selecting = selecting
	selecting = bodypart
	if(old_selecting != selecting)
		update_icon()

/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/zone_sel_newer.dmi', "[selecting]")

/*
/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")
*/
/obj/screen/intent
	name = "intent"
	//icon = 'icons/mob/screen/dark.dmi'
	icon_state = "intent_help"
	screen_loc = ui_drop_throw//ui_acti
	var/intent = I_HELP

/obj/screen/intent/Click(var/location, var/control, var/params)
	var/clicksound = list('sound/misc/UISwitch1.ogg', 'sound/misc/UISwitch2.ogg', 'sound/misc/PopupMenu.ogg')
	var/list/P = params2list(params)
	var/icon_x = text2num(P["icon-x"])
	var/icon_y = text2num(P["icon-y"])
	playsound(usr, pick(clicksound), 30, 0)
	intent = I_GRAB
	if(icon_x <= world.icon_size/2)
		if(icon_y <= world.icon_size/2)
			intent = I_HELP
		else
			intent = I_HURT
	else if(icon_y <= world.icon_size/2)
		intent = I_DISARM
	update_icon()
	usr.a_intent = intent

/obj/screen/intent/update_icon()
	icon_state = "intent_[intent]"

/obj/screen/combat
	name = "Combat Intent"
	icon = 'icons/mob/screen/dark.dmi'
	icon_state = "aim"
	screen_loc = ui_atk_intents
	var/intent = I_STRONG

/obj/screen/combat/Click(var/location, var/control, var/params)
	var/clicksound = list('sound/misc/UISwitch1.ogg', 'sound/misc/UISwitch2.ogg', 'sound/misc/PopupMenu.ogg')
	var/list/P = params2list(params)
	var/icon_x = text2num(P["icon-x"])
	var/icon_y = text2num(P["icon-y"])
	playsound(usr, pick(clicksound), 30, 0)
	intent = I_STRONG
	if(icon_x <= world.icon_size/2)
		if(icon_y <= world.icon_size/2)
			intent = I_DEFEND
		else
			intent = I_AIM
	else if(icon_y <= world.icon_size/2)
		intent = I_QUICK
	update_icon()
	usr.c_intent = intent

/obj/screen/combat/update_icon()
	icon_state = "[intent]"

/obj/screen/skills_family
	name = "skills_family"
	icon = 'icons/mob/screen/dark.dmi'
	icon_state = "skills_family"
	screen_loc = ui_skills_family//ui_acti

/obj/screen/skills_family/Click(var/location, var/control, var/params)
	var/clicksound = list('sound/misc/UISwitch1.ogg', 'sound/misc/UISwitch2.ogg', 'sound/misc/PopupMenu.ogg')
	var/list/P = params2list(params)
	var/icon_y = text2num(P["icon-y"])
	playsound(usr, pick(clicksound), 30, 0)
	if(icon_y <= world.icon_size/2)
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			H.check_skills()
	else
		if(ishuman(usr))
			chat_crew_manifest()

/obj/screen/Click(location, control, params)
	if(!usr)	return 1
	var/clicksound = list('sound/misc/UISwitch1.ogg', 'sound/misc/UISwitch2.ogg', 'sound/misc/PopupMenu.ogg')
	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			playsound(usr, pick(clicksound), 30, 0)
			usr.hud_used.hidden_inventory_update()

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()
			playsound(usr, pick(clicksound), 30, 0)

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()
			playsound(usr, pick(clicksound), 30, 0)


		if("mov_intent")
			playsound(usr, pick(clicksound), 30, 0)
			switch(usr.m_intent)
				if("run")
					usr.m_intent = "walk"
					usr.hud_used.move_intent.icon_state = "walking"
				if("walk")
					usr.m_intent = "run"
					usr.hud_used.move_intent.icon_state = "running"

		if("Reset Machine")
			usr.unset_machine()

		if("health")
			if(ishuman(usr))
				var/mob/living/carbon/human/X = usr
				X.exam_self()
				playsound(usr, pick(clicksound), 30, 0)


		if("surrender")
			if(ishuman(usr))
				var/mob/living/carbon/human/S = usr
				S.surrender()
				playsound(usr, pick(clicksound), 30, 0)


		if("internal")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.stat && !C.stunned && !C.paralysis && !C.restrained())
					if(C.internal)
						C.internal = null
						to_chat(C, "<span class='notice'>No longer running on internals.</span>")
						if(C.internals)
							C.internals.icon_state = "internal0"
					else

						var/no_mask
						if(!(C.wear_mask && C.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT))
							var/mob/living/carbon/human/H = C
							if(!(H.head && H.head.item_flags & ITEM_FLAG_AIRTIGHT))
								no_mask = 1

						if(no_mask)
							to_chat(C, "<span class='notice'>You are not wearing a suitable mask or helmet.</span>")
							return 1
						else
							var/list/nicename = null
							var/list/tankcheck = null
							var/breathes = "oxygen"    //default, we'll check later
							var/list/contents = list()
							var/from = "on"

							if(ishuman(C))
								var/mob/living/carbon/human/H = C
								breathes = H.species.breath_type
								nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
								tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)
							else
								nicename = list("right hand", "left hand", "back")
								tankcheck = list(C.r_hand, C.l_hand, C.back)

							for(var/i=1, i<tankcheck.len+1, ++i)
								if(istype(tankcheck[i], /obj/item/weapon/tank))
									var/obj/item/weapon/tank/t = tankcheck[i]
									if (!isnull(t.manipulated_by) && t.manipulated_by != C.real_name && findtext(t.desc,breathes))
										contents.Add(t.air_contents.total_moles)	//Someone messed with the tank and put unknown gasses
										continue					//in it, so we're going to believe the tank is what it says it is
									switch(breathes)
																		//These tanks we're sure of their contents
										if("nitrogen") 							//So we're a bit more picky about them.

											if(t.air_contents.gas["nitrogen"] && !t.air_contents.gas["oxygen"])
												contents.Add(t.air_contents.gas["nitrogen"])
											else
												contents.Add(0)

										if ("oxygen")
											if(t.air_contents.gas["oxygen"] && !t.air_contents.gas["phoron"])
												contents.Add(t.air_contents.gas["oxygen"])
											else
												contents.Add(0)

										// No races breath this, but never know about downstream servers.
										if ("carbon dioxide")
											if(t.air_contents.gas["carbon_dioxide"] && !t.air_contents.gas["phoron"])
												contents.Add(t.air_contents.gas["carbon_dioxide"])
											else
												contents.Add(0)


								else
									//no tank so we set contents to 0
									contents.Add(0)

							//Alright now we know the contents of the tanks so we have to pick the best one.

							var/best = 0
							var/bestcontents = 0
							for(var/i=1, i <  contents.len + 1 , ++i)
								if(!contents[i])
									continue
								if(contents[i] > bestcontents)
									best = i
									bestcontents = contents[i]


							//We've determined the best container now we set it as our internals

							if(best)
								to_chat(C, "<span class='notice'>You are now running on internals from [tankcheck[best]] [from] your [nicename[best]].</span>")
								playsound(C, 'sound/effects/internals.ogg', 50, 0)
								C.internal = tankcheck[best]


							if(C.internal)
								if(C.internals)
									C.internals.icon_state = "internal1"
							else
								to_chat(C, "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>")
		if("act_intent")
			usr.a_intent_change("right")
			playsound(usr, pick(clicksound), 30, 0)

		if("pull")
			usr.stop_pulling()
			playsound(usr, pick(clicksound), 30, 0)


		if("rest")
			usr.mob_rest()
			playsound(usr, pick(clicksound), 30, 0)


		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
				playsound(usr, pick(clicksound), 30, 0)
		if("drop")
			if(usr.client)
				usr.client.drop_item()
				playsound(usr, pick(clicksound), 30, 0)
		if("wield")
			if(!ishuman(usr)) return
			var/mob/living/carbon/human/HH = usr
			var/obj/item/I = HH.get_active_hand()
			if(!I)
				return
			I.attempt_wield(HH)
			playsound(usr, pick(clicksound), 30, 0)
		if("kick")
			playsound(usr, pick(clicksound), 30, 0)
			if(usr.middle_click_intent == "kick")
				usr.middle_click_intent = null
				usr.kick_icon.icon_state = "kick"
			else
				usr.middle_click_intent = "kick"
				usr.kick_icon.icon_state = "kick_on"
				usr.jump_icon.icon_state = "jump"
		if("jump")
			playsound(usr, pick(clicksound), 30, 0)
			if(usr.middle_click_intent == "jump")
				usr.middle_click_intent = null
				usr.jump_icon.icon_state = "jump"
			else
				usr.middle_click_intent = "jump"
				usr.jump_icon.icon_state = "jump_on"
				usr.kick_icon.icon_state = "kick"
		if("combat mode")
			if(!ishuman(usr))	return
			usr << 'sound/effects/ui_toggle.ogg'
			var/mob/living/carbon/human/C = usr
			if(C.combat_mode)
				C.combat_mode = 0
				C.combat_icon.icon_state = "combat0"
			else
				C.combat_mode = 1
				C.combat_icon.icon_state = "combat1"

		if("dodge intent")
			if(ishuman(usr))
				playsound(usr, pick(clicksound), 30, 0)
				var/mob/living/carbon/human/E = usr
				if(E.defense_intent == I_PARRY)
					E.defense_intent = I_DODGE
					E.dodge_intent_icon.icon_state = "dodge"
				else
					E.defense_intent = I_PARRY
					E.dodge_intent_icon.icon_state = "parry"
		if("fixeye")
			usr.face_direction()
			playsound(usr, pick(clicksound), 30, 0)
			if(usr.facing_dir)
				usr.fixeye.icon_state = "fixeye_on"
			else
				usr.fixeye.icon_state = "fixeye"

		if("mood")
			playsound(usr, pick(clicksound), 30, 0)
			var/mob/living/carbon/C = usr
			C.print_happiness(C)

		if("stamina")
			playsound(usr, pick(clicksound), 30, 0)
			var/mob/living/M = usr
			M.report_stamina()

		if("module")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
//				if(R.module)
//					R.hud_used.toggle_show_robot_modules()
//					return 1
				R.pick_module()

		if("inventory")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.hud_used.toggle_show_robot_modules()
					return 1
				else
					to_chat(R, "You haven't selected a module yet.")

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.uneq_active()
					R.hud_used.update_robot_modules_display()
				else
					to_chat(R, "You haven't selected a module yet.")

		if("module1")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(1)

		if("module2")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(2)

		if("module3")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(3)
		else
			return 0
	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(!usr.canClick())
		return 1
	if(usr.stat || usr.paralysis || usr.stunned)//|| usr.weakened Don't need none of that shit no more.
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
				if(C.hand)
					C.activate_hand("r")
				else
					C.attack_empty_hand(BP_R_HAND)
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
				if(!C.hand)
					C.activate_hand("l")
				else
					C.attack_empty_hand(BP_L_HAND)
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()

		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
	return 1
