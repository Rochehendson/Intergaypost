/*
=== Item Click Call Sequences ===
These are the default click code call sequences used when clicking on stuff with an item.

Atoms:

mob/ClickOn() calls the item's resolve_attackby() proc.
item/resolve_attackby() calls the target atom's attackby() proc.

Mobs:

mob/living/attackby() after checking for surgery, calls the item's attack() proc.
item/attack() generates attack logs, sets click cooldown and calls the mob's attacked_with_item() proc. If you override this, consider whether you need to set a click cooldown, play attack animations, and generate logs yourself.
mob/attacked_with_item() should then do mob-type specific stuff (like determining hit/miss, handling shields, etc) and then possibly call the item's apply_hit_effect() proc to actually apply the effects of being hit.

Item Hit Effects:

item/apply_hit_effect() can be overriden to do whatever you want. However "standard" physical damage based weapons should make use of the target mob's hit_with_weapon() proc to
avoid code duplication. This includes items that may sometimes act as a standard weapon in addition to having other effects (e.g. stunbatons on harm intent).
*/

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

//I would prefer to rename this to attack(), but that would involve touching hundreds of files.
/obj/item/proc/resolve_attackby(atom/A, mob/user, var/click_params)
	if(obj_flags & OBJ_FLAG_ABSTRACT)//Abstract items cannot be interacted with. They're not real.
		return 1
	if(!(item_flags & ITEM_FLAG_NO_PRINT))
		add_fingerprint(user)
	return A.attackby(src, user, click_params)

// No comment
/atom/proc/attackby(obj/item/W, mob/user, var/click_params)
	return

/atom/movable/attackby(obj/item/W, mob/user)
	if(!(W.item_flags & ITEM_FLAG_NO_BLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user)
	if(!ismob(user))
		return 0
	if(can_operate(src,user) && I.do_surgery(src,user)) //Surgery
		return 1
	return I.attack(src, user, user.zone_sel.selecting)

/mob/living/carbon/human/attackby(obj/item/I, mob/user)
	if(user == src && src.zone_sel.selecting == BP_MOUTH)
		var/obj/item/blocked = src.check_mouth_coverage()
		if(blocked)
			to_chat(user, "<span class='warning'>\The [blocked] is in the way!</span>")
			return 1
		else if(devour(I))
			return 1
	return ..()

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

//I would prefer to rename this attack_as_weapon(), but that would involve touching hundreds of files.
/obj/item/proc/attack(mob/living/M, mob/living/user, var/target_zone)
	if(!force || (item_flags & ITEM_FLAG_NO_BLUDGEON))
		return 0
	if(M == user && user.a_intent != I_HURT)
		return 0

	if(user.staminaloss >= STAMINA_EXHAUST)//Can't attack people if you're out of stamina.
		return 0

	if(world.time <= next_attack_time)
		if(world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>The [src] is not ready to attack again!</span>")
		return 0

	/////////////////////////

	if(!no_attack_log)
		admin_attack_log(user, M, "Attacked using \a [src] (DAMTYE: [uppertext(damtype)])", "Was attacked with \a [src] (DAMTYE: [uppertext(damtype)])", "used \a [src] (DAMTYE: [uppertext(damtype)]) to attack")
	/////////////////////////

	var/cooldown_modifier = user.c_intent == I_QUICK ? -4 : 0 //Quick mode lowers attack cooldown by 1/2th
	cooldown_modifier += user.c_intent == I_AIM ? 4 : 0 //Aim mode raise attack cooldown by 1/2th
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN + cooldown_modifier)

	//user.do_attack_animation(M)
	if(!user.aura_check(AURA_TYPE_WEAPON, src, user))
		return 0

	var/combat_mode_stam_modifier = user.c_intent == I_STRONG ? 7 : 0 //If they are attacking strong, they lose more stam
	if(force)
		user.adjustStaminaLoss(w_class + 3 + combat_mode_stam_modifier )

	if(swing_sound)
		playsound(M, swing_sound, 50, 1, -1)

	var/hit_zone = M.resolve_item_attack(src, user, target_zone)
	if(hit_zone)
		apply_hit_effect(M, user, hit_zone)

	next_attack_time = world.time + (weapon_speed_delay)//by default, that's 25 - 10. Which is 15. Which should be what the average attack is. People who are weaker will swing heavy objects slower.

	return 1

//Called when a weapon is used to make a successful melee attack on a mob. Returns the blocked result
/obj/item/proc/apply_hit_effect(mob/living/target, mob/living/user, var/hit_zone)
	if(hitsound)
		playsound(loc, hitsound, 50, 1, -1)

	var/power = force
	if(HULK in user.mutations)
		power *= 2
	return target.hit_with_weapon(src, user, power, hit_zone)

