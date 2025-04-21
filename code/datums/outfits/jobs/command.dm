/decl/hierarchy/outfit/job/captain
	name = OUTFIT_JOB_NAME("Captain")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/gold
	pda_type = /obj/item/device/pda/captain

/decl/hierarchy/outfit/job/captain/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack]      = /obj/item/weapon/storage/backpack/captain
	backpack_overrides[/decl/backpack_outfit/satchel]       = /obj/item/weapon/storage/backpack/satchel_cap
	backpack_overrides[/decl/backpack_outfit/messenger_bag] = /obj/item/weapon/storage/backpack/messenger/com

/decl/hierarchy/outfit/job/captain/post_equip(var/mob/living/carbon/human/H)
	..()
	if(H.age>49)
		// Since we can have something other than the default uniform at this
		// point, check if we can actually attach the medal
		var/obj/item/clothing/uniform = H.w_uniform
		if(uniform)
			var/obj/item/clothing/accessory/medal/gold/nanotrasen/medal = new()
			if(uniform.can_attach_accessory(medal))
				uniform.attach_accessory(null, medal)
			else
				qdel(medal)

/decl/hierarchy/outfit/job/hop
	name = OUTFIT_JOB_NAME("Head of Personnel")
	l_ear = null
	uniform = null
	shoes = null
	head = null
	suit = null
	id_type = /obj/item/weapon/card/id/silver
	pda_type = /obj/item/device/pda/heads/hop
