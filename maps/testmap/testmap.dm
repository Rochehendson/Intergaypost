#if !defined(using_map_DATUM)

	#include "../shared/exodus_torch/_include.dm"

	#include "testmap_announcements.dm"
	#include "testmap_areas.dm"


	//CONTENT
	#include "../shared/job/jobs.dm"
	#include "../shared/datums/uniforms.dm"
	#include "../shared/items/cards_ids.dm"
	#include "../shared/items/clothing.dm"
	#include "testmap_gamemodes.dm"
	#include "testmap_presets.dm"
	#include "testmap_shuttles.dm"
	#include "testmap_elevator.dm"

	#include "testmap-1.dmm"
	#include "testmap-2.dmm"
	#include "testmap-3.dmm"
	#include "testmap-4.dmm"
	#include "testmap-5.dmm"

	#include "../../code/modules/lobby_music/generic_songs.dm"

	#include "../away/mining/mining.dm"
	#include "../away/testmap/testmap.dm"
	#include "../away/bearcat/bearcat.dm"
	#include "../away/lost_supply_base/lost_supply_base.dm"
	#include "../away/marooned/marooned.dm"
	#include "../away/smugglers/smugglers.dm"
	#include "../away/magshield/magshield.dm"
	#include "../away/casino/casino.dm"
	#include "../away/yacht/yacht.dm"
	#include "../away/blueriver/blueriver.dm"
	#include "../away/slavers/slavers_base.dm"
	#include "../away/hydro/hydro.dm"
	#include "../away/mobius_rift/mobius_rift.dm"
	#include "../away/icarus/icarus.dm"
	#include "../away/errant_pisces/errant_pisces.dm"

	#define using_map_DATUM /datum/map/testmap

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring testmap
#endif
