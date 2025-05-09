//Fullscreen overlay resolution in tiles.
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

/mob
	var/list/screens = list()

/mob/proc/set_fullscreen(condition, screen_name, screen_type, arg)
	condition ? overlay_fullscreen(screen_name, screen_type, arg) : clear_fullscreen(screen_name)

/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/screen/fullscreen/screen = screens[category]

	if(screen)
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			screen = null
		else if(!severity || severity == screen.severity)
			return null

	if(!screen)
		screen = new type()

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity

	screens[category] = screen
	screen.transform = null
	if(screen && client)
		if(screen.screen_loc != ui_entire_screen)
			if(max(client.last_view_x_dim, client.last_view_y_dim) > 7)
				var/matrix/M = matrix()
				M.Scale(ceil(client.last_view_x_dim/7),ceil(client.last_view_y_dim/7))
				screen.transform = M
		if(stat != DEAD || screen.allstate)
			client.screen += screen
	return screen

/mob/proc/clear_fullscreen(category, animated = 10)
	var/obj/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screens -= category

	if(animated)
		spawn(0)
			animate(screen, alpha = 0, time = animated)
			sleep(animated)
			if(client)
				client.screen -= screen
			qdel(screen)
	else
		if(client)
			client.screen -= screen
		qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in screens)
			client.screen -= screens[category]

/mob/proc/reload_fullscreen()
	if(client)
		var/largest_bound = max(client.last_view_x_dim, client.last_view_y_dim)
		for(var/category in screens)
			var/obj/screen/fullscreen/screen = screens[category]
			screen.transform = null
			if(screen.screen_loc != ui_entire_screen && largest_bound > 7)
				var/matrix/M = matrix()
				M.Scale(ceil(client.last_view_x_dim/7), ceil(client.last_view_y_dim/7))
				screen.transform = M
			client.screen |= screen

/obj/screen/fullscreen
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	plane = FULLSCREEN_PLANE
	mouse_opacity = 0
	var/view = 7
	var/severity = 0
	var/allstate = 0 //shows if it should show up for dead people too

/obj/screen/fullscreen/Destroy()
	severity = 0
	return ..()

/obj/screen/fullscreen/proc/update_for_view(client_view)
	if (screen_loc == "CENTER-7,CENTER-7" && view != client_view)
		var/list/actualview = getviewsize(client_view)
		view = client_view
		transform = matrix(actualview[1]/FULLSCREEN_OVERLAY_RESOLUTION_X, 0, 0, 0, actualview[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y, 0)

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/obj/screen/fullscreen/dead
	icon_state = "deathscreen"
	layer = FULLSCREEN_LAYER

/obj/screen/fullscreen/blackout
	icon = 'icons/mob/screen1.dmi'
	icon_state = "black"
	screen_loc = ui_entire_screen
	layer = BLIND_LAYER

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = ui_entire_screen
	icon_state = "blurry"
	alpha = 100

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = ui_entire_screen
	icon_state = "flash"

/obj/screen/fullscreen/flash/noise
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = ui_entire_screen
	icon_state = "druggy"
	alpha = 127
	blend_mode = BLEND_MULTIPLY

/obj/screen/fullscreen/noise
	icon = 'icons/effects/static.dmi'
	icon_state = "1 light"
	screen_loc = ui_entire_screen
	layer = FULLSCREEN_LAYER
	alpha = 127

/obj/screen/fullscreen/fadeout
	icon = 'icons/mob/screen1.dmi'
	icon_state = "black"
	screen_loc = ui_entire_screen
	layer = FULLSCREEN_LAYER
	alpha = 0
	allstate = 1

/obj/screen/fullscreen/fadeout/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 10)

/obj/screen/fullscreen/scanline
	icon = 'icons/effects/static.dmi'
	icon_state = "scanlines"
	screen_loc = ui_entire_screen
	alpha = 50
	layer = FULLSCREEN_LAYER

/obj/screen/fullscreen/fishbed
	icon_state = "fishbed"
	allstate = 1

/obj/screen/fullscreen/pain
	icon_state = "brutedamageoverlay6"
	alpha = 0

/obj/screen/fullscreen/freakout
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "extreme"
	blend_mode = BLEND_MULTIPLY