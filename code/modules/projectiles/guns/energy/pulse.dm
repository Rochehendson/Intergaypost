/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A weapon that uses advanced pulse-based beam generation technology to emit powerful laser blasts. Because of its complexity and cost, it is rarely seen in use except by specialists."
	icon_state = "pulse"
	item_state = "pulse"
	slot_flags = SLOT_BACK
	force = 12
	projectile_type = /obj/item/projectile/beam/pulse/heavy
	max_shots = 36
	w_class = ITEM_SIZE_HUGE
	one_hand_penalty= 6
	multi_aim = 1
	burst_delay = 3
	burst = 3
	move_delay = 4
	accuracy = -1
	wielded_item_state = "gun_wielded"

/obj/item/weapon/gun/energy/pulse_rifle/carbine
	name = "pulse carbine"
	desc = "A military grade weapon that uses advanced pulse-based beam generation technology to emit powerful laser blasts."
	icon_state = "pulse_carbine"
	slot_flags = SLOT_BACK|SLOT_BELT
	force = 8
	projectile_type = /obj/item/projectile/beam/pulse/mid
	max_shots = 24
	w_class = ITEM_SIZE_LARGE
	one_hand_penalty= 3
	burst_delay = 2
	move_delay = 2

/obj/item/weapon/gun/energy/pulse_rifle/pistol
	name = "pulse pistol"
	desc = "A military grade weapon that uses advanced pulse-based beam generation technology to emit powerful laser blasts."
	icon_state = "pulse_pistol"
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	force = 6
	projectile_type = /obj/item/projectile/beam/pulse
	max_shots = 21
	w_class = ITEM_SIZE_NORMAL
	one_hand_penalty=1 //a bit heavy
	burst_delay = 1
	move_delay = 1
	wielded_item_state = null

/obj/item/weapon/gun/energy/pulse_rifle/mounted
	self_recharge = 1
	use_external_power = 1

/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon. Because of its complexity and cost, it is rarely seen in use except by specialists."
	power_supply = /obj/item/weapon/cell/super
	fire_delay = 25
	projectile_type=/obj/item/projectile/beam/pulse/destroy
	charge_cost= 40

/obj/item/weapon/gun/energy/pulse_rifle/destroyer/attack_self(mob/living/user as mob)
	to_chat(user, "<span class='warning'>[src.name] has three settings, and they are all DESTROY.</span>")

/obj/item/weapon/gun/energy/pulse_rifle/bogani
	name = "pulsar cannon"
	desc = "An alien weapon never before seen by the likes of your species."
	icon_state = "bog_rifle"
	item_state = "bog_rifle"
	wielded_item_state = "bog_rifle-wielded"
	projectile_type = /obj/item/projectile/beam/pulse/bogani
	max_shots = 100 //Don't want it to run out
	icon_rounder = 20