/mob/observer/ghost/Logout()
	..()
	remove_client_color(/datum/client_color/noir)
	clear_fullscreen("deathscreen")
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)