/proc/index_all_personal_lockers()
	var/list/used_numbers = list()
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(L.locker_number > 0)
			used_numbers |= L.locker_number

	var/next_num = 1
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(!L.locker_number)
			while(next_num in used_numbers)
				next_num++
			L.locker_number = next_num
			used_numbers |= next_num
		L.update_locker_name()

/hook/roundstart/proc/setup_personal_lockers_index()
	index_all_personal_lockers()
	return 1

/proc/find_personal_locker_for(var/mob/living/carbon/human/H)
	if(!istype(H) || !H.ckey)
		return null

	// First check if already assigned to this player and character
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(L.registered_ckey == H.ckey && L.registered_name == H.real_name)
			return L

	// Next find an unassigned locker
	for(var/obj/structure/closet/secure_closet/personal_locker/L in GLOB.all_personal_lockers)
		if(!L.registered_ckey)
			return L

	return null

/proc/assign_personal_locker(var/mob/living/carbon/human/H)
	if(!istype(H) || !H.ckey || !H.real_name)
		return null

	index_all_personal_lockers()

	var/obj/structure/closet/secure_closet/personal_locker/L = find_personal_locker_for(H)
	if(!L)
		log_game("No free personal locker found for [H.name] ([H.ckey])")
		to_chat(H, "<span class='info'><b>Personal Storage:</b> No unassigned personal lockers are currently available on the station.</span>")
		return null

	var/already_registered = (L.registered_ckey == H.ckey && L.registered_name == H.real_name)
	L.registered_ckey = H.ckey
	L.registered_name = H.real_name
	L.update_locker_name()

	if(!already_registered)
		load_personal_locker_data(L, H.ckey, H.real_name)

	// Create and give the physical locker key
	var/obj/item/weapon/key/locker_key/K = new /obj/item/weapon/key/locker_key(null, L.lock_code, L.locker_number, H.real_name, H.ckey)
	var/given = FALSE

	if(H.equip_to_slot_if_possible(K, slot_r_store))
		given = TRUE
	else if(H.equip_to_slot_if_possible(K, slot_l_store))
		given = TRUE
	else if(H.put_in_hands(K))
		given = TRUE
	else if(istype(H.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = H.back
		if(S.handle_item_insertion(K, prevent_warning = 1, NoUpdate = 1))
			given = TRUE

	if(!given)
		K.forceMove(get_turf(H))

	to_chat(H, "<span class='notice'><b>Personal Storage:</b> You have been assigned personal locker #[L.locker_number]. Your locker key has been placed in your inventory.</span>")
	return L
