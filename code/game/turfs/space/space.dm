/turf/space
	plane = SPACE_PLANE
	icon = 'icons/turf/space.dmi'

	name = "\proper space"
	icon_state = "fake"
	dynamic_lighting = 0
	temperature = 193.0
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	var/static/list/dust_cache
	permit_ao = FALSE
	appearance_flags = TILE_BOUND | PIXEL_SCALE | TILE_MOVER
	var/dirt = 0
	has_coldbreath = FALSE

/turf/space/Initialize()
	. = ..()
	update_starlight()

	appearance = SSskybox.space_appearance_cache[(((x + y) ^ ~(x * y) + z) % 25) + 1]

	var/turf/space/S
	var/turf/T = S
	var/radiation_count = rand(45, 85)
	SSradiation.flat_radiate(T, radiation_count, 1, 1)

	if(!HasBelow(z))
		return
	var/turf/below = GetBelow(src)

	if(istype(below, /turf/space))
		return
	var/area/A = below.loc

	if(!below.density && (A.area_flags & AREA_FLAG_EXTERNAL))
		return

	return INITIALIZE_HINT_LATELOAD // oh no! we need to switch to being a different kind of turf!

/turf/space/Destroy()
	// Cleanup cached z_eventually_space values above us.
	if (above)
		var/turf/T = src
		while ((T = GetAbove(T)))
			T.z_eventually_space = FALSE
	return ..()

/turf/space/LateInitialize()
	// We alter area type before the turf to ensure the turf-change-event-propagation is handled as expected.
	if(GLOB.using_map.base_floor_area)
		var/area/new_area = locate(GLOB.using_map.base_floor_area) || new GLOB.using_map.base_floor_area
		new_area.contents.Add(src)
	ChangeTurf(GLOB.using_map.base_floor_type)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		O.hide(0)

/turf/space/is_solid_structure()
	return locate(/obj/structure/lattice, src) //counts as solid structure if it has a lattice

/turf/space/proc/update_starlight()
	if(!config.starlight)
		return
	if(locate(/turf/simulated) in orange(src,1))
		set_light(config.starlight)
	else
		set_light(0)

/turf/space/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return L.attackby(C, user)
		var/obj/item/stack/rods/R = C
		if (R.use(1))
			to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		return

	if (istype(C, /obj/item/stack/tile/floor))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/floor/S = C
			if (S.get_amount() < 1)
				return
			qdel(L)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			S.use(1)
			ChangeTurf(/turf/simulated/floor/airless, keep_air = TRUE)
			return
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if(A && A.loc == src)
		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "mercenary")	return
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE + 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE + 1))
			A.touch_map_edge()

/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	var/cur_x
	var/cur_y
	var/next_x
	var/next_y
	var/target_z
	var/list/y_arr

	if(src.x <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (--cur_x||GLOB.global_map.len)
		y_arr = GLOB.global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		log_debug("Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		log_debug("Target Z = [target_z]")
		log_debug("Next X = [next_x]")

		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > GLOB.global_map.len ? 1 : cur_x)
		y_arr = GLOB.global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		log_debug("Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		log_debug("Target Z = [target_z]")
		log_debug("Next X = [next_x]")

		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = GLOB.global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		log_debug("Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		log_debug("Next Y = [next_y]")
		log_debug("Target Z = [target_z]")

		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

	else if (src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = GLOB.global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		log_debug("Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		log_debug("Next Y = [next_y]")
		log_debug("Target Z = [target_z]")

		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	return

/turf/space/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE, keep_air = FALSE)
	return ..(N, tell_universe, TRUE, keep_air)

//Bluespace turfs for shuttles and possible future transit use
/turf/space/bluespace
	name = "bluespace"
	icon_state = "bluespace"

/turf/space/is_open()
	return TRUE
