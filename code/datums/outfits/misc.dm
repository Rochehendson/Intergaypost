/decl/hierarchy/outfit/standard_space_gear
	name = "Standard space gear"
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/space
	suit = /obj/item/clothing/suit/space
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/weapon/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath
	flags = OUTFIT_HAS_JETPACK|OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/merchant
	name = "Merchant"
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/color/grey
	id_slot = slot_wear_id
	id_type = /obj/item/weapon/card/id/merchant
	pda_slot = slot_r_store
	pda_type = /obj/item/device/pda/chef //cause I like the look
	id_pda_assignment = "Merchant"

/decl/hierarchy/outfit/clown
	name = "Clown"
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_ear =  /obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/rank/clown
	l_pocket = /obj/item/weapon/bikehorn
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/clown/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack] = /obj/item/weapon/storage/backpack/clown
