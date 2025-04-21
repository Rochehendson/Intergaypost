/* Surgery Tools
 * Contains:
 *		Retractor
 *		Hemostat
 *		Cautery
 *		Surgical Drill
 *		Scalpel
 *		Circular Saw
 */

/*
 * Retractor
 */

/obj/item/weapon/surgery_tool
	var/operation_sound
	var/operation_sound_fail

/obj/item/weapon/surgery_tool/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	matter = list(DEFAULT_WALL_MATERIAL = 10000, "glass" = 5000)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	operation_sound = 'sound/effects/retractor.ogg'

/*
 * Hemostat
 */
/obj/item/weapon/surgery_tool/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	matter = list(DEFAULT_WALL_MATERIAL = 5000, "glass" = 2500)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("attacked", "pinched")
	operation_sound = 'sound/effects/hemostat.ogg'

/*
 * Cautery
 */
/obj/item/weapon/surgery_tool/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	matter = list(DEFAULT_WALL_MATERIAL = 5000, "glass" = 2500)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("burnt")
	operation_sound = 'sound/effects/cautery.ogg'

/*
 * Surgical Drill
 */
/obj/item/weapon/surgery_tool/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	matter = list(DEFAULT_WALL_MATERIAL = 15000, "glass" = 10000)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 15.0
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("drilled")
	operation_sound = 'sound/effects/surgicaldrill.ogg'

/*
 * Scalpel
 */
/obj/item/weapon/surgery_tool/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 10.0
	sharp = 1
	sharpness = 25
	//edge = 1 //WHY THE FUCK DOES THIS HAVE EDGE YOU'RE NOT GOING TO CUT SOMEONE'S HEAD OFF WITH A SCALPEL
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	hitsound = 'sound/weapons/bladeslice.ogg'
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	matter = list(DEFAULT_WALL_MATERIAL = 10000, "glass" = 5000)
	attack_verb = list("slashed", "stabbed")
	operation_sound = 'sound/effects/scalpel.ogg'

/*
 * Researchable Scalpels
 */
/obj/item/weapon/surgery_tool/scalpel/laser1
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"

/obj/item/weapon/surgery_tool/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0

/obj/item/weapon/surgery_tool/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	damtype = "fire"
	force = 15.0

/obj/item/weapon/surgery_tool/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	force = 7.5

//A makeshift knife, for doing all manner of cutting and stabbing tasks in a half-assed manner
/obj/item/weapon/shiv
	icon = 'icons/obj/tools.dmi'
	name = "shiv"
	desc = "A pointy piece of glass, abraded to an edge and wrapped in tape for a handle."
	icon_state = "impro_shiv"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	drop_sound = 'sound/items/knife_drop.ogg'
	hitsound = 'sound/weapons/bladeslice.ogg'
	matter = list(MATERIAL_GLASS_TYPE = 1)
	sharp = TRUE
	edge = TRUE
	force = 7
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	//tool_qualities = list(QUALITY_CUTTING = 15, QUALITY_WIRE_CUTTING = 5, QUALITY_DRILLING = 10)
	//degradation = 4 //Gets worse with use

/*
 * Circular Saw
 */
/obj/item/weapon/surgery_tool/circular_saw
	name = "bone saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/bladeslice.ogg'
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 15.0
	w_class = ITEM_SIZE_NORMAL
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	sharpness = 25
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	matter = list(DEFAULT_WALL_MATERIAL = 20000,"glass" = 10000)
	attack_verb = list("slashed")
	sharp = 1
	edge = 1
	operation_sound = 'sound/effects/circular_saw.ogg'

//misc, formerly from code/defines/weapons.dm
/obj/item/weapon/surgery_tool/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0

/obj/item/weapon/surgery_tool/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 3)
	w_class = ITEM_SIZE_SMALL
	var/usage_amount = 10
	operation_sound = 'sound/items/suture.ogg'

/obj/item/weapon/surgery_tool/FixOVein/suture
	name = "suture"
	icon_state = "suture"

/obj/item/weapon/surgery_tool/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "hit", "bludgeoned")
	operation_sound = 'sound/items/bones.ogg'
	operation_sound_fail = 'sound/items/bone_crack.ogg'