//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	width = 2
	appearance_flags = TILE_BOUND

/obj/machinery/door/airlock/multi_tile/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Door2x1glass.dmi'
	opacity = 0
	glass = 1
	assembly_type = /obj/structure/door_assembly/multi_tile

	open_sound_powered = 'sound/machines/maint_open.ogg'
	close_sound_powered = 'sound/machines/maint_close.ogg'

/obj/machinery/door/airlock/multi_tile/metal
	name = "Metal Airlock"
	icon = 'icons/obj/doors/Door2x1metal.dmi'
	assembly_type = /obj/structure/door_assembly/multi_tile
	opacity = TRUE

	open_sound_powered = 'sound/machines/ndooropen.ogg'
	close_sound_powered = 'sound/machines/ndoorclose.ogg'

/obj/machinery/door/airlock/multi_tile/metal/handle_multidoor()
	if(!(width > 1)) return //Bubblewrap

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			T.set_opacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			T.set_opacity(opacity)

	if(dir in list(NORTH, SOUTH))
		bound_height = world.icon_size * width
	else if(dir in list(EAST, WEST))
		bound_width = world.icon_size * width

/obj/machinery/door/airlock/multi_tile/metal/proc/update_filler_turfs()

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) T.set_opacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) T.set_opacity(opacity)

/obj/machinery/door/airlock/multi_tile/metal/proc/get_filler_turfs()
	var/list/filler_turfs = list()
	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) filler_turfs += T
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) filler_turfs += T
	return filler_turfs

/obj/machinery/door/airlock/multi_tile/metal/open()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/metal/close()
	. = ..()
	update_filler_turfs()
