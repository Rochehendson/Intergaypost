/datum/crafting_recipe/furniture
	category = "Furniture"
	time = 80
	tools = list(/obj/item/weapon/screwdriver = 1)
	parts = list(MATERIAL_STEEL_TYPE = 5)
	result = null
	int_required = 11

/datum/crafting_recipe/furniture/chair
	name = "Chair"
	parts = list(MATERIAL_STEEL_TYPE = 3)
	result = list(/obj/structure/bed/chair = 1)

/datum/crafting_recipe/furniture/bed
	name = "Bed"
	parts = list(MATERIAL_STEEL_TYPE = 5)
	result = list(/obj/structure/bed = 1)

/datum/crafting_recipe/furniture/bar_stool
	name = "Bar Stool"
	parts = list(MATERIAL_STEEL_TYPE = 1)
	result = list(/obj/item/weapon/stool/bar  = 1)
	time = 20

/datum/crafting_recipe/furniture/table_frame
	name = "Table Frame"
	parts = list(/obj/item/stack/rods = 2)
	result = list(/obj/structure/table = 1)
	time = 20

/datum/crafting_recipe/furniture/rack
	name = "rack"
	result = list(/obj/structure/table/rack = 1)
	parts = list(MATERIAL_STEEL_TYPE = 2)

/datum/crafting_recipe/furniture/shelf
	name = "shelf"
	result = list(/obj/structure/table/rack/shelf = 1)
	parts = list(MATERIAL_STEEL_TYPE = 2)

/datum/crafting_recipe/furniture/closet
	name = "closet"
	result = list(/obj/structure/closet = 1)
	parts = list(MATERIAL_STEEL_TYPE = 4)

/datum/crafting_recipe/furniture/crate/plasteel
	name = "Metal crate"
	result = list(/obj/structure/closet/crate = 1)
	parts = list(MATERIAL_PLASTEEL_TYPE = 10)

/datum/crafting_recipe/furniture/crate/plastic
	name = "plastic crate"
	result = list(/obj/structure/closet/crate/plastic = 1)
	parts = list(MATERIAL_PLASTIC_TYPE = 10)

/datum/crafting_recipe/furniture/bookshelf
	name = "book shelf"
	result = list(/obj/structure/bookcase = 1)
	parts = list(MATERIAL_WOOD_TYPE  = 10)

/datum/crafting_recipe/furniture/coffin
	name = "coffin"
	result = list(/obj/structure/closet/coffin = 1)
	parts = list(MATERIAL_WOOD_TYPE  = 10)

/datum/crafting_recipe/furniture/bed
	name = "bed"
	result = list(/obj/structure/bed = 1)
	parts = list(MATERIAL_STEEL_TYPE = 10)

/datum/crafting_recipe/furniture/stool
	name = "stool"
	result = list(/obj/item/weapon/stool = 1)
	time = 30
	parts = list(MATERIAL_STEEL_TYPE = 1)

//Common chairs
/datum/crafting_recipe/furniture/chair
	name = "chair"
	result = list(/obj/structure/bed/chair = 1)

// Office chairs
/datum/crafting_recipe/furniture/office_chair
	name = "dark office chair"
	result = list(/obj/structure/bed/chair/office/dark = 1)
	parts = list(MATERIAL_STEEL_TYPE = 5)

/datum/crafting_recipe/furniture/office_chair/light
	name = "light office chair"
	result = list(/obj/structure/bed/chair/office/light = 1)
	parts = list(MATERIAL_STEEL_TYPE = 5)

// Wheelchairs
/datum/crafting_recipe/furniture/wheelchair
	name = "wheelchair"
	result = list(/obj/structure/bed/chair/wheelchair = 1)
	parts = list(MATERIAL_STEEL_TYPE = 15)