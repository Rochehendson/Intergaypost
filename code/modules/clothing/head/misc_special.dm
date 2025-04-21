/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	item_state_slots = list(
		slot_l_hand_str = "welding",
		slot_r_hand_str = "welding",
		)
	matter = list(DEFAULT_WALL_MATERIAL = 3000, "glass" = 1000)
	var/up = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	body_parts_covered = HEAD|FACE|EYES
	action_button_name = "Flip Welding Mask"
	siemens_coefficient = 0.9
	w_class = ITEM_SIZE_NORMAL
	var/base_state
	flash_protection = FLASH_PROTECTION_MAJOR
	tint = TINT_HEAVY

/obj/item/clothing/head/welding/attack_self()
	if(!base_state)
		base_state = icon_state
	toggle()


/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(src.up)
			src.up = !src.up
			body_parts_covered |= (EYES|FACE)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			flash_protection = initial(flash_protection)
			tint = initial(tint)
			icon_state = base_state
			item_state = base_state
			to_chat(usr, "You flip the [src] down to protect your eyes.")
		else
			src.up = !src.up
			body_parts_covered &= ~(EYES|FACE)
			flash_protection = FLASH_PROTECTION_NONE
			tint = TINT_NONE
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[base_state]up"
			item_state = "[base_state]up"
			to_chat(usr, "You push the [src] up out of your face.")
		update_clothing_icon()	//so our mob-overlays
		update_vision()
		usr.update_action_buttons()

/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	var/icon_state_up = "ushankaup"
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(icon_state == initial(icon_state))
		icon_state = icon_state_up
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		icon_state = initial(icon_state)
		to_chat(user, "You lower the ear flaps on the ushanka.")

/obj/item/clothing/head/richard
	name = "chicken mask"
	desc = "You can hear the distant sounds of rhythmic electronica."
	icon_state = "richard"
	body_parts_covered = HEAD|FACE
	flags_inv = BLOCKHAIR
