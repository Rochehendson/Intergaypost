GLOBAL_VAR_INIT (waterchip_installed,0)

/obj/item/device/waterchip
	name = "water chip"
	desc = "This neat thing provides water to the entire station if installed properly."
	icon_state = "chip"
	icon = 'icons/obj/waterchip.dmi'
	force = 1
	w_class = 3
	slot_flags = SLOT_HEAD | SLOT_MASK
	matter = list("steel" = 5000)

/obj/machinery/waterchip_holder
	name = "water chip holder"
	desc = "This is where you hold the water chip. It provides water. Hold it."
	density = 1
	anchored = 1
	icon = 'icons/obj/waterchip.dmi'
	icon_state = "holder1"

	// Power
	idle_power_usage = 10
	active_power_usage = 40 KILOWATTS

/obj/machinery/waterchip_holder/attackby(obj/item/G as obj, mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return

	if (istype(G, /obj/item/device/waterchip))
		to_chat("You install the chip.")
		qdel(G)
		GLOB.waterchip_installed = 1
		update_icon()
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
	if(GLOB.waterchip_installed)
		to_chat("There's already a water chip here.")
		return

/obj/machinery/waterchip_holder/attack_hand(mob/user as mob)
	var/obj/item/device/waterchip/W

	if(istype(user,/mob/living/silicon))
		return

	..()

	if(GLOB.waterchip_installed)
		user.put_in_hands(W)
		GLOB.waterchip_installed = 0
		update_icon()
		to_chat("You uninstall the chip.")
	else
		to_chat("There is nothing here!")

/obj/machinery/waterchip_holder/update_icon()
	if(GLOB.waterchip_installed)
		icon_state = "holder2"
	else
		icon_state = "holder1"