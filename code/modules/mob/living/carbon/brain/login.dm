/mob/living/carbon/brain/Login()
	..()
	sleeping = 0
	updatePig()
	src.overlay_fullscreen("deathscreen",/obj/screen/fullscreen/dead)
	updateButtons()