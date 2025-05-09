/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act

*/

/obj/item/proc/get_attack_name()
	if(sharp && edge)
		return "slices"
	else if(sharp && !edge)
		return "stabs"
	else
		return "hits"

/mob/living/carbon/human/bullet_act(var/obj/item/projectile/P, var/def_zone)

	def_zone = check_zone(def_zone)
	if(!has_organ(def_zone))
		return PROJECTILE_FORCE_MISS //if they don't have the organ in question then the projectile just passes by.

	//Shields
	var/shield_check = check_shields(P.damage, P, null, def_zone, "the [P.name]")
	if(shield_check)
		if(shield_check < 0)
			return shield_check
		else
			P.on_hit(src, 100, def_zone)
			return 100

	var/obj/item/organ/external/organ = get_organ(def_zone)
	var/armor = getarmor_organ(organ, P.check_armour)
	var/penetrating_damage = ((P.damage + P.armor_penetration) * P.penetration_modifier) - armor

	//Organ damage
	if(organ.internal_organs.len && prob(35 + max(penetrating_damage, -12.5)))
		var/damage_amt = min((P.damage * P.penetration_modifier), penetrating_damage) //So we don't factor in armor_penetration as additional damage
		if(damage_amt > 0)
		// Damage an internal organ
			var/list/victims = list()
			var/list/possible_victims = shuffle(organ.internal_organs.Copy())
			for(var/obj/item/organ/internal/I in possible_victims)
				if(I.damage < I.max_damage && (prob((I.relative_size) * (1 / max(1, victims.len)))))
					victims += I
			if(victims.len)
				for(var/obj/item/organ/internal/victim in victims)
					damage_amt /= 2
					victim.take_internal_damage(damage_amt)

	//Embed or sever artery
	if(P.can_embed() && !(species.species_flags & SPECIES_FLAG_NO_EMBED) && prob(22.5 + max(penetrating_damage, -10)) && !(prob(50) && (organ.sever_artery())))
		var/obj/item/weapon/material/shard/shrapnel/SP = new()
		SP.SetName((P.name != "shrapnel")? "[P.name] shrapnel" : "shrapnel")
		SP.desc = "[SP.desc] It looks like it was fired from [P.shot_from]."
		SP.loc = organ
		organ.embed(SP)

	var/blocked = ..(P, def_zone)

	projectile_hit_bloody(P, P.damage*blocked_mult(blocked), def_zone)

	shake_camera(src, 3, 1)

	return blocked

/mob/living/carbon/human/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone)
	var/obj/item/organ/external/affected = get_organ(check_zone(def_zone))
	if(!affected)
		return

	var/siemens_coeff = get_siemens_coefficient_organ(affected)
	stun_amount *= siemens_coeff
	agony_amount *= siemens_coeff
	agony_amount *= affected.get_agony_multiplier()

	affected.stun_act(stun_amount, agony_amount)

	..(stun_amount, agony_amount, def_zone)

/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	var/psi_mod = psi ? psi.get_armour(type) : 0
	var/armorval = 0
	var/total = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/obj/item/organ/external/affecting = get_organ(def_zone)
		if(affecting)
			return clamp(psi_mod + getarmor_organ(isorgan(def_zone) ? def_zone : get_organ(def_zone), type),0,100)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/organ_name in organs_by_name)
		if (organ_name in organ_rel_size)
			var/obj/item/organ/external/organ = organs_by_name[organ_name]
			if(organ)
				var/weight = organ_rel_size[organ_name]
				armorval += (getarmor_organ(organ, type) * weight) //use plain addition here because we are calculating an average
				total += weight
	return clamp(psi_mod + (armorval/max(total, 1)),0,100)

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/obj/item/organ/external/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = max(species.siemens_coefficient,0)

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(var/obj/item/organ/external/def_zone, var/type)
	if(!type || !def_zone) return 0
	if(!istype(def_zone))
		def_zone = get_organ(check_zone(def_zone))
	if(!def_zone)
		return 0
	var/protection = 0
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/obj/item/clothing/gear in protective_gear)
		if(gear.body_parts_covered & def_zone.body_part)
			protection = add_armor(protection, gear.armor[type])
		if(gear.accessories.len)
			for(var/obj/item/clothing/accessory/bling in gear.accessories)
				if(bling.body_parts_covered & def_zone.body_part)
					protection = add_armor(protection, bling.armor[type])
	return protection

/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & HEAD)
				return 1
	return 0

//Used to check if they can be fed food/drinks/pills
/mob/living/carbon/human/check_mouth_coverage()
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform)
	for(var/obj/item/gear in protective_gear)
		if(istype(gear) && (gear.body_parts_covered & FACE) && !(gear.item_flags & ITEM_FLAG_FLEXIBLEMATERIAL))
			return gear
	return null

/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/atom/damage_source = null, var/mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	var/obj/item/projectile/P = damage_source
	if(istype(P) && !P.disrupts_psionics() && psi && P.starting && prob(psi.get_armour(P.check_armour) * 0.5) && psi.spend_power(round(damage/10)))
		visible_message("<span class='danger'>\The [src] deflects [attack_text]!</span>")
		P.redirect(P.starting.x + rand(-2,2), P.starting.y + rand(-2,2), get_turf(src), src)
		return PROJECTILE_FORCE_MISS

	for(var/obj/item/weapon/shield in list(l_hand, r_hand, wear_suit))
		if(!shield) continue
		. = shield.handle_shield(src, damage, damage_source, attacker, def_zone, attack_text)
		if(.) return
	return 0

/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, var/target_zone)

	for (var/obj/item/grab/G in grabbed_by)
		if(G.resolve_item_attack(user, I, target_zone))
			return null

	if(user == src) // Attacking yourself can't miss
		return target_zone

	if(attempt_dodge())//Trying to dodge it before they even have the chance to miss us.
		return null

	var/hit_modifier = user.c_intent == I_AIM ? -40 : 0 //If they are in aim mode, miss less
	var/hit_zone = get_zone_with_miss_chance(target_zone, src, hit_modifier)

	if(!hit_zone)
		visible_message("<span class='danger'>\The [user] misses [src] with \the [I]!</span>")
		return null

	if(user.skillcheck(user.skills["melee"], 60, null, "melee") == CRIT_FAILURE)
		user.resolve_critical_miss(I)
		return null

	if(!user.skillcheck(user.skills["melee"], 30, null, "melee") || !user.combat_mode)
		if(prob(user.skills["melee"]/3))
			visible_message("<span class='danger'>[user] botches the attack on [src]!</span>")
			return null

	//PARRYING HAPPENS HERE
	if(check_shields(I.force, I, user, target_zone, "the [I.name]"))
		return null

	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if (!affecting || affecting.is_stump())
		to_chat(user, "<span class='danger'>They are missing that limb!</span>")
		return null

	var/blocked = run_armor_check(hit_zone, "melee", I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")

	if(blocked == 100)
		visible_message("<span class='danger'>[user] [I.get_attack_name()] [src]'s [affecting.name] with the [I], but it does no damage!")
		return null

	if(hit_zone == BP_CHEST || hit_zone == BP_MOUTH || hit_zone == BP_THROAT || hit_zone == BP_HEAD)//If we're lying and we're trying to aim high, we won't be able to hit.
		if(user.lying && !src.lying)
			to_chat(user, "<span class='notice'><b>I can't reach their [affecting.name]!</span></b>")
			return null

	return hit_zone

/mob/living/carbon/human/hit_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)

	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return //should be prevented by attacked_with_item() but for sanity.

	var/aim_zone = user.zone_sel.selecting


	var/obj/item/organ/external/aimed = get_organ(aim_zone)

	var/organ_hit = affecting.name//This is spaghetti, but it's done so that it recognizes when you hit the throat, and when you hit something else instead.

	if(aim_zone == BP_THROAT)
		organ_hit = "throat"

	var/blocked = run_armor_check(hit_zone, "melee", I.armor_penetration, "Your armor has protected your [affecting.name].", "Your armor has softened the blow to your [affecting.name].")


	if(hit_zone != aim_zone && (aim_zone != BP_MOUTH) &&  (aim_zone != BP_THROAT) && (aim_zone != BP_EYES))//This is ugly but it works.
		visible_message("<span class='combat'>[user] aimed for [src]\'s [aimed.name], but [I.get_attack_name()] \his [organ_hit] instead. [(blocked < 20 && blocked > 1)  ? "Slight damage was done." : ""]</span>")

	else if(blocked < 20 && blocked > 1)//This is ugly and it doesn't work.
		visible_message("<span class='combat'>[user] [I.get_attack_name()] [src]\'s [organ_hit] with the [I.name]! Slight damage was done.</span>")

	else
		visible_message("<span class='combat'>[user] [I.get_attack_name()] [src]\'s [organ_hit] with the [I.name]!</span>")

	receive_damage()

	shake_camera(src, 3, 1)

	standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)

	return blocked

/mob/living/carbon/human/standard_weapon_hit_effects(obj/item/I, mob/living/user, var/effective_force, var/blocked, var/hit_zone)
	hit_zone = user.zone_sel.selecting
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return 0

	if(user.stats[STAT_ST])//If they have strength then add it.
		effective_force += strToDamageModifier(user.stats[STAT_ST])

	// Handle striking to cripple.
	if(user.a_intent == I_DISARM)
		effective_force *= 0.66 //reduced effective force...
		if(!..(I, user, effective_force, blocked, hit_zone))
			return 0

		//set the dislocate mult less than the effective force mult so that
		//dislocating limbs on disarm is a bit easier than breaking limbs on harm
		attack_joint(affecting, I, effective_force, 0.5, blocked) //...but can dislocate joints

	else if(!..())
		return 0

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	//Ok this block of text handles cutting arteries, tendons, and limbs off.
	//First we cut an artery, the reason for that, is that arteries are funninly enough, not that lethal, and don't have the biggest impact. They'll still make you bleed out, but they're less immediately lethal.
	if(I.sharp && prob(I.sharpness * 2) && !(affecting.status & ORGAN_ARTERY_CUT))
		affecting.sever_artery()
		if(affecting.artery_name == "cartoid artery")
			src.visible_message("<span class='danger'>[user] slices [src]'s throat!</span>")
		else
			src.visible_message("<span class='danger'>[user] slices open [src]'s [affecting.artery_name]!</span>")

	//Next tendon, which disables the limb, but does not remove it, making it easier to fix, and less lethal, than losing it.
	else if(I.sharp && (I.sharpness * 2) && !(affecting.status & ORGAN_TENDON_CUT) && affecting.has_tendon)//Yes this is the same exactly probability again. But I'm running it seperate because I don't want the two to be exclusive.
		affecting.sever_tendon()
		src.visible_message("<span class='danger'>[user] slices open [src]'s [affecting.tendon_name]!</span>")

	if(I.sharp && affecting.has_finger && prob(rand(10,18)))
		affecting.ripout_fingers(get_dir(affecting, src), round(rand(28, 38) * ((I.force*1.5)/100)))

	//Finally if we pass all that, we cut the limb off. This should reduce the number of one hit sword kills.
	else if(I.sharp && I.edge)
		if(I.sharpness >= 1 && user.statcheck(user.stats[STAT_ST], 13, 0, STAT_ST)) //cant dismember with blunt objects fool, or being a weak fool
			if(prob(I.sharpness * strToDamageModifier(user.stats[STAT_ST])))
				affecting.droplimb(0, DROPLIMB_EDGE)

	var/obj/item/organ/external/head/O = locate(/obj/item/organ/external/head) in src.organs

	if(I.damtype == BRUTE && !I.edge && prob(I.force * (hit_zone == BP_MOUTH ? 6 : 0)) && O)//Knocking out teeth.
		if(O.knock_out_teeth(get_dir(user, src), round(rand(28, 38) * ((I.force*1.5)/100))))
			src.visible_message("<span class='danger'>[src]'s teeth sail off in an arc!</span>", \
								"<span class='userdanger'>[src]'s teeth sail off in an arc!</span>")

	else if((I.damtype == BRUTE || I.damtype == PAIN) && prob(25 + (effective_force * 2)))//Knocking them out.
		if(!stat)
			if(headcheck(hit_zone))
				//Harder to score a stun but if you do it lasts a bit longer
				if(prob(effective_force - stat_to_modifier(user.stats[STAT_HT])))
					visible_message("<span class='danger'>[src] [species.knockout_message]</span>")
					apply_effect(20, PARALYZE, blocked)
			else if(hit_zone == (BP_L_LEG || BP_R_LEG || BP_L_FOOT || BP_R_FOOT))
				//Easier to score a stun but lasts less time
				if(prob(effective_force + 15 - stat_to_modifier(user.stats[STAT_HT])))
					visible_message("<span class='danger'>[src] has been knocked down!</span>")
					apply_effect(6, WEAKEN, blocked)
		//Apply blood
		attack_bloody(I, user, effective_force, hit_zone)
	if(user.skillcheck(user.skills["melee"], 0, null,"melee") == CRIT_SUCCESS)
		resolve_critical_hit()

	if(user.stats[STAT_HT] >= src.stats[STAT_HT]+4 && !lying)
		Weaken(1)
		var/turf/target = get_turf(src.loc)
		var/range = src.throw_range
		var/throw_dir = get_dir(user, src)
		for(var/i = 1; i < range; i++)
			var/turf/new_turf = get_step(target, throw_dir)
			target = new_turf
			if(new_turf.density)
				break
		src.throw_at(target, rand(2,4), src.throw_speed)

	//Blood to gold
	if(GLOB.all_religions["Gozag Ym Sagoz"].bloodgold)
		var/datum/transaction/T = new("Gozag Ym Sagoz", "Blood money", -effective_force)
		spawn_money(round(effective_force),src.loc,null)
		mind.initial_account.do_transaction(T)
	return 1

/mob/living/carbon/human/proc/attack_bloody(obj/item/W, mob/living/attacker, var/effective_force, var/hit_zone)
	if(W.damtype != BRUTE)
		return

	//make non-sharp low-force weapons less likely to be bloodied
	if(W.sharp || prob(effective_force*4))
		if(!(W.atom_flags & ATOM_FLAG_NO_BLOOD))
			W.add_blood(src)
	else
		return //if the weapon itself didn't get bloodied than it makes little sense for the target to be bloodied either

	//getting the weapon bloodied is easier than getting the target covered in blood, so run prob() again
	if(prob(33 + W.sharp*10))
		var/turf/location = loc
		if(istype(location, /turf/simulated))
			location.add_blood(src)
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
				H.bloody_body(src)
				H.bloody_hands(src)

		switch(hit_zone)
			if(BP_HEAD)
				if(wear_mask)
					wear_mask.add_blood(src)
					update_inv_wear_mask(0)
				if(head)
					head.add_blood(src)
					update_inv_head(0)
				if(glasses && prob(33))
					glasses.add_blood(src)
					update_inv_glasses(0)
			if(BP_CHEST)
				bloody_body(src)

	//All this is copypasta'd from projectile code. Basically there's a cool splat animation when someone gets hit by something.
	var/splatter_dir = dir
	var/turf/target_loca = get_turf(src)
	splatter_dir = get_dir(attacker, target_loca)
	target_loca = get_step(target_loca, splatter_dir)
	var/blood_color = "#C80000"
	blood_color = src.species.blood_color
	new /obj/effect/overlay/temp/dir_setting/bloodsplatter(target_loca, splatter_dir, blood_color)
	target_loca.add_blood(src)

/mob/living/carbon/human/proc/projectile_hit_bloody(obj/item/projectile/P, var/effective_force, var/hit_zone)
	if(P.damage_type != BRUTE || P.nodamage)
		return
	if(!(P.sharp || prob(effective_force*4)))
		return
	if(prob(effective_force))
		var/turf/location = loc
		if(istype(location, /turf/simulated))
			location.add_blood(src)

		switch(hit_zone)
			if(BP_HEAD)
				if(wear_mask)
					wear_mask.add_blood(src)
					update_inv_wear_mask(0)
				if(head)
					head.add_blood(src)
					update_inv_head(0)
				if(glasses && prob(33))
					glasses.add_blood(src)
					update_inv_glasses(0)
			if(BP_CHEST)
				bloody_body(src)

/mob/living/carbon/human/proc/attack_joint(var/obj/item/organ/external/organ, var/obj/item/W, var/effective_force, var/dislocate_mult, var/blocked)
	if(!organ || (organ.dislocated == 2) || (organ.dislocated == -1) || blocked >= 100)
		return 0
	if(W.damtype != BRUTE)
		return 0

	//want the dislocation chance to be such that the limb is expected to dislocate after dealing a fraction of the damage needed to break the limb
	var/dislocate_chance = effective_force/(dislocate_mult * organ.min_broken_damage * config.organ_health_multiplier)*100
	if(prob(dislocate_chance * blocked_mult(blocked)))
		visible_message("<span class='danger'>[src]'s [organ.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		organ.dislocate(1)
		return 1
	return 0

/mob/living/carbon/human/emag_act(var/remaining_charges, mob/user, var/emag_source)
	var/obj/item/organ/external/affecting = get_organ(user.zone_sel.selecting)
	if(!affecting || !(affecting.robotic >= ORGAN_ROBOT))
		to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
		return -1
	if(affecting.sabotaged)
		to_chat(user, "<span class='warning'>[src]'s [affecting.name] is already sabotaged!</span>")
		return -1
	to_chat(user, "<span class='notice'>You sneakily slide [emag_source] into the dataport on [src]'s [affecting.name] and short out the safeties.</span>")
	affecting.sabotaged = 1
	return 1

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM as mob|obj,var/speed = THROWFORCE_SPEED_DIVISOR)
	if(istype(AM,/obj/))
		var/obj/O = AM

		if(in_throw_mode && !get_active_hand() && speed <= THROWFORCE_SPEED_DIVISOR)	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(isturf(O.loc))
					put_in_active_hand(O)
					visible_message("<span class='warning'>[src] catches [O]!</span>")
					throw_mode_off()
					return

		var/dtype = O.damtype
		var/throw_damage = O.throwforce*(speed/THROWFORCE_SPEED_DIVISOR)

		var/zone
		if (istype(O.thrower, /mob/living))
			var/mob/living/L = O.thrower
			zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone(BP_CHEST,75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		var/miss_chance = 15
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = max(15*(distance-2), 0)
		zone = get_zone_with_miss_chance(zone, src, miss_chance, ranged_attack=1)

		if(zone && O.thrower != src)
			var/shield_check = check_shields(throw_damage, O, thrower, zone, "[O]")
			if(shield_check == PROJECTILE_FORCE_MISS)
				zone = null
			else if(shield_check)
				return

		if(!zone)
			visible_message("<span class='notice'>\The [O] misses [src] narrowly!</span>")
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1)
			return

		O.throwing = 0		//it hit, so stop moving

		var/obj/item/organ/external/affecting = get_organ(zone)
		var/hit_area = affecting.name
		var/datum/wound/created_wound

		src.visible_message("<span class='warning'>\The [src] has been hit in the [hit_area] by \the [O].</span>")
		var/armor = run_armor_check(affecting, "melee", O.armor_penetration, "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here
		if(armor < 100)
			var/damage_flags = O.damage_flags()
			if(prob(armor))
				damage_flags &= ~(DAM_SHARP|DAM_EDGE)
			created_wound = apply_damage(throw_damage, dtype, zone, armor, damage_flags, O)

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				admin_attack_log(M, src, "Threw \an [O] at their victim.", "Had \an [O] thrown at them", "threw \an [O] at")

		//thrown weapon embedded object code.
		if(dtype == BRUTE && istype(O,/obj/item))
			var/obj/item/I = O
			if (!is_robot_module(I))
				var/sharp = is_sharp(I)
				var/damage = throw_damage //the effective damage used for embedding purposes, no actual damage is dealt here
				if (armor)
					damage *= blocked_mult(armor)

				//blunt objects should really not be embedding in things unless a huge amount of force is involved
				var/embed_chance = sharp? damage/I.w_class : damage/(I.w_class*3)
				var/embed_threshold = sharp? 5*I.w_class : 15*I.w_class

				//Sharp objects will always embed if they do enough damage.
				//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
				if((sharp && prob(damage/(10*I.w_class)*100)) || (damage > embed_threshold && prob(embed_chance)))
					affecting.embed(I, supplied_wound = created_wound)

		shake_camera(src, 3, 1)

		// Begin BS12 momentum-transfer code.
		var/mass = 1.5
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class/THROWNOBJ_KNOCKBACK_DIVISOR
		var/momentum = speed*mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			visible_message("<span class='warning'>\The [src] staggers under the impact!</span>","<span class='warning'>You stagger under the impact!</span>")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!O || !src) return

			if(O.loc == src && O.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O

/mob/living/carbon/human/embed(var/obj/O, var/def_zone=null, var/datum/wound/supplied_wound)
	if(!def_zone) ..()

	if(O.obj_flags & OBJ_FLAG_NO_EMBED)
		return

	var/obj/item/organ/external/affecting = get_organ(def_zone)
	if(affecting)
		affecting.embed(O, supplied_wound = supplied_wound)

/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)
	if (gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(0)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(0)

/mob/living/carbon/human/proc/handle_suit_punctures(var/damtype, var/damage, var/def_zone)

	// Tox and oxy don't matter to suits.
	if(damtype != BURN && damtype != BRUTE) return

	// The rig might soak this hit, if we're wearing one.
	if(back && istype(back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/rig = back
		rig.take_hit(damage)

	// We may also be taking a suit breach.
	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	var/obj/item/clothing/suit/space/SS = wear_suit
	var/penetrated_dam = max(0,(damage - SS.breach_threshold))
	if(penetrated_dam) SS.create_breaches(damtype, penetrated_dam)

/mob/living/carbon/human/reagent_permeability()
	var/perm = 0

	var/list/perm_by_part = list(
		"head" = THERMAL_PROTECTION_HEAD,
		"upper_torso" = THERMAL_PROTECTION_UPPER_TORSO,
		"lower_torso" = THERMAL_PROTECTION_LOWER_TORSO,
		"legs" = THERMAL_PROTECTION_LEG_LEFT + THERMAL_PROTECTION_LEG_RIGHT,
		"feet" = THERMAL_PROTECTION_FOOT_LEFT + THERMAL_PROTECTION_FOOT_RIGHT,
		"arms" = THERMAL_PROTECTION_ARM_LEFT + THERMAL_PROTECTION_ARM_RIGHT,
		"hands" = THERMAL_PROTECTION_HAND_LEFT + THERMAL_PROTECTION_HAND_RIGHT
		)

	for(var/obj/item/clothing/C in src.get_equipped_items())
		if(C.permeability_coefficient == 1 || !C.body_parts_covered)
			continue
		if(C.body_parts_covered & HEAD)
			perm_by_part["head"] *= C.permeability_coefficient
		if(C.body_parts_covered & UPPER_TORSO)
			perm_by_part["upper_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LOWER_TORSO)
			perm_by_part["lower_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LEGS)
			perm_by_part["legs"] *= C.permeability_coefficient
		if(C.body_parts_covered & FEET)
			perm_by_part["feet"] *= C.permeability_coefficient
		if(C.body_parts_covered & ARMS)
			perm_by_part["arms"] *= C.permeability_coefficient
		if(C.body_parts_covered & HANDS)
			perm_by_part["hands"] *= C.permeability_coefficient

	for(var/part in perm_by_part)
		perm += perm_by_part[part]

	return perm

/mob/living/carbon/human/kick_act(var/mob/living/user)
	if(!..())//If we can't kick then this doesn't happen.
		return
	if(user == src)//Can't kick yourself dummy.
		return

	var/hit_zone = user.zone_sel.selecting
	var/too_high_message = "You can't reach that high."
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting || affecting.is_stump())
		to_chat(user, "<span class='danger'>They are missing that limb!</span>")
		return

	var/armour = run_armor_check(hit_zone, "melee")
	switch(hit_zone)
		if(BP_CHEST)//If we aim for the chest we kick them in the direction we're facing.
			if(lying || prob(10))
				var/turf/target = get_turf(src.loc)
				var/range = src.throw_range
				var/throw_dir = get_dir(user, src)
				var/throwdis = 1 + 3 + user.stats[STAT_ST] - 7
				for(var/i = 1; i < range; i++)
					var/turf/new_turf = get_step(target, throw_dir)
					target = new_turf
					if(new_turf.density)
						break
				src.throw_at(target, throwdis, src.throw_speed)
			if(user.lying)
				to_chat(user, too_high_message)
				return

		if(BP_MOUTH)//If we aim for the mouth then we kick their teeth out.
			if(lying)
				if(istype(affecting, /obj/item/organ/external/head) && prob(95))
					var/obj/item/organ/external/head/U = affecting
					U.knock_out_teeth(get_dir(user, src), rand(1,3))//Knocking out one tooth at a time.
			else
				to_chat(user, too_high_message)
				return

		if(BP_HEAD)
			if(!lying)
				to_chat(user, too_high_message)
				return

	//STR makes you hit harder, DEX makes it less tiring
	var/kickdam = rand(5,20) + stat_to_modifier(user.stats[STAT_ST])
	user.adjustStaminaLoss(rand(30,45) - stat_to_modifier(user.stats[STAT_DX]))//Kicking someone is a big deal.
	if(kickdam)
		playsound(user.loc, 'sound/weapons/kick.ogg', 50, 0)
		apply_damage(kickdam, BRUTE, hit_zone, armour)
		user.visible_message("<span class= 'combat'>[user] kicks [src] in the [affecting.name]!</span>")
		admin_attack_log(user, src, "Has kicked [src]", "Has been kicked by [user].")
	else
		user.visible_message("<span class= 'combat'>[user] tried to kick [src] in the [affecting.name], but missed!</span>")
		playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1)


//We crit failed, let's see what happens to us.
/mob/living/proc/resolve_critical_miss(var/obj/item/I)
	var/result = rand(1,3)

	if(!I)
		visible_message("<span class='danger'>[src] punches themself in the face!</span>")
		attack_hand(src)
		return

	switch(result)
		if(1)//They drop their weapon.
			visible_message("<span class='combat'><big>CRITICAL FAILURE! \The [I] flies out of [src]'s hand!</big></span>")
			drop_from_inventory(I)
			throw_at(get_edge_target_turf(I, pick(GLOB.alldirs)), rand(1,3), throw_speed)//Throw that sheesh away
			return
		if(2)
			visible_message("<span class='combat'><big>CRITICAL FAILURE! [src] botches the attack, stumbles, and falls!</big></span>")
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1)
			Weaken(1)
			Stun(3)
			return
		if(3)
			visible_message("<span class='combat'><big>CRITICAL FAILURE! [src] botches the attack and hits themself!</big></span>")
			I.attack(src, src, zone_sel)
			apply_damage(rand(5,10), BRUTE)

/mob/living/proc/resolve_critical_miss_unarmed()
	visible_message("<span class='danger'>[src] punches themself in the face!</span>")
	attack_hand(src)
	return

/mob/living/proc/resolve_critical_hit()
	var/result = rand(1,3)

	switch(result)
		if(1)
			visible_message("<span class='danger'><big>CRITICAL HIT! IT MUST BE PAINFUL</big></span>")
			apply_damage(rand(5,10), BRUTE)
			return

		if(2)
			visible_message("<span class='danger'><big>CRITICAL HIT! [src] is stunned!</big></span>")
			Weaken(1)
			Stun(3)
			return

		if(3)
			visible_message("<span class='danger'><big>CRITICAL HIT! [src] is knocked unconcious by the blow!</big></span>")
			apply_effect(10, PARALYZE)
			return

//Add screaming here.
/mob/living/carbon/human/IgniteMob()
	..()
	if(fire_stacks)
		agony_scream()