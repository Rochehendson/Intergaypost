/obj/structure/table/standard
	icon_state = "plain_preview"
	color = COLOR_OFF_WHITE
	material = DEFAULT_TABLE_MATERIAL
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/steel
	icon_state = "plain_preview"
	color = COLOR_GRAY40
	material = DEFAULT_WALL_MATERIAL
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/counter
	icon_state = "hardenedsteel_preview"
	color = null
	material = "hardened steel"

/obj/structure/table/reinftable3
	icon_state = "reinf_table3"
	color = null
	material = DEFAULT_WALL_MATERIAL

/obj/structure/table/reinftable3/can_connect()
	return 0

/obj/structure/table/marble
	icon_state = "stone_preview"
	color = COLOR_GRAY80
	material = "marble"

/obj/structure/table/reinforced
	icon_state = "reinf_preview"
	color = COLOR_OFF_WHITE
	material = DEFAULT_TABLE_MATERIAL
	reinforced = DEFAULT_WALL_MATERIAL

/obj/structure/table/steel_reinforced
	icon_state = "reinf_preview"
	color = COLOR_GRAY40
	material = DEFAULT_WALL_MATERIAL
	reinforced = DEFAULT_WALL_MATERIAL

/obj/structure/table/woodentable
	icon_state = "solid_preview"
	color = COLOR_BROWN_ORANGE
	material = "wood"
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/gamblingtable
	icon_state = "gamble_preview"
	carpeted = 1
	material = "wood"
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/glass
	icon_state = "glass_preview"
	material = "glass"
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/glass/pglass
	color = "#8f29a3"
	material = "phglass"
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/holotable
	icon_state = "holo_preview"
	color = COLOR_OFF_WHITE
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/table/holotable/New()
	material = "holo[DEFAULT_TABLE_MATERIAL]"
	..()

/obj/structure/table/holo_woodentable
	icon_state = "holo_preview"
	material = "holowood"
	atom_flags = ATOM_FLAG_CLIMBABLE
