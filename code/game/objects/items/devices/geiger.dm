//Geiger counter
//Rewritten version of TG's geiger counter
//I opted to show exact radiation levels

/obj/item/device/geiger
	name = "geiger counter"
	desc = "A handheld device used for detecting and measuring radiation in an area."
	description_info = "By using this item, you may toggle its scanning mode on and off. Examine it while it's on to check for ambient radiation."
	description_fluff = "For centuries geiger counters have been saving the lives of unsuspecting laborers and technicians. You can never be too careful around radiation."
	icon_state = "geiger_off"
	item_state = "multitool"
	w_class = ITEM_SIZE_SMALL
	var/scanning = 0
	var/radiation_count = 0

/obj/item/device/geiger/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/device/geiger/Process()
	if(!scanning)
		return
	radiation_count = SSradiation.get_rads_at_turf(get_turf(src))
	update_icon()

/obj/item/device/geiger/attack_self(var/mob/user)
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_icon()
	playsound(usr, 'sound/effects/mechanic_enable.ogg', 50, 0)
	to_chat(user, "<span class='notice'>\icon[src] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/device/geiger/resolve_attackby(var/atom/A)
	var/turf/T = A
	if(!scanning)
		return
	if(!istype(T))
		to_chat(usr, "<span class='warning'>\The [src] only scans the surrounding area.</span>")
		playsound(usr, 'sound/misc/denied.ogg', 50, 0)
		return
	. = ..(usr)
	var/msg = "[scanning ? "Ambient" : "Stored"] radiation level: [radiation_count ? radiation_count : "0"] Bq."
	playsound(usr, 'sound/misc/accepted.ogg', 50, 0)
	to_chat(usr, "<span class='notice'>[msg]</span>")

/obj/item/device/geiger/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1

	switch(radiation_count)
		if(null) icon_state = "geiger_on_1"
		if(-INFINITY to RAD_LEVEL_LOW) icon_state = "geiger_on_1"
		if(RAD_LEVEL_LOW + 0.01 to RAD_LEVEL_MODERATE) icon_state = "geiger_on_2"
		if(RAD_LEVEL_MODERATE + 0.1 to RAD_LEVEL_HIGH) icon_state = "geiger_on_3"
		if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH) icon_state = "geiger_on_4"
		if(RAD_LEVEL_VERY_HIGH + 1 to INFINITY) icon_state = "geiger_on_5"

