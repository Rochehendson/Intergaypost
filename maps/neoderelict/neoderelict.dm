#if !defined(using_map_DATUM)

	#include "neoderelict_announcements.dm"
	#include "neoderelict_areas.dm"


	//CONTENT
	#include "neoderelict_gamemodes.dm"
	#include "neoderelict_presets.dm"
	#include "neoderelict_shuttles.dm"

	#include "neoderelict-1.dmm"
	#include "neoderelict-2.dmm"
	#include "neoderelict-3.dmm"
	#include "neoderelict-4.dmm"
	#include "neoderelict-5.dmm"

	//#include "job/jobs.dm"
	#include "../shared/job/jobs.dm"

	#include "../../code/modules/lobby_music/generic_songs.dm"

	#define using_map_DATUM /datum/map/neoderelict

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring neoderelict
#endif
