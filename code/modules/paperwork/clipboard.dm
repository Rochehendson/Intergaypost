/obj/item/weapon/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 10
	var/obj/item/weapon/pen/haspen		//The stored pen.
	var/obj/item/weapon/toppaper	//The topmost piece of paper.
	slot_flags = SLOT_BELT
	matter = list(DEFAULT_WALL_MATERIAL = 70)

/obj/item/weapon/clipboard/New()
	update_icon()

/obj/item/weapon/clipboard/MouseDrop(obj/over_object as obj) //Quick clipboard fix. -Agouri
	if(ishuman(usr))
		var/mob/M = usr
		if(!(istype(over_object, /obj/screen) ))
			return ..()

		if(!M.restrained() && !M.stat)
			switch(over_object.name)
				if("r_hand")
					if(M.unEquip(src))
						M.put_in_r_hand(src)
				if("l_hand")
					if(M.unEquip(src))
						M.put_in_l_hand(src)

			add_fingerprint(usr)
			return

/obj/item/weapon/clipboard/update_icon()
	overlays.Cut()
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	if(haspen)
		overlays += "clipboard_pen"
	overlays += "clipboard_over"
	return

/obj/item/weapon/clipboard/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/photo))
		user.drop_item()
		W.loc = src
		if(istype(W, /obj/item/weapon/paper))
			toppaper = W
		to_chat(user, "<span class='notice'>You clip the [W] onto \the [src].</span>")
		update_icon()

	else if(istype(toppaper) && istype(W, /obj/item/weapon/pen))
		toppaper.attackby(W, usr)
		update_icon()

	return

/obj/item/weapon/clipboard/attack_self(mob/user as mob)
	var/dat = "<title>Clipboard</title>"
	if(haspen)
		dat += "<a href='byond://?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<a href='byond://?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. I don't think there's any way to organise contents in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/weapon/paper/P = toppaper
		dat += "<a href='byond://?src=\ref[src];write=\ref[P]'>Write</A> <a href='byond://?src=\ref[src];remove=\ref[P]'>Remove</A> <a href='byond://?src=\ref[src];rename=\ref[P]'>Rename</A> - <a href='byond://?src=\ref[src];read=\ref[P]'>[P.name]</A><BR><HR>"

	for(var/obj/item/weapon/paper/P in src)
		if(P==toppaper)
			continue
		dat += "<a href='byond://?src=\ref[src];remove=\ref[P]'>Remove</A> <a href='byond://?src=\ref[src];rename=\ref[P]'>Rename</A> - <a href='byond://?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/weapon/photo/Ph in src)
		dat += "<a href='byond://?src=\ref[src];remove=\ref[Ph]'>Remove</A> <a href='byond://?src=\ref[src];rename=\ref[Ph]'>Rename</A> - <a href='byond://?src=\ref[src];look=\ref[Ph]'>[Ph.name]</A><BR>"

	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	add_fingerprint(usr)
	return

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(src.loc == usr)

		if(href_list["pen"])
			if(istype(haspen) && (haspen.loc == src))
				haspen.loc = usr.loc
				usr.put_in_hands(haspen)
				haspen = null

		else if(href_list["addpen"])
			if(!haspen)
				var/obj/item/weapon/pen/W = usr.get_active_hand()
				if(istype(W, /obj/item/weapon/pen))
					usr.drop_item()
					W.loc = src
					haspen = W
					to_chat(usr, "<span class='notice'>You slot the pen into \the [src].</span>")

		else if(href_list["write"])
			var/obj/item/weapon/P = locate(href_list["write"])

			if(P && (P.loc == src) && istype(P, /obj/item/weapon/paper) && (P == toppaper) )

				var/obj/item/I = usr.get_active_hand()

				if(istype(I, /obj/item/weapon/pen))

					P.attackby(I, usr)

		else if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])

			if(P && (P.loc == src) && (istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/photo)) )

				P.loc = usr.loc
				usr.put_in_hands(P)
				if(P == toppaper)
					toppaper = null
					var/obj/item/weapon/paper/newtop = locate(/obj/item/weapon/paper) in src
					if(newtop && (newtop != P))
						toppaper = newtop
					else
						toppaper = null

		else if(href_list["rename"])
			var/obj/item/weapon/O = locate(href_list["rename"])

			if(O && (O.loc == src))
				if(istype(O, /obj/item/weapon/paper))
					var/obj/item/weapon/paper/to_rename = O
					to_rename.rename()

				else if(istype(O, /obj/item/weapon/photo))
					var/obj/item/weapon/photo/to_rename = O
					to_rename.rename()

		else if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])

			if(P && (P.loc == src) && istype(P, /obj/item/weapon/paper) )

				if(!(istype(usr, /mob/living/carbon/human) || isghost(usr) || istype(usr, /mob/living/silicon)))
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")

		else if(href_list["look"])
			var/obj/item/weapon/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P, /obj/item/weapon/photo) )
				P.show(usr)

		else if(href_list["top"]) // currently unused
			var/obj/item/P = locate(href_list["top"])
			if(P && (P.loc == src) && istype(P, /obj/item/weapon/paper) )
				toppaper = P
				to_chat(usr, "<span class='notice'>You move [P.name] to the top.</span>")

		//Update everything
		attack_self(usr)
		update_icon()
	return
