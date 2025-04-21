/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "Gross. This is hard to stomach."
	icon_state = "stomach"
	dead_icon = "stomach"
	organ_tag = BP_STOMACH
	parent_organ = BP_GROIN
	var/stomach_capacity
	var/datum/reagents/metabolism/ingested
	var/next_cramp = 0
	var/functioning = TRUE
	var/functioning_set = FALSE

/obj/item/organ/internal/stomach/Destroy()
	QDEL_NULL(ingested)
	. = ..()

/obj/item/organ/internal/stomach/New()
	..()
	ingested = new/datum/reagents/metabolism(240, owner, CHEM_INGEST)
	if(!ingested.my_atom)
		ingested.my_atom = src

/obj/item/organ/internal/stomach/removed()
	. = ..()
	ingested.my_atom = src
	ingested.parent = null

/obj/item/organ/internal/stomach/replaced()
	. = ..()
	ingested.my_atom = owner
	ingested.parent = owner

/obj/item/organ/internal/stomach/proc/can_eat_atom(var/atom/movable/food)
	return !isnull(get_devour_time(food))

/obj/item/organ/internal/stomach/proc/is_full(var/atom/movable/food)
	var/total = Floor(ingested.total_volume / 10)
	for(var/a in contents + food)
		if(ismob(a))
			var/mob/M = a
			total += M.mob_size
		else if(isobj(a))
			var/obj/item/I = a
			total += I.get_storage_cost()
		else
			continue
		if(total > species.stomach_capacity)
			return TRUE
	return FALSE

/obj/item/organ/internal/stomach/proc/get_devour_time(var/atom/movable/food)
	if(iscarbon(food) || isanimal(food))
		var/mob/living/L = food
		if((species.gluttonous & GLUT_TINY) && (L.mob_size <= MOB_TINY) && !ishuman(food)) // Anything MOB_TINY or smaller
			return DEVOUR_SLOW
		else if((species.gluttonous & GLUT_SMALLER) && owner.mob_size > L.mob_size) // Anything we're larger than
			return DEVOUR_SLOW
		else if(species.gluttonous & GLUT_ANYTHING) // Eat anything ever
			return DEVOUR_FAST
	else if(istype(food, /obj/item) && !istype(food, /obj/item/weapon/holder)) //Don't eat holders. They are special.
		var/obj/item/I = food
		var/cost = I.get_storage_cost()
		if(cost != ITEM_SIZE_NO_CONTAINER)
			if((species.gluttonous & GLUT_ITEM_TINY) && cost < 4)
				return DEVOUR_SLOW
			else if((species.gluttonous & GLUT_ITEM_NORMAL) && cost <= 4)
				return DEVOUR_SLOW
			else if(species.gluttonous & GLUT_ITEM_ANYTHING)
				return DEVOUR_FAST

/mob/living/proc/get_digestion_product()
	return null

/obj/item/organ/internal/stomach/return_air()
	return null

// This call needs to be split out to make sure that all the ingested things are metabolised
// before the process call is made on any of the other organs
/obj/item/organ/internal/stomach/proc/metabolize()
	if(is_usable())
		ingested.metabolize()

// This makes sure that the ingested metabolism call and the Process() call both have the
// same value for is_usable() due to the probability involved
/obj/item/organ/internal/stomach/is_usable()
	if(functioning_set)
		return functioning

	functioning_set = TRUE
	functioning = ..()

	if(damage >= min_bruised_damage && prob((damage / max_damage) * 100))
		functioning = FALSE

	return functioning

#define STOMACH_VOLUME 65

/obj/item/organ/internal/stomach/Process(var/mob/living/carbon/human/H)

	..()

	if(owner)
		if(is_usable())
			for(var/mob/living/M in contents)
				if(M.stat == DEAD)
					qdel(M)
					continue

				M.adjustBruteLoss(3)
				M.adjustFireLoss(3)
				M.adjustToxLoss(3)

				var/digestion_product = M.get_digestion_product()
				if(digestion_product)
					ingested.add_reagent(digestion_product, rand(1,3))

		else if(world.time >= next_cramp)
			next_cramp = world.time + rand(200,800)
			owner.custom_pain("Your stomach cramps agonizingly!",1)

		var/alcohol_threshold_met = (ingested.get_reagent_amount(/datum/reagent/ethanol) > STOMACH_VOLUME / 2)
		if(alcohol_threshold_met && (owner.disabilities & EPILEPSY) && prob(20))
			owner.seizure()

		// Just over the limit, the probability will be low. It rises a lot such that at double ingested it's 64% chance.
		var/vomit_probability = (ingested.total_volume / STOMACH_VOLUME) ** 6

		// They need to have had more than their volume of reagent to vomit from it
		if((alcohol_threshold_met || ingested.total_volume > STOMACH_VOLUME) && prob(vomit_probability))
			owner.vomit()

		handle_hunger()
		handle_excrement()

	functioning_set = FALSE

/obj/item/organ/internal/stomach/proc/handle_hunger()
	owner.adjust_nutrition(-HUNGER_FACTOR)
	switch(owner.nutrition)
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			owner.add_event("hunger", /datum/happiness_event/nutrition/wellfed)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			owner.add_event("hunger", /datum/happiness_event/nutrition/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			owner.clear_event("hunger")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			owner.add_event("hunger", /datum/happiness_event/nutrition/hungry)
			if(prob(1))
				to_chat(owner, "<span class='warning'>I really need to eat something...</span>")
			else if(prob(1))
				to_chat(owner, "<span class='warning'>My stomach rumbles.</span>")
		if(0 to NUTRITION_LEVEL_STARVING)
			owner.add_event("hunger", /datum/happiness_event/nutrition/veryhungry)
			if(prob(2))
				to_chat(owner, "<span class='danger'><font size = 3>I faint from hunger.</span></font>")
				owner.Paralyse(3)
			else if(prob(3))
				to_chat(owner, "<span class='danger'><font size = 3>GIVE ME SOMETHING TO EAT!</span></font>")
				owner.Weaken(1)
				owner.Stun(1)
			if(prob(2))
				to_chat(owner, "<span class='danger'><font size = 3>There's no food...anywhere...</span></font>")
				take_internal_damage(1)

#define BLADDER_FACTOR 0.03
#define BOWEL_FACTOR 0.01
/obj/item/organ/internal/stomach/proc/handle_excrement()
	if(owner.has_quirk(/datum/quirk/no_bathroom))//You'll never have to use the restroom now.
		owner.bladder = 0
		owner.bowels = 0

	owner.adjust_shit(BOWEL_FACTOR)
	if(owner.bowels >= 250)
		switch(owner.bowels)
			if(250 to 400)
				to_chat(owner, "<b>You need to use the bathroom.</b>")
				if(prob(25))
					owner.bowels += 15
			if(400 to 450)
				to_chat(owner, "<span class='danger'>You really need to use the restroom!</span>")
				if(prob(35))
					owner.bowels += 15
			if(450 to 500)
				to_chat(owner, "<span class='danger'>You're about to shit yourself!</span>")
				if(prob(2))
					owner.handle_shit()
				else if(prob(45))
					owner.bowels += 25
			if(500 to 550)
				to_chat(owner, "<span class='danger'>OH MY GOD YOU HAVE TO SHIT!</span>")
				if(prob(15))
					owner.handle_shit()
				else if(prob(60))
					owner.bowels += 35
			if(550 to INFINITY)
				owner.handle_shit()

	owner.adjust_piss(BLADDER_FACTOR)
	if(owner.bladder >= 100)//Your bladder is smaller than your colon
		switch(owner.bladder)
			if(100 to 250)
				to_chat(owner, "<b>You need to use the bathroom.</b>")
				if(prob(25))
					owner.bladder += 15
			if(250 to 400)
				to_chat(owner, "<span class='danger'>You really need to use the restroom!</span>")
				if(prob(25))
					owner.bladder += 15
			if(400 to 500)
				to_chat(owner, "<span class='danger'>You're about to piss yourself!</span>")
				if(prob(25))
					owner.handle_piss()
				else if(prob(10))
					owner.bladder += 25
			if(500 to 550)
				to_chat(owner, "<span class='danger'>OH MY GOD YOU HAVE TO PEE!</span>")
				if(prob(60))
					owner.handle_piss()
				else if(prob(30))
					owner.bladder += 35
			if(550 to INFINITY)
				owner.handle_piss()

//Shitting
/mob/living/carbon/human/proc/handle_shit()
	var/message = null
	if (src.bowels >= 30)

		var/mob/living/carbon/human/H = usr

		//Poo in the loo.
		var/obj/structure/hygiene/toilet/T = locate() in src.loc
		var/obj/item/weapon/reagent_containers/RC = locate() in src.loc
		var/mob/living/M = locate() in src.loc
		if(T && T.open) //&& M.buckled removed until buckling is actually fixed
			message = "<B>[H]</B><span class='hygiene'> defecates into \the [T].</span>"

		else if(w_uniform)
			message = "<B>[H]</B><span class='hygiene'> shits \his pants.</span>"
			var/obj/item/weapon/reagent_containers/food/snacks/poo/V = new/obj/item/weapon/reagent_containers/food/snacks/poo(src.loc)
			if(reagents)
				reagents.trans_to(V, rand(1,5))
			adjust_hygiene(-25)
			add_event("shitself", /datum/happiness_event/hygiene/shit)
			unlock_achievement(new/datum/achievement/shit_pants())

		//Poo on the face.
		else if(M != src && M.lying)//Can only shit on them if they're lying down.
			message = "<span class='combatbold'>[H]</span><span class='hygiene'> shits right on </span><span class='combatbold'>[M]'s</span><span class='hygiene'> face!</span>"
			M.reagents.add_reagent(/datum/reagent/poo, 10)
			M.unlock_achievement(new/datum/achievement/shit_on())

		//Poo in the food.
		else if(RC && (istype(RC,/obj/item/weapon/reagent_containers/food/drinks || istype(RC,/obj/item/weapon/reagent_containers/glass))))
			if(RC.is_open_container())
				//Inside a beaker, glass, drink, etc.
				message = "<B>[H]</B><span class='hygiene'> shits in \the [RC].</span>"
				var/amount = rand(4,12)
				RC.reagents.add_reagent(/datum/reagent/poo, amount)
				if(reagents)
					reagents.trans_to(RC, amount)

		//Poo on the floor.
		else
			message = "<B>[H]</B> [pick("shits", "craps", "poops")]."
			var/obj/item/weapon/reagent_containers/food/snacks/poo/V = new/obj/item/weapon/reagent_containers/food/snacks/poo(src.loc)
			if(reagents)
				reagents.trans_to(V, rand(1,5))

		playsound(src.loc, 'sound/effects/poo2.ogg', 60, 1)
		bowels -= rand(60,80)
		GLOB.shit_left++
	else
		to_chat(src, "<span class='hygiene'>I don't have to.</span>")
		return

	visible_message("[message]")

//Peeing
/mob/living/carbon/human/proc/handle_piss()
	var/message = null
	if (bladder < 30)
		to_chat(src, "<span class='hygiene'>I don't have to.</span>")
		return

	var/mob/living/carbon/human/H = usr

	var/obj/structure/hygiene/urinal/U = locate() in src.loc
	var/obj/structure/hygiene/toilet/TT = locate() in src.loc
	//var/obj/structure/toilet/T2 = locate() in src.loc
	var/obj/structure/hygiene/sink/S = locate() in src.loc
	var/obj/item/weapon/reagent_containers/RC = locate() in src.loc
	if((U || S) && gender != FEMALE)//In the urinal or sink.
		message = "<B>[H]</B><span class='hygiene'> urinates into [U ? U : S].</span>"
		reagents.remove_any(rand(1,8))

	else if(TT && TT.open)//In the toilet.
		message = "<B>[H]</B><span class='hygiene'> urinates into [TT].</span>"
		reagents.remove_any(rand(1,8))

	else if(RC && (istype(RC,/obj/item/weapon/reagent_containers/food/drinks || istype(RC,/obj/item/weapon/reagent_containers/glass))))
		if(RC.is_open_container())
			//Inside a beaker, glass, drink, etc.
			message = "<B>[H]</B><span class='hygiene'> urinates into [RC].</span>"
			var/amount = rand(1,8)
			RC.reagents.add_reagent(/datum/reagent/urine, amount)
			if(reagents)
				reagents.trans_to(RC, amount)

	else if(w_uniform)//In your pants.
		message = "<B>[H]</B><span class='hygiene'> pisses \his pants.</span>"
		adjust_hygiene(-25)
		add_event("pissedself", /datum/happiness_event/hygiene/pee)
		unlock_achievement(new/datum/achievement/pissed())

	else//On the floor.
		var/mob/user = usr
		message = "<B>[H]</B><span class='hygiene'> pisses on the floor.</span>"
		for(var/thing in trange(1, get_turf(user)))
			var/turf/T = thing
			T.add_fluid_piss(1, /datum/reagent/urine)
	GLOB.piss_left++
	src.bladder -= 50
	visible_message("[message]")

/mob/living/carbon/proc/adjust_shit(var/amount)
	var/old_shit = bowels
	if(amount>0)
		bowels = min(bowels+amount, NUTRITION_LEVEL_FAT)

	else if(old_shit)
		bowels = max(bowels+amount, 0)

/mob/living/carbon/proc/set_shit(var/amount)
	if(amount >= 0)
		bowels = min(NUTRITION_LEVEL_FAT, amount)

/mob/living/carbon/proc/adjust_piss(var/amount)
	var/old_piss = bladder
	if(amount>0)
		bladder = min(bladder+amount, THIRST_LEVEL_MAX)

	else if(old_piss)
		bladder = max(bladder+amount, 0)

/mob/living/carbon/proc/set_piss(var/amount)
	if(amount >= 0)
		bladder = min(THIRST_LEVEL_MAX, amount)

#undef STOMACH_VOLUME