/*#####SHIT AND PISS#####
##Ok there's a lot of stupid shit here. Literally, but let me explain a bit why I put this here.
##I feel like poo and pee add a degree of autistic realism that you wouldn't otherwise get. And I'm autistic about that kind of thing.
##This file contains all the reagents, decals, objects and life procs. These procs are used in human/life.dm and human/emote.dm
##Have some shitty fun. - Matt
*/

//####DEFINES####

/mob
	var/bladder = 0
	var/bowels = 0

//#####DECALS#####
/obj/effect/decal/cleanable/poo
	name = "poo stain"
	desc = "Well that stinks."
	density = 0
	anchored = 1
	icon = 'icons/effects/pooeffect.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "floor8")
	var/dried = 0
	persistent = TRUE


/obj/effect/decal/cleanable/poo/New()
	icon = 'icons/effects/pooeffect.dmi'
	icon_state = pick(src.random_icon_states)
	..()
	for(var/obj/effect/decal/cleanable/poo/shit in src.loc)
		if(shit != src)
			qdel(shit)
	spawn(6000)
		dried = 1
		name = "dried poo stain"
		desc = "It's a dried poo stain..."


/obj/effect/decal/cleanable/poo/tracks
	icon_state = "tracks"
	random_icon_states = null

/obj/effect/decal/cleanable/poo/drip
	name = "drips of poo"
	desc = "It's brown."
	density = 0
	anchored = 1
	icon = 'icons/effects/pooeffect.dmi'
	icon_state = "drip1"
	random_icon_states = list("drip1", "drip2", "drip3", "drip4", "drip5")

/obj/effect/decal/cleanable/poo/Crossed(AM as mob|obj, var/forceslip = 0)
	if (istype(AM, /mob/living/carbon) && src.dried == 0)
		var/mob/living/carbon/M = AM
		if (M.m_intent == "walk")
			return

		if(prob(5))
			M.slip("poo")

//These aren't needed for now.
///obj/effect/decal/cleanable/poo/tracks/Crossed(AM as mob|obj)
//	return

//obj/effect/decal/cleanable/poo/drip/Crossed(AM as mob|obj)
//	return

/obj/effect/decal/cleanable/urine
	name = "urine stain"
	desc = "Someone couldn't hold it.."
	density = 0
	anchored = 1
	icon = 'icons/effects/pooeffect.dmi'
	icon_state = "pee1"
	random_icon_states = list("pee1", "pee2", "pee3")
	var/dried = 0
	reagents = null

/obj/effect/decal/cleanable/urine/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M =	AM
		if ((ishuman(M) && istype(M:shoes, /obj/item/clothing/shoes/galoshes)) || M.m_intent == "walk")
			return

		if((!dried) && prob(5))
			M.slip("urine")

/obj/effect/decal/cleanable/urine/New()
	var/datum/reagents/R = new/datum/reagents(30, GLOB.temp_reagents_holder)
	reagents = R
	..()
	icon_state = pick(random_icon_states)
	reagents.add_reagent(/datum/reagent/urine,20)
	for(var/obj/effect/decal/cleanable/urine/piss in src.loc)
		if(piss != src)
			qdel(piss)

	spawn(800)
		dried = 1
		name = "dried urine stain"
		desc = "That's a dried crusty urine stain. Fucking janitors."

//#####BOTTLES#####

//PISS
/obj/item/weapon/reagent_containers/glass/bottle/urine
	name = "urine bottle"
	desc = "A small bottle. Contains urine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

	New()
		..()
		reagents.add_reagent(/datum/reagent/urine, 30)


//#####LIFE PROCS#####
/*
//poo and pee counters. This is called in human/handle_stomach.
/mob/living/carbon/human/proc/handle_excrement()
	if(bowels <= 0)
		bowels = 0
	if(bladder <= 0)
		bladder = 0

	if(has_quirk(/datum/quirk/no_bathroom))//You'll never have to use the restroom now.
		bladder = 0
		bowels = 0

	if(bowels >= 250)
		switch(bowels)
			if(250 to 400)
				if(prob(25))
					to_chat(src, "<b>You need to use the bathroom.</b>")
					bowels += 15
			if(400 to 450)
				if(prob(35))
					to_chat(src, "<span class='danger'>You really need to use the restroom!</span>")
					bowels += 15
			if(450 to 500)
				if(prob(2))
					handle_shit()
				else if(prob(45))
					to_chat(src, "<span class='danger'>You're about to shit yourself!</span>")
					bowels += 25
			if(500 to 550)
				if(prob(15))
					handle_shit()
				else if(prob(60))
					to_chat(src, "<span class='danger'>OH MY GOD YOU HAVE TO SHIT!</span>")
					bowels += 35
			if(550 to INFINITY)
				handle_shit()

	if(bladder >= 100)//Your bladder is smaller than your colon
		switch(bladder)
			if(100 to 250)
				if(prob(25))
					to_chat(src, "<b>You need to use the bathroom.</b>")
					bladder += 15
			if(250 to 400)
				if(prob(25))
					to_chat(src, "<span class='danger'>You really need to use the restroom!</span>")
					bladder += 15
			if(400 to 500)
				if(prob(45))
					handle_piss()
				else if(prob(10))
					to_chat(src, "<span class='danger'>You're about to piss yourself!</span>")
					bladder += 25
			if(500 to 550)
				if(prob(60))
					handle_piss()
				else if(prob(30))
					to_chat(src, "<span class='danger'>OH MY GOD YOU HAVE TO PEE!</span>")
					bladder += 35
			if(550 to INFINITY)
				handle_piss()

//Shitting
/mob/living/carbon/human/proc/handle_shit()
	var/message = null
	if (src.bowels >= 30)

		//Poo in the loo.
		var/obj/structure/hygiene/toilet/T = locate() in src.loc
		var/mob/living/M = locate() in src.loc
		if(T && T.open && M.buckled)
			message = "<B>[src]</B> defecates into \the [T]."

		else if(w_uniform)
			message = "<B>[src]</B> shits \his pants."
			var/obj/item/weapon/reagent_containers/food/snacks/poo/V = new/obj/item/weapon/reagent_containers/food/snacks/poo(src.loc)
			if(reagents)
				reagents.trans_to(V, rand(1,5))
			adjust_hygiene(-25)
			add_event("shitself", /datum/happiness_event/hygiene/shit)

		//Poo on the face.
		else if(M != src && M.lying)//Can only shit on them if they're lying down.
			message = "<span class='danger'><b>[src]</b> shits right on <b>[M]</b>'s face!</span>"
			M.reagents.add_reagent(/datum/reagent/poo, 10)

		//Poo on the floor.
		else
			message = "<B>[src]</B> [pick("shits", "craps", "poops")]."
			var/obj/item/weapon/reagent_containers/food/snacks/poo/V = new/obj/item/weapon/reagent_containers/food/snacks/poo(src.loc)
			if(reagents)
				reagents.trans_to(V, rand(1,5))

		playsound(src.loc, 'sound/effects/poo2.ogg', 60, 1)
		bowels -= rand(60,80)
		GLOB.shit_left++
	else
		to_chat(src, "You don't have to.")
		return

	visible_message("[message]")

//Peeing
/mob/living/carbon/human/proc/handle_piss()
	var/message = null
	if (bladder < 30)
		to_chat(src, "You don't have to.")
		return

	var/obj/structure/hygiene/urinal/U = locate() in src.loc
	var/obj/structure/hygiene/toilet/T = locate() in src.loc
	//var/obj/structure/toilet/T2 = locate() in src.loc
	var/obj/structure/hygiene/sink/S = locate() in src.loc
	var/obj/item/weapon/reagent_containers/RC = locate() in src.loc
	if((U || S) && gender != FEMALE)//In the urinal or sink.
		message = "<B>[src]</B> urinates into [U ? U : S]."
		reagents.remove_any(rand(1,8))

	else if(T && T.open)//In the toilet.
		message = "<B>[src]</B> urinates into [T]."
		reagents.remove_any(rand(1,8))

	else if(RC && (istype(RC,/obj/item/weapon/reagent_containers/food/drinks || istype(RC,/obj/item/weapon/reagent_containers/glass))))
		if(RC.is_open_container())
			//Inside a beaker, glass, drink, etc.
			message = "<B>[src]</B> urinates into [RC]."
			var/amount = rand(1,8)
			RC.reagents.add_reagent(/datum/reagent/urine, amount)
			if(reagents)
				reagents.trans_to(RC, amount)

	else if(w_uniform)//In your pants.
		message = "<B>[src]</B> pisses \his pants."
		adjust_hygiene(-25)
		add_event("pissedself", /datum/happiness_event/hygiene/pee)

	else//On the floor.
		var/turf/TT = src.loc
		var/obj/effect/decal/cleanable/urine/D = new/obj/effect/decal/cleanable/urine(src.loc)
		if(reagents)
			reagents.trans_to(D, rand(1,8))
		message = "<B>[src]</B> pisses on the [TT.name]."
	GLOB.piss_left++
	src.bladder -= 50
	visible_message("[message]")
*/