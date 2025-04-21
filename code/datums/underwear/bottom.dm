/datum/category_item/underwear/bottom
	underwear_gender = PLURAL
	underwear_name = "underwear"
	underwear_type = /obj/item/underwear/bottom

/datum/category_item/underwear/bottom/none
	name = "None"
	always_last = TRUE
	underwear_type = null

/datum/category_item/underwear/bottom/briefs
	name = "Briefs"
	underwear_name = "briefs"
	icon_state = "briefs"
	has_color = TRUE

/datum/category_item/underwear/bottom/briefs/is_default(var/gender)
	return gender != FEMALE

/datum/category_item/underwear/bottom/panties
	name = "Panties"
	underwear_name = "panties"
	icon_state = "panties"
	has_color = TRUE
	underwear_gender = FEMALE

/datum/category_item/underwear/bottom/panties/is_default(var/gender)
	return gender == FEMALE