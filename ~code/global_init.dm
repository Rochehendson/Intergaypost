/*
	The initialization of the game happens roughly like this:
	1. All global variables are initialized (including the global_init instance$
	2. The map is initialized, and map objects are created.
	3. world/New() runs, creating the process scheduler (and the old master con$
	4. processScheduler/setup() runs, creating all the processes. game_controll$
	5. The gameticker is created.
*/


var/global_init = new /datum/global_init()

/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()
	load_configuration()
	callHook("global_init")
	qdel(src) //we're done

/datum/global_init/Destroy()
	global_init = null
	..()
	return QDEL_HINT_HARDDEL