/obj/machinery/button/remote
	name = "remote object control"
	desc = "It controls objects, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	power_channel = ENVIRON
	var/desiredstate = 0
	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = 1.0
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/button/remote/attack_ai(mob/user as mob)
	if(wires & 2)
		return src.attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/button/remote/attackby(obj/item/weapon/W, mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/button/remote/emag_act(var/remaining_charges, var/mob/user)
	if(req_access.len || req_one_access.len)
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)
		return 1

/obj/machinery/button/remote/attack_hand(mob/user as mob)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		to_chat(user, "<span class='warning'>Access Denied</span>")
		flick("[initial(icon_state)]-denied",src)
		return

	use_power_oneoff(5)
	icon_state = "[initial(icon_state)]1"
	desiredstate = !desiredstate
	trigger(user)
	spawn(15)
		update_icon()

/obj/machinery/button/remote/proc/trigger()
	return

/obj/machinery/button/remote/update_icon()
	if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = "[initial(icon_state)]"

/*
	Door control with id
*/

/obj/machinery/button/remote/id
	name = "remote door control"
	desc = "It controls doors, remotely. Using an id."
	icon_state = "doorctrlid"
	var/deny = 0

/obj/machinery/button/remote/id/Initialize()
	. = ..()
	update_icon()

/obj/machinery/button/remote/id/proc/CanToggleButton(var/mob/user, var/obj/item/weapon/card/id/id_card)
	return allowed(user) || (istype(id_card) && check_access_list(id_card.GetAccess()))

/obj/machinery/button/remote/id/attack_hand(mob/user as mob)
	to_chat(user, "<span class='info'>Maybe, if I use an ID this would work?</span>")
	return

/obj/machinery/button/remote/id/attackby(var/obj/item/I, var/mob/user, var/obj/item/weapon/card/id/id_card)
	if(stat & (NOPOWER|BROKEN))
		return

	if(CanToggleButton(user, id_card) && istype(I, /obj/item/weapon/card/id/))
		use_power_oneoff(5)
		icon_state = "[initial(icon_state)]1"
		desiredstate = !desiredstate
		trigger(user)
		spawn(12)
		update_icon() // this is ass - Turret. No you're ass - Mclovin
		playsound(src, 'sound/ported/BUILD_TRAP.ogg', 40)
	else if(!CanToggleButton(user, id_card))
		to_chat(user, "<span class='danger'>No, wrong access.</span>")
		playsound(src, 'sound/machines/button11.ogg', 40)
		deny = 1
		update_icon()
	else
		to_chat(user, "<span class='danger'>I can't do this like that.</span>")
		playsound(src, 'sound/machines/button11.ogg', 40)
		deny = 1
		update_icon()

/obj/machinery/button/remote/id/trigger()
	for(var/obj/machinery/door/blast/iddoor/ID in world)
		if(ID.id == src.id)
			if(ID.density)
				spawn(5)
					ID.open()
					overlays += overlay_image(icon, "doorctrlid0-overlay", plane = ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER)
					update_icon()
					return
			else
				spawn(5)
					ID.close()
					overlays += overlay_image(icon, "doorctrlid0-overlay", plane = ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER)
					update_icon()
					return

/obj/machinery/button/remote/id/update_icon()
	overlays.Cut()

	icon_state = "[initial(icon_state)]"
	overlays += overlay_image(icon, "doorctrlid1-overlay", plane = ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER)

	if(stat & NOPOWER)
		flick("[initial(icon_state)]-denied", src)
		overlays += overlay_image(icon, "doorctrliddeny-overlay", plane = ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER)
	if(deny)
		flick("[initial(icon_state)]-denied", src)
		overlays += overlay_image(icon, "doorctrliddeny-overlay", plane = ABOVE_LIGHTING_PLANE, layer = ABOVE_LIGHTING_LAYER)
		deny = 0

/*
	Airlock remote control
*/

// Bitmasks for door switches.
#define OPEN   0x1
#define IDSCAN 0x2
#define BOLTS  0x4
#define SHOCK  0x8
#define SAFE   0x10

/obj/machinery/button/remote/airlock
	name = "remote door-control"
	desc = "It controls doors, remotely."

	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties
	*/

/obj/machinery/button/remote/airlock/trigger()
	for(var/obj/machinery/door/airlock/D in world)
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					spawn(0)
						D.open()
						return
				else
					spawn(0)
						D.close()
						return
			if(desiredstate == 1)
				if(specialfunctions & IDSCAN)
					D.set_idscan(0)
				if(specialfunctions & BOLTS)
					D.lock()
				if(specialfunctions & SHOCK)
					D.electrify(-1)
				if(specialfunctions & SAFE)
					D.set_safeties(0)
			else
				if(specialfunctions & IDSCAN)
					D.set_idscan(1)
				if(specialfunctions & BOLTS)
					D.unlock()
				if(specialfunctions & SHOCK)
					D.electrify(0)
				if(specialfunctions & SAFE)
					D.set_safeties(1)

#undef OPEN
#undef IDSCAN
#undef BOLTS
#undef SHOCK
#undef SAFE

/*
	Blast door remote control
*/
/obj/machinery/button/remote/blast_door
	name = "remote blast door-control"
	desc = "It controls blast doors, remotely."
	icon_state = "blastctrl"

/obj/machinery/button/remote/blast_door/trigger()
	for(var/obj/machinery/door/blast/M in world)
		if(M.id == src.id)
			if(M.density)
				spawn(0)
					M.open()
					return
			else
				spawn(0)
					M.close()
					return

/*
	Emitter remote control
*/
/obj/machinery/button/remote/emitter
	name = "remote emitter control"
	desc = "It controls emitters, remotely."

/obj/machinery/button/remote/emitter/trigger(mob/user as mob)
	for(var/obj/machinery/power/emitter/E in world)
		if(E.id == src.id)
			spawn(0)
				E.activate(user)
				return

/*
	Mass driver remote control
*/
/obj/machinery/button/remote/driver
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"

/obj/machinery/button/remote/driver/trigger(mob/user as mob)
	set waitfor = 0
	active = 1
	update_icon()

	for(var/obj/machinery/door/blast/M in SSmachines.machinery)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in SSmachines.machinery)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/blast/M in SSmachines.machinery)
		if (M.id == src.id)
			spawn(0)
				M.close()
				return

	icon_state = "launcherbtt"
	update_icon()

	return

/obj/machinery/button/remote/driver/update_icon()
	if(!active || (stat & NOPOWER))
		icon_state = "launcherbtt"
	else
		icon_state = "launcheract"
