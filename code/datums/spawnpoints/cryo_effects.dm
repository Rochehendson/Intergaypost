/mob/living/carbon/human/proc/give_cryo_effect()
	var/message = ""
	if(prob(20)) //starvation
		message += "<span class='info'>It seems like you forgot to eat before getting 'buried' in the chamber...\n</span>"
		set_nutrition(rand(100,200))
		set_thirst(rand(100,200))
	if(prob(15)) //stutterting and jittering (because of cold?)
		message += "<span class='info'>This cold is making me jittery... </span>\n"
		make_jittery(120)
		stuttering = 20
	if(prob(15)) //vomit
		message += "<span class='info'>I want to vomit... </span>\n"
		vomit()
	if(!message)
		message += "<span class='notice'>It seems like there weren't any bad effects today...but I couldn't sleep properly anyway. </span>\n"
	else
		message += "<span class='info'>Can't even sleep or live properly here... </span>\n"
	to_chat(src, "[message]")
	return TRUE

/mob/living/carbon/human/proc/give_cryo_captain_effect()
	var/message = ""
	if(prob(20)) //starvation
		message += "<span class='info'>It seems like I forgot to eat before getting 'buried' in the chamber...[rand(20,60)] years of working as a Captain and still no brain. </span>"
		set_nutrition(rand(100,200))
		set_thirst(rand(100,200))
	if(prob(15)) //stutterting and jittering (because of cold?)
		message += "<span class='info'>This cold is making me jittery... </span>"
		make_jittery(120)
		stuttering = 20
	if(prob(15)) //vomit
		message += "<span class='info'>I want to vomit... </span>"
		vomit()
	if(!message)
		message += "<span class='notice'>It seems like there weren't any bad effects today...but I couldn't sleep properly anyway. </span>"
	else
		message += "<span class='info'>Can't even sleep or live properly here... </span>"
	to_chat(src, "[message]")
	return TRUE