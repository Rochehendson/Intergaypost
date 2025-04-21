/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0	//off or on.
	matter = list(DEFAULT_WALL_MATERIAL = 100)

/obj/item/weapon/hand_labeler/attack(atom/target, mob/living/user, target_zone, animate)
	if (label)
		target.AddLabel(label, user)
		return TRUE

/obj/item/weapon/hand_labeler/attack_self(mob/living/user)
	if (label)
		to_chat(user, "<span class='info'>You turn off \the [src].</span>")
		label = null
		update_icon()
	else
		var/response = input(user, "Label Text:") as null | text
		if (!response)
			return
		response = sanitizeSafe(response, MAX_LNAME_LEN)
		if (!length(response))
			to_chat(user, "<span class = 'warning'>Invalid Label.</span>")
			return
		label = response
		to_chat(user, "<span class='info'>You turn \the [src] on and set its text to \"[label]\".</span>")