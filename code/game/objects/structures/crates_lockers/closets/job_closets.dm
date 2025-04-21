/* Closets for specific jobs
 * Contains:
 *		Bartender
 *		Janitor
 *		Lawyer
 */

/*
 * Chef
 */
/obj/structure/closet/chefcloset
	name = "chef's closet"
	desc = "It's a storage unit for foodservice garments."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/chefcloset/WillContain()
	return list(
		/obj/item/weapon/storage/box/mousetraps = 2,
		/obj/item/clothing/head/chefhat
	)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/WillContain()
	return list(
		/obj/item/clothing/gloves/thick,
		/obj/item/clothing/head/beret/purple,
		/obj/item/device/flashlight,
		/obj/item/weapon/caution = 4,
		/obj/item/device/lightreplacer,
		/obj/item/weapon/storage/bag/trash,
		/obj/item/clothing/shoes/galoshes,
		/obj/item/weapon/soap/nanotrasen)

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/WillContain()
	return list(
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/lawyer/black,
		/obj/item/clothing/under/lawyer/red,
		/obj/item/clothing/under/lawyer/bluesuit,
		/obj/item/clothing/suit/storage/toggle/suit/blue,
		/obj/item/clothing/under/lawyer/purpsuit,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/black
	)
