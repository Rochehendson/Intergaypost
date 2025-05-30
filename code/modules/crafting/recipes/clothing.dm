/datum/crafting_recipe/clothing
	category = "Clothing"
	time = 50
	result = null
	int_required = 12

/datum/crafting_recipe/clothing/sandals
	name = "wooden sandals"
	result = list(/obj/item/clothing/shoes/sandal = 1)
	parts = list(MATERIAL_WOOD_TYPE  = 1)

/datum/crafting_recipe/clothing/armorvest
	name = "armor vest"
	result = list(/obj/item/clothing/suit/armor/vest/handmade = 1)
	parts = list(/obj/item/clothing/suit/storage/hazardvest = 1, /obj/item/stack/material/steel/ = 5, /obj/item/stack/cable_coil = 4)

/datum/crafting_recipe/clothing/combat_helmet
	name = "combat helmet"
	result = list(/obj/item/clothing/head/helmet/handmade = 1)
	parts = list(/obj/item/weapon/reagent_containers/glass/bucket = 1,  /obj/item/stack/material/steel/ = 2, /obj/item/stack/cable_coil = 2)