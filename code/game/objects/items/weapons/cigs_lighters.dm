//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

//For anything that can light stuff on fire
/obj/item/weapon/flame
	waterproof = FALSE
	var/lit = 0

/obj/item/weapon/flame/proc/extinguish(var/mob/user, var/no_message)
	lit = 0
	damtype = "brute"
	STOP_PROCESSING(SSobj, src)

/obj/item/weapon/flame/water_act(var/depth)
	..()
	if(!waterproof && lit)
		if(submerged(depth))
			extinguish(no_message = TRUE)

/proc/isflamesource(A)
	if(isWelder(A))
		var/obj/item/weapon/weldingtool/WT = A
		return (WT.isOn())
	else if(istype(A, /obj/item/weapon/flame))
		var/obj/item/weapon/flame/F = A
		return (F.lit)
	else if(istype(A, /obj/item/clothing/mask/smokable) && !istype(A, /obj/item/clothing/mask/smokable/pipe))
		var/obj/item/clothing/mask/smokable/S = A
		return (S.lit)
	else if(istype(A, /obj/item/device/assembly/igniter))
		return 1
	return 0

///////////
//MATCHES//
///////////
/obj/item/weapon/flame/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/burnt = 0
	var/smoketime = 5
	w_class = ITEM_SIZE_TINY
	origin_tech = list(TECH_MATERIAL = 1)
	slot_flags = SLOT_EARS
	attack_verb = list("burnt", "singed")

/obj/item/weapon/flame/match/Process()
	if(isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()
	var/turf/location = get_turf(src)
	smoketime--
	if(submerged() || smoketime < 1)
		extinguish()
		return
	if(location)
		location.hotspot_expose(700, 5)
		return

/obj/item/weapon/flame/match/dropped(var/mob/user)
	//If dropped, put ourselves out
	//not before lighting up the turf we land on, though.
	if(lit)
		spawn(0)
			var/turf/location = src.loc
			if(istype(location))
				location.hotspot_expose(700, 5)
			extinguish()
	return ..()

/obj/item/weapon/flame/match/extinguish(var/mob/user, var/no_message)
	. = ..()
	icon_state = "match_burnt"
	item_state = "cigoff"
	name = "burnt match"
	desc = "A match. This one has seen better days."
	burnt = 1

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/smokable
	name = "smokable item"
	desc = "You're not sure what this is. You should probably ahelp it."
	body_parts_covered = 0

	var/lit = 0
	var/icon_on
	var/type_butt = null
	var/chem_volume = 0
	var/smoketime = 0
	var/matchmes = "USER lights NAME with FLAME"
	var/lightermes = "USER lights NAME with FLAME"
	var/zippomes = "USER lights NAME with FLAME"
	var/weldermes = "USER lights NAME with FLAME"
	var/ignitermes = "USER lights NAME with FLAME"
	var/brand
	waterproof = FALSE

/obj/item/clothing/mask/smokable/New()
	..()
	atom_flags |= ATOM_FLAG_NO_REACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15

/obj/item/clothing/mask/smokable/Destroy()
	. = ..()
	if(lit)
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/proc/smoke(amount)
	smoketime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, REM, CHEM_INGEST, 0.2) // Most of it is not inhaled... balance reasons.
		else // else just remove some of the reagents
			reagents.remove_any(REM)

/obj/item/clothing/mask/smokable/Process()
	var/turf/location = get_turf(src)
	smoke(1)
	if(submerged() || smoketime < 1)
		extinguish()
		return
	if(location)
		location.hotspot_expose(700, 5)

/obj/item/clothing/mask/smokable/update_icon()
	if(lit && icon_on)
		icon_state = icon_on
		item_state = icon_on
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	if(ismob(loc))
		var/mob/living/M = loc
		M.update_inv_wear_mask(0)
		M.update_inv_l_hand(0)
		M.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/water_act(var/depth)
	..()
	if(!waterproof && lit)
		if(submerged(depth))
			extinguish(no_message = TRUE)

/obj/item/clothing/mask/smokable/proc/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		if(submerged())
			to_chat(usr, "<span class='warning'>You cannot light \the [src] underwater.</span>")
			return
		src.lit = 1
		damtype = "fire"
		if(reagents.get_reagent_amount(/datum/reagent/toxin/phoron)) // the phoron explodes when exposed to fire
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/phoron) / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			qdel(src)
			return
		if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
			e.start()
			qdel(src)
			return
		atom_flags &= ~ATOM_FLAG_NO_REACT // allowing reagents to react after being lit
		reagents.handle_reactions()
		update_icon()
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		set_light(0.6, 0.5, 2, 2, "#e38f46")
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/proc/extinguish(var/mob/user, var/no_message)
	lit = 0
	damtype = "brute"
	STOP_PROCESSING(SSobj, src)
	set_light(0)
	update_icon()

/obj/item/clothing/mask/smokable/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(isflamesource(W))
		var/text = matchmes
		if(istype(W, /obj/item/weapon/flame/match))
			text = matchmes
		else if(istype(W, /obj/item/weapon/flame/lighter/zippo))
			text = zippomes
		else if(istype(W, /obj/item/weapon/flame/lighter))
			text = lightermes
		else if(isWelder(W))
			text = weldermes
		else if(istype(W, /obj/item/device/assembly/igniter))
			text = ignitermes
		text = replacetext(text, "USER", "[user]")
		text = replacetext(text, "NAME", "[name]")
		text = replacetext(text, "FLAME", "[W.name]")
		light(text)

/obj/item/clothing/mask/smokable/attack(var/mob/living/M, var/mob/living/user, def_zone)
	if(istype(M) && M.on_fire)
		user.do_attack_animation(M)
		light("<span class='notice'>\The [user] coldly lights the \the [src] with the burning body of \the [M].</span>")
		return 1
	else
		return ..()

/obj/item/clothing/mask/smokable/cigarette
	name = "cigarette"
	desc = "A small paper cylinder filled with processed tobacco and various fillers."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	attack_verb = list("burnt", "singed")
	type_butt = /obj/item/trash/cigbutt
	chem_volume = 5
	smoketime = 300
	matchmes = "<span class='notice'>USER lights their NAME with their FLAME.</span>"
	lightermes = "<span class='notice'>USER manages to light their NAME with FLAME.</span>"
	zippomes = "<span class='rose'>With a flick of their wrist, USER lights their NAME with their FLAME.</span>"
	weldermes = "<span class='notice'>USER casually lights the NAME with FLAME.</span>"
	ignitermes = "<span class='notice'>USER fiddles with FLAME, and manages to light their NAME.</span>"
	brand = "\improper Trans-Stellar Duty-free"
	var/list/filling = list(/datum/reagent/tobacco = 1)

/obj/item/clothing/mask/smokable/cigarette/New()
	..()
	for(var/R in filling)
		reagents.add_reagent(R, filling[R])

/obj/item/clothing/mask/smokable/cigarette/update_icon()
	..()
	overlays.Cut()
	if(lit)
		overlays += overlay_image(icon, "cigon", flags=RESET_COLOR)

/obj/item/clothing/mask/smokable/cigarette/trident/update_icon()
	..()
	overlays.Cut()
	if(lit)
		overlays += overlay_image(icon, "cigarello-on", flags=RESET_COLOR)

/obj/item/clothing/mask/smokable/extinguish(var/mob/user, var/no_message)
	..()
	if (type_butt)
		var/obj/item/butt = new type_butt(get_turf(src))
		transfer_fingerprints_to(butt)
		butt.color = color
		if(brand)
			butt.desc += " This one is \a [brand]."
		if(ismob(loc))
			var/mob/living/M = loc
			if (!no_message)
				to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		qdel(src)

/obj/item/clothing/mask/smokable/cigarette/menthol
	name = "menthol cigarette"
	desc = "A cigarette with a little minty kick. Well, minty in theory."
	icon_state = "cigmentol"
	brand = "\improper Temperamento Menthol"
	color = "#ddffe8"
	type_butt = /obj/item/trash/cigbutt/menthol
	filling = list(/datum/reagent/tobacco = 1, /datum/reagent/menthol = 1)

/obj/item/trash/cigbutt/menthol
	icon_state = "cigbuttmentol"

/obj/item/clothing/mask/smokable/cigarette/luckystars
	brand = "\improper Lucky Star"

/obj/item/clothing/mask/smokable/cigarette/jerichos
	name = "rugged cigarette"
	brand = "\improper Jericho"
	icon_state = "cigjer"
	color = "#dcdcdc"
	type_butt = /obj/item/trash/cigbutt/jerichos
	filling = list(/datum/reagent/tobacco/bad = 1.5)

/obj/item/trash/cigbutt/jerichos
	icon_state = "cigbuttjer"

/obj/item/clothing/mask/smokable/cigarette/carcinomas
	name = "dark cigarette"
	brand = "\improper Carcinoma Angel"
	color = "#869286"

/obj/item/clothing/mask/smokable/cigarette/professionals
	name = "thin cigarette"
	brand = "\improper Professional"
	icon_state = "cigpro"
	type_butt = /obj/item/trash/cigbutt/professionals
	filling = list(/datum/reagent/tobacco/bad = 1)

/obj/item/trash/cigbutt/professionals
	icon_state = "cigbuttpro"

/obj/item/clothing/mask/smokable/cigarette/killthroat
	brand = "\improper Acme Co. cigarette"

/obj/item/clothing/mask/smokable/cigarette/dromedaryco
	brand = "\improper Dromedary Co. cigarette"

/obj/item/clothing/mask/smokable/cigarette/trident
	name = "wood tip cigar"
	brand = "\improper Trident cigar"
	desc = "A narrow cigar with a wooden tip."
	icon_state = "cigarello"
	item_state = "cigaroff"
	smoketime = 600
	chem_volume = 10
	type_butt = /obj/item/trash/cigbutt/woodbutt
	filling = list(/datum/reagent/tobacco/fine = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/mint
	icon_state = "cigarelloMi"
	filling = list(/datum/reagent/tobacco/fine = 2, /datum/reagent/menthol = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/berry
	icon_state = "cigarelloBe"
	filling = list(/datum/reagent/tobacco/fine = 2, /datum/reagent/drink/juice/berry = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/cherry
	icon_state = "cigarelloCh"
	filling = list(/datum/reagent/tobacco/fine = 2, /datum/reagent/nutriment/cherryjelly = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/grape
	icon_state = "cigarelloGr"
	filling = list(/datum/reagent/tobacco/fine = 2, /datum/reagent/drink/juice/grape = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/watermelon
	icon_state = "cigarelloWm"
	filling = list(/datum/reagent/tobacco/fine = 2, /datum/reagent/drink/juice/watermelon = 2)

/obj/item/clothing/mask/smokable/cigarette/trident/orange
	icon_state = "cigarelloOr"
	filling = list(/datum/reagent/tobacco/fine = 2, /datum/reagent/drink/juice/orange = 2)

/obj/item/trash/cigbutt/woodbutt
	name = "wooden tip"
	desc = "A wooden mouthpiece from a cigar. Smells rather bad."
	icon_state = "woodbutt"
	matter = list("Wood" = 1)

/obj/item/clothing/mask/smokable/cigarette/attackby(var/obj/item/weapon/W, var/mob/user)
	..()

	if(istype(W, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = W
		if(S.active)
			light("<span class='warning'>[user] swings their [W], barely missing their nose. They light their [name] in the process.</span>")

	return

/obj/item/clothing/mask/smokable/cigarette/attack(mob/living/carbon/human/H, mob/user, def_zone)
	if(lit && H == user && istype(H))
		var/obj/item/blocked = H.check_mouth_coverage()
		if(blocked)
			to_chat(H, "<span class='warning'>\The [blocked] is in the way!</span>")
			return 1
		to_chat(H, "<span class='notice'>You take a drag on your [name].</span>")
		smoke(5)
		return 1
	return ..()

/obj/item/clothing/mask/smokable/cigarette/afterattack(obj/item/weapon/reagent_containers/glass/glass, var/mob/user, proximity)
	..()
	if(!proximity)
		return
	if(istype(glass)) //you can dip cigarettes into beakers
		if(!glass.is_open_container())
			to_chat(user, "<span class='notice'>You need to take the lid off first.</span>")
			return
		var/transfered = glass.reagents.trans_to_obj(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")

/obj/item/clothing/mask/smokable/cigarette/attack_self(var/mob/user)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		extinguish(no_message = 1)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/get_icon_state(mob/user_mob, slot)
	return item_state

/obj/item/clothing/mask/smokable/cigarette/get_mob_overlay(mob/user_mob, slot)
	var/image/res = ..()
	if(lit == 1)
		var/image/ember = overlay_image(res.icon, "cigember", flags=RESET_COLOR)
		ember.layer = ABOVE_LIGHTING_LAYER
		ember.plane = ABOVE_LIGHTING_PLANE
		res.overlays += ember
	return res

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/smokable/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	type_butt = /obj/item/trash/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	chem_volume = 15
	matchmes = "<span class='notice'>USER lights their NAME with their FLAME.</span>"
	lightermes = "<span class='notice'>USER manages to offend their NAME by lighting it with FLAME.</span>"
	zippomes = "<span class='rose'>With a flick of their wrist, USER lights their NAME with their FLAME.</span>"
	weldermes = "<span class='notice'>USER insults NAME by lighting it with FLAME.</span>"
	ignitermes = "<span class='notice'>USER fiddles with FLAME, and manages to light their NAME with the power of science.</span>"
	filling = list(/datum/reagent/tobacco/fine = 5)

/obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"

/obj/item/clothing/mask/smokable/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	smoketime = 3000
	chem_volume = 20
	filling = list(/datum/reagent/tobacco/fine = 10)

/obj/item/trash/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	randpixel = 10
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	throwforce = 1

/obj/item/trash/cigbutt/New()
	..()
	transform = turn(transform,rand(0,360))

/obj/item/trash/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/obj/item/clothing/mask/smokable/cigarette/cigar/attackby(var/obj/item/weapon/W, var/mob/user)
	..()

	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)

/////////// //Ported Straight from TG. I am not sorry. - BloodyMan
//ROLLING//
///////////
/obj/item/paper/cig
	name = "rolling paper"
	desc = "A thin piece of paper used to make smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = ITEM_SIZE_TINY

/obj/item/paper/cig/fancy
	name = "\improper Trident rolling paper"
	desc = "A thin piece of trident branded paper used to make fine smokeables."
	icon_state = "cig_paperf"

/obj/item/paper/cig/filter
	name = "cigarette filter"
	desc = "A small nub like filter for cigarettes."
	icon_state = "cig_filter"
	w_class = ITEM_SIZE_TINY

//tobacco sold seperately if you're too snobby to grow it yourself.
/obj/item/weapon/reagent_containers/terrbacco
	name = "tobacco"
	desc = "A wad of carefully cured and dried tobacco. Ground into a mess."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "chew"
	w_class = ITEM_SIZE_TINY
	volume = 15
	var/dry = 1
	var/list/filling = list(/datum/reagent/tobacco = 5)

/obj/item/weapon/reagent_containers/terrbacco/New()
	..()
	for(var/R in filling)
		reagents.add_reagent(R, filling[R])

/obj/item/weapon/reagent_containers/terrbacco/bad
	desc = "A wad of carefully cured and dried tobacco. Ground into a coarse mess."
	filling = list(/datum/reagent/tobacco/bad = 5)

/obj/item/weapon/reagent_containers/terrbacco/fine
	desc = "A wad of carefully cured and dried tobacco. Ground into a fine mess."
	filling = list(/datum/reagent/tobacco/fine = 5)

//cig paper interaction ported straight from TG with some adjustments for our derelict code
/obj/item/paper/cig/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = target
		if(G.dry)
			var/obj/item/clothing/mask/smokable/cigarette/rolled/R = new(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to_holder(R.reagents, R.chem_volume)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a rolling paper.</span>")
			R.desc = "A [target.name] rolled up in a thin piece of paper."
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

//and if you are a savage you can just use a sheet of ordinary paper.
/obj/item/weapon/paper/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = target
		if(G.dry)
			var/obj/item/clothing/mask/smokable/cigarette/rolled/R = new(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to_holder(R.reagents, R.chem_volume)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a regular sheet of paper. How bold.</span>")
			R.desc = "A [target.name] rolled up in a piece of office paper. How bold."
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

//and finally a use for those magic scrolls that are left over from wizard antags.
/obj/item/weapon/teleportation_scroll/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = target
		if(G.dry)
			var/obj/item/clothing/mask/smokable/cigarette/rolled/R = new(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to_holder(R.reagents, R.chem_volume)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into the wizard's teleportation scroll. Not like he'll be needing it anymore.</span>")
			R.desc = "A [target.name] rolled up in a piece of arcane parchment. Magical!"
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

//Repeating this for tobacco-wad objects
/obj/item/paper/cig/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/weapon/reagent_containers/terrbacco))
		var/obj/item/weapon/reagent_containers/terrbacco/Z = target
		if(Z.dry)
			var/obj/item/clothing/mask/smokable/cigarette/rolled/R = new(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to_holder(R.reagents, R.chem_volume)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a rolling paper.</span>")
			R.desc = "A [target.name] rolled up in a thin piece of paper."
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

/obj/item/weapon/paper/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/weapon/reagent_containers/terrbacco))
		var/obj/item/weapon/reagent_containers/terrbacco/Z = target
		if(Z.dry)
			var/obj/item/clothing/mask/smokable/cigarette/rolled/R = new(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to_holder(R.reagents, R.chem_volume)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a regular sheet of paper. How bold.</span>")
			R.desc = "A [target.name] rolled up in a piece of office paper. How bold."
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

/obj/item/weapon/teleportation_scroll/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/weapon/reagent_containers/terrbacco))
		var/obj/item/weapon/reagent_containers/terrbacco/Z = target
		if(Z.dry)
			var/obj/item/clothing/mask/smokable/cigarette/rolled/R = new(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to_holder(R.reagents, R.chem_volume)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into the wizard's teleportation scroll. Not like he'll be needing it anymore.</span>")
			R.desc = "A [target.name] rolled up in a piece of arcane parchment. Magical!"
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

//crafting a filter into the existing rollie
/obj/item/paper/cig/filter/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/clothing/mask/smokable/cigarette/rolled))
		var/obj/item/clothing/mask/smokable/cigarette/rolled/filtered/R = new(user.loc)
		R.chem_volume = target.reagents.total_volume
		target.reagents.trans_to_holder(R.reagents, R.chem_volume)
		qdel(target)
		qdel(src)
		user.put_in_active_hand(R)
		to_chat(user, "<span class='notice'>You roll the filter into the rolled cigarette.</span>")
		R.desc = "A [target.name] with a filter."
	else
		..()

// Rollies.

/obj/item/clothing/mask/smokable/cigarette/rolled
	name = "rolled cigarette"
	desc = "A hand rolled cigarette using dried plant matter."
	icon_state = "cigroll"
	item_state = "cigoff"
	type_butt = /obj/item/trash/cigbutt/rollbutt
	chem_volume = 50
	brand = "handrolled"
	filling = list()

/obj/item/clothing/mask/smokable/cigarette/rolled/office
	brand = "handrolled from regular office paper. How bold."

/obj/item/clothing/mask/smokable/cigarette/rolled/arcane
	brand = "handrolled from a magic scroll"


/obj/item/clothing/mask/smokable/cigarette/rolled/filtered
	name = "filtered rolled cigarette"
	desc = "A hand rolled cigarette using dried plant matter. Capped off one end with a filter."
	icon_state = "cigoff"
	brand = "handrolled with a filter"

/obj/item/trash/cigbutt/rollbutt
	name = "cigarette butt"
	desc = "A cigarette butt."
	icon_state = "rollbutt"

//Bizarre

/obj/item/clothing/mask/smokable/cigarette/rolled/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat, with a smoky scent."
	icon_state = "cigar3off"

	item_state = "cigaroff"
	icon_on = "cigar3on"
	type_butt = /obj/item/trash/cigbutt/sausagebutt
	chem_volume = 6
	smoketime = 5000
	brand = "sausage... wait what."
	filling = list(/datum/reagent/nutriment/protein = 6)

/obj/item/trash/cigbutt/sausagebutt
	name = "sausage butt"
	desc = "A piece of burnt meat."
	icon_state = "sausagebutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/smokable/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	w_class = ITEM_SIZE_TINY
	icon_on = "pipeon"  //Note - these are in masks.dmi
	smoketime = 0
	chem_volume = 50
	matchmes = "<span class='notice'>USER lights their NAME with their FLAME.</span>"
	lightermes = "<span class='notice'>USER manages to light their NAME with FLAME.</span>"
	zippomes = "<span class='rose'>With much care, USER lights their NAME with their FLAME.</span>"
	weldermes = "<span class='notice'>USER recklessly lights NAME with FLAME.</span>"
	ignitermes = "<span class='notice'>USER fiddles with FLAME, and manages to light their NAME with the power of science.</span>"

/obj/item/clothing/mask/smokable/pipe/New()
	..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/smokable/pipe/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit && src.smoketime)
		if(submerged())
			to_chat(usr, "<span class='warning'>You cannot light \the [src] underwater.</span>")
			return
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		START_PROCESSING(SSobj, src)
		if(ismob(loc))
			var/mob/living/M = loc
			M.update_inv_wear_mask(0)
			M.update_inv_l_hand(0)
			M.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/extinguish(var/mob/user, var/no_message)
	..()
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	if(ismob(loc))
		var/mob/living/M = loc
		if (!no_message)
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")

/obj/item/clothing/mask/smokable/pipe/attack_self(var/mob/user)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>You put out [src].</span>")
		lit = 0
		update_icon()
		STOP_PROCESSING(SSobj, src)
	else if (smoketime)
		var/turf/location = get_turf(user)
		user.visible_message("<span class='notice'>[user] empties out [src].</span>", "<span class='notice'>You empty out [src].</span>")
		new /obj/effect/decal/cleanable/ash(location)
		smoketime = 0
		reagents.clear_reagents()
		SetName("empty [initial(name)]")

/obj/item/clothing/mask/smokable/pipe/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/weapon/melee/energy/sword))
		return

	..()

	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = W
		if (!G.dry)
			to_chat(user, "<span class='notice'>[G] must be dried before you stuff it into [src].</span>")
			return
		if (smoketime)
			to_chat(user, "<span class='notice'>[src] is already packed.</span>")
			return
		smoketime = 1000
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		SetName("[G.name]-packed [initial(name)]")
		qdel(G)

	else if(istype(W, /obj/item/weapon/flame/lighter))
		var/obj/item/weapon/flame/lighter/L = W
		if(L.lit)
			light("<span class='notice'>[user] manages to light their [name] with [W].</span>")

	else if(istype(W, /obj/item/weapon/flame/match))
		var/obj/item/weapon/flame/match/M = W
		if(M.lit)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name] with the power of science.</span>")

	user.update_inv_wear_mask(0)
	user.update_inv_l_hand(0)
	user.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen, kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	chem_volume = 35

///////////////////////
//DIP, SNUFF and CHEW//
///////////////////////

/obj/item/clothing/mask/chewable
	name = "chewable item master"
	desc = "You're not sure what this is. You should probably ahelp it."
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = 0

	var/type_butt = null
	var/chem_volume = 0
	var/chewtime = 0
	var/brand
	var/list/filling = list()

obj/item/clothing/mask/chewable/New()
	..()
	atom_flags |= ATOM_FLAG_NO_REACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15
	for(var/R in filling)
		reagents.add_reagent(R, filling[R])

/obj/item/clothing/mask/chewable/equipped()
	START_PROCESSING(SSobj, src)
	..()

/obj/item/clothing/mask/chewable/dropped()
	STOP_PROCESSING(SSobj, src)
	..()

obj/item/clothing/mask/chewable/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/chewable/proc/chew(amount)
	chewtime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, REM, CHEM_INGEST, 0.2) // I am keeping this one because gum is not a replacement for real food. Fuck off Wonka.
		else // else just remove some of the reagents
			reagents.remove_any(REM)

/obj/item/clothing/mask/chewable/Process()
	chew(1)
	if(chewtime < 1)
		extinguish()
		return


/obj/item/clothing/mask/chewable/tobacco
	name = "wad"
	desc = "A chewy wad of terbecco. Cut in long strands and treated with syrups so it doesn't taste like a ash-tray when you stuff it into your face."
	throw_speed = 0.5
	icon_state = "chew"
	type_butt = /obj/item/trash/cigbutt/spitwad
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	chem_volume = 50
	chewtime = 300
	brand = "tobacco"

/obj/item/trash/cigbutt/spitwad
	name = "spit wad"
	desc = "A disgusting spitwad."
	icon_state = "spit-gum"

/obj/item/clothing/mask/chewable/proc/extinguish(var/mob/user, var/no_message)
	STOP_PROCESSING(SSobj, src)
	if (type_butt)
		var/obj/item/butt = new type_butt(get_turf(src))
		transfer_fingerprints_to(butt)
		butt.color = color
		if(brand)
			butt.desc += " This one is \a [brand]."
		if(ismob(loc))
			var/mob/living/M = loc
			if (!no_message)
				to_chat(M, "<span class='notice'>You spit out the [name].</span>")
		qdel(src)

/obj/item/clothing/mask/chewable/tobacco/lenni
	name = "chewing tobacco"
	desc = "A chewy wad of tobacco. Cut in long strands and treated with syrups so it tastes less like a ash-tray when you stuff it into your face."
	filling = list(/datum/reagent/tobacco = 2)

/obj/item/clothing/mask/chewable/tobacco/redlady
	name = "chewing tobacco"
	desc = "A chewy wad of fine tobacco. Cut in long strands and treated with syrups so it doesn't taste like a ash-tray when you stuff it into your face"
	filling = list(/datum/reagent/tobacco/fine = 2)

/obj/item/clothing/mask/chewable/tobacco/nico
	name = "nicotine gum"
	desc = "A chewy wad of synthetic rubber, laced with nicotine. Possibly the least disgusting method of nicotine delivery."
	icon_state = "nic_gum"
	type_butt = /obj/item/trash/cigbutt/spitgum

/obj/item/clothing/mask/chewable/tobacco/nico/New()
	..()
	reagents.add_reagent(/datum/reagent/nicotine, 2)
	color = reagents.get_color()

/obj/item/clothing/mask/chewable/candy
	name = "wad"
	desc = "A chewy wad of wadding material."
	throw_speed = 0.5
	icon_state = "chew"
	type_butt = /obj/item/trash/cigbutt/spitgum
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	chem_volume = 50
	chewtime = 300
//	brand = "wad"
	filling = list(/datum/reagent/sugar = 2)


/obj/item/trash/cigbutt/spitgum
	name = "old gum"
	desc = "A disgusting chewed up wad of gum."
	icon_state = "spit-gum"


/obj/item/trash/cigbutt/lollibutt
	name = "popsicle stick"
	desc = "A popsicle stick devoid of pop."
	icon_state = "pop-stick"


/obj/item/clothing/mask/chewable/candy/gum
	name = "chewing gum"
	desc = "A chewy wad of fine synthetic rubber and artificial flavoring."
	icon_state = "gum"
	item_state = "gum"
//	brand = "gum"

/obj/item/clothing/mask/chewable/candy/gum/New()
	..()
	reagents.add_reagent(pick(list(
				/datum/reagent/fuel,
				/datum/reagent/drink/juice/grape,
				/datum/reagent/drink/juice/orange,
				/datum/reagent/drink/juice/lemon,
				/datum/reagent/drink/juice/lime,
				/datum/reagent/drink/juice/banana,
				/datum/reagent/drink/juice/berry,
				/datum/reagent/drink/juice/watermelon)), 3)
	color = reagents.get_color()

/obj/item/clothing/mask/chewable/candy/lolli
	name = "lollipop"
	desc = "A simple artificially flavored sphere of sugar on a handle. Colloquially known as a sucker. Allegedly one is born every minute."
	type_butt = /obj/item/trash/cigbutt/lollibutt
	icon_state = "lollipop"
	item_state = "lollipop"
//	brand = "unremarkable"
/obj/item/clothing/mask/chewable/candy/lolli/New()
	..()
	reagents.add_reagent(pick(list(
				/datum/reagent/fuel,
				/datum/reagent/drink/juice/grape,
				/datum/reagent/drink/juice/orange,
				/datum/reagent/drink/juice/lemon,
				/datum/reagent/drink/juice/lime,
				/datum/reagent/drink/juice/banana,
				/datum/reagent/drink/juice/berry,
				/datum/reagent/drink/juice/watermelon)), 3)
	color = reagents.get_color()

/obj/item/clothing/mask/chewable/candy/lolli/meds
	name = "lollipop"
	desc = "A sucrose sphere on a small handle, it has been infused with medication."
	type_butt = /obj/item/trash/cigbutt/lollibutt
	icon_state = "lollipop"

/obj/item/clothing/mask/chewable/candy/lolli/meds/New()
	..()
	reagents.add_reagent(pick(list(
				/datum/reagent/dexalinp,
				/datum/reagent/tricordrazine,
				/datum/reagent/hyperzine,
				/datum/reagent/hyronalin,
				/datum/reagent/methylphenidate,
				/datum/reagent/citalopram,
				/datum/reagent/dylovene,
				/datum/reagent/bicaridine,
				/datum/reagent/kelotane,
				/datum/reagent/inaprovaline)), 10)
	color = reagents.get_color()




/////////
//ZIPPO//
/////////
/obj/item/weapon/flame/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = ITEM_SIZE_TINY
	throwforce = 4
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
	var/max_fuel = 5

/obj/item/weapon/flame/lighter/New()
	..()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	set_extension(src, /datum/extension/base_icon_state, icon_state)
	update_icon()

/obj/item/weapon/flame/lighter/proc/light(mob/user)
	if(submerged())
		to_chat(usr, "<span class='warning'>You cannot light \the [src] underwater.</span>")
		return
	lit = 1
	update_icon()
	light_effects(user)
	set_light(0.6, 0.5, 2)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/flame/lighter/proc/light_effects(mob/living/carbon/user)
	if(prob(95))
		user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
	else
		to_chat(user, "<span class='warning'>You burn yourself while lighting the lighter.</span>")
		if (user.l_hand == src)
			user.apply_damage(2,BURN,BP_L_HAND)
		else
			user.apply_damage(2,BURN,BP_R_HAND)
		user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")
	playsound(src.loc, "light_bic", 100, 1, -4)

/obj/item/weapon/flame/lighter/extinguish(var/mob/user, var/no_message)
	..()
	update_icon()
	if(user)
		shutoff_effects(user)
	else if(!no_message)
		visible_message("<span class='notice'>[src] goes out.</span>")
	set_light(0)

/obj/item/weapon/flame/lighter/proc/shutoff_effects(mob/user)
	user.visible_message("<span class='notice'>[user] quietly shuts off the [src].</span>")

/obj/item/weapon/flame/lighter/zippo
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	max_fuel = 10

/obj/item/weapon/flame/lighter/bullet
	name = "bullet ligther"
	desc = "A homemade lighter made out of a big caliber bullet."
	icon_state = "bulletzip"
	item_state = "zippo"
	max_fuel = 20

/obj/item/weapon/flame/lighter/zippo/light_effects(mob/user)
	user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
	playsound(src.loc, 'sound/items/zippo_open.ogg', 100, 1, -4)

/obj/item/weapon/flame/lighter/zippo/shutoff_effects(mob/user)
	user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing.</span>")
	playsound(src.loc, 'sound/items/zippo_close.ogg', 100, 1, -4)

/obj/item/weapon/flame/lighter/zippo/afterattack(obj/O, mob/user, proximity)
	if(!proximity) return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && !lit)
		O.reagents.trans_to_obj(src, max_fuel)
		to_chat(user, "<span class='notice'>You refuel [src] from \the [O]</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)

/obj/item/weapon/flame/lighter/random/New()
	icon_state = "lighter-[pick("r","c","y","g")]"
	item_state = icon_state
	..()

/obj/item/weapon/flame/lighter/attack_self(mob/living/user)
	if(!lit)
		if(reagents.has_reagent(/datum/reagent/fuel))
			light(user)
		else
			to_chat(user, "<span class='warning'>[src] won't ignite - out of fuel.</span>")
	else
		extinguish(user)

/obj/item/weapon/flame/lighter/update_icon()
	. = ..()
	var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)

	if(lit)
		icon_state = "[bis.base_icon_state]on"
		item_state = "[bis.base_icon_state]on"
	else
		icon_state = "[bis.base_icon_state]"
		item_state = "[bis.base_icon_state]"

/obj/item/weapon/flame/lighter/attack(var/mob/living/carbon/M, var/mob/living/carbon/user)
	if(!istype(M, /mob))
		return

	if(lit)
		M.IgniteMob()

		if(istype(M.wear_mask, /obj/item/clothing/mask/smokable/cigarette) && user.zone_sel.selecting == BP_MOUTH)
			var/obj/item/clothing/mask/smokable/cigarette/cig = M.wear_mask
			if(M == user)
				cig.attackby(src, user)
			else
				if(istype(src, /obj/item/weapon/flame/lighter/zippo))
					cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M].</span>")
				else
					cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
			return

	..()

/obj/item/weapon/flame/lighter/Process()
	if(!submerged() && reagents.has_reagent(/datum/reagent/fuel))
		if(ismob(loc) && prob(10) && reagents.get_reagent_amount(/datum/reagent/fuel) < 1)
			to_chat(loc, "<span class='warning'>[src]'s flame flickers.</span>")
			set_light(0)
			spawn(4)
				set_light(0.6, 0.5, 2)
		reagents.remove_reagent(/datum/reagent/fuel, 0.05)
	else
		extinguish()

		var/turf/location = get_turf(src)
		if(location)
			location.hotspot_expose(700, 5)
