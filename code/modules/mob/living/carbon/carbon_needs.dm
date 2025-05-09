/mob/living/carbon/proc/print_happiness(var/mob/living/carbon/human/H)
	var/msg = "\n<div class='firstdiv'><div class='box'>"
	msg += "<span class='info'>I am a follower of </span><font color='red'>[religion]</font>.\n"
	msg += "<span class='info'>I still remember my name, it's </span><font color='green'>[real_name].</font>\n"
	msg += "<span class='info'>I believe I am </span><font color='red'>[H.age]</font> <span class='info'>years old.</span>\n"
	msg += "<span class='info'>Everyone knows that I am </span>[get_social_class()].\n"
	msg += "<span class='info'>I am a </span><font color='blue'>[H.gender]</font>, <span class='info'>as well.</span>\n"
	if(nuisance)
		msg += "<br><span class='info'>I specialize in <span class='danger'>[nuisance.name].</span></span>\n"
	msg += "<hr class='linexd'>"
	msg += "<span class='info'><EM>Current mood:</EM></span><br>\n"
	for(var/i in events)
		var/datum/happiness_event/event = events[i]
		msg += event.description

	if(!events.len)
		msg += "<span class='info'>I feel indifferent.</span>\n"
	else if(happiness < MOOD_LEVEL_SAD2)
		msg += "<span class='warning'>I am stressed out!</span>\n"

	msg += "<hr class='linexd'>"

	if(trait)
		msg += 	"<br><span class='info'>I am <span class='danger'>[trait.name]</span>. [trait.description]</span>\n"
	if(quirk)//NOT THE SAME THING AS TRAITS
		msg += "<span class='info'>I am also <span class='danger'>[quirk.name]</span>. [quirk.description]</span>\n"
	if(sin)
		msg += 	"<br><span class='info'>My sin is <span class='danger'>[sin.name].</span></span>\n"
	if(virtue)
		msg += "<br><span class='info'>But my virtue is <span class='danger'>[virtue.name].</span></span>\n"

	msg += "</div></div>"
	to_chat(src, msg)

/mob/living/carbon/proc/update_happiness()
	var/old_happiness = happiness
	var/old_icon = null
	if(happiness_icon)
		old_icon = happiness_icon.icon_state
	happiness = 0
	for(var/i in events)
		var/datum/happiness_event/event = events[i]
		happiness += event.happiness

	switch(happiness)
		if(-5000000 to MOOD_LEVEL_SAD4)
			if(happiness_icon)
				happiness_icon.icon_state = "mood7"

		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			if(happiness_icon)
				happiness_icon.icon_state = "mood6"

		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			if(happiness_icon)
				happiness_icon.icon_state = "mood5"

		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			if(happiness_icon)
				happiness_icon.icon_state = "mood5"

		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			if(happiness_icon)
				happiness_icon.icon_state = "mood4"

		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			if(happiness_icon)
				happiness_icon.icon_state = "mood4"

		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			if(happiness_icon)
				happiness_icon.icon_state = "mood3"

		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			if(happiness_icon)
				happiness_icon.icon_state = "mood2"

		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			if(happiness_icon)
				happiness_icon.icon_state = "mood1"

	if(old_icon && old_icon != happiness_icon.icon_state)
		if(old_happiness > happiness)
			to_chat(src, "<span class='warning'>My mood gets worse.</span>")
		else
			to_chat(src, "<span class='info'>My mood gets better.</span>")

/mob/proc/flash_sadness()
	if(prob(2))
		flick("sadness",pain)
		var/spoopysound = pick('sound/effects/badmood1.ogg','sound/effects/badmood2.ogg','sound/effects/badmood3.ogg','sound/effects/badmood4.ogg')
		sound_to(src, spoopysound)

/mob/living/carbon/proc/handle_happiness()
	if(happiness > MOOD_LEVEL_SAD4)
		if(horror_loop)
			to_chat(src, "<span class='phobia'>My nerves relax some... I can think clearly again...</span>")
			sound_to(src, sound(null, repeat = 1, wait = 0, volume = 50, channel = 6))
			horror_loop = FALSE
			clear_fullscreen("freakout", /obj/screen/fullscreen/freakout)

	switch(happiness)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			do_stress_effects()
			flash_sadness()
			crit_mood_modifier = -10
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			flash_sadness()
			crit_mood_modifier = -5
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY2)
			crit_mood_modifier = CRIT_SUCCESS_NORM
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			crit_mood_modifier = 5
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			crit_mood_modifier = 10

/mob/living/carbon/proc/do_stress_effects()
	return

/mob/living/carbon/human/do_stress_effects()
	if(!horror_loop)
		freakout_emote()
		sound_to(src, sound('sound/effects/White_noise.ogg', repeat = 1, wait = 0, volume = 25, channel = 6))
		horror_loop = TRUE
		overlay_fullscreen("freakout", /obj/screen/fullscreen/freakout)
		to_chat(src, "<span class='phobia'<big>NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL NOT REAL</big></span>")
	stuttering = 5
	shake_camera(src, 5, 0.1)


/mob/living/carbon/proc/add_event(category, type) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	var/datum/happiness_event/the_event
	if(events[category])
		the_event = events[category]
		if(the_event.type != type)
			clear_event(category)
			return .()
		else
			return 0 //Don't have to update the event.
	else
		the_event = new type()

	events[category] = the_event
	update_happiness()

	if(the_event.timeout)
		spawn(the_event.timeout)
			clear_event(category)

/mob/living/carbon/proc/clear_event(category)
	var/datum/happiness_event/event = events[category]
	if(!event)
		return 0

	events -= category
	qdel(event)
	update_happiness()

/mob/living/carbon/proc/handle_hygiene()
	adjust_hygiene(-my_hygiene_factor)
	var/image/smell = image('icons/effects/effects.dmi', "smell")//This is a hack, there has got to be a safer way to do this but I don't know it at the moment.
	switch(hygiene)
		if(HYGIENE_LEVEL_NORMAL to INFINITY)
			add_event("hygiene", /datum/happiness_event/hygiene/clean)
			overlays -= smell
		if(HYGIENE_LEVEL_DIRTY to HYGIENE_LEVEL_NORMAL)
			clear_event("hygiene")
			overlays -= smell
		if(0 to HYGIENE_LEVEL_DIRTY)
			overlays -= smell
			overlays += smell
			add_event("hygiene", /datum/happiness_event/hygiene/smelly)

/mob/living/carbon/proc/adjust_hygiene(var/amount)
	var/old_hygiene = hygiene
	if(amount>0)
		hygiene = min(hygiene+amount, HYGIENE_LEVEL_CLEAN)

	else if(old_hygiene)
		hygiene = max(hygiene+amount, 0)

/mob/living/carbon/proc/set_hygiene(var/amount)
	if(amount >= 0)
		hygiene = min(HYGIENE_LEVEL_CLEAN, amount)

/mob/living/carbon/proc/adjust_thirst(var/amount)
	var/old_thirst = thirst
	if(amount>0)
		thirst = min(thirst+amount, THIRST_LEVEL_MAX)

	else if(old_thirst)
		thirst = max(thirst+amount, 0)

/mob/living/carbon/proc/set_thirst(var/amount)
	if(amount >= 0)
		thirst = min(THIRST_LEVEL_MAX, amount)