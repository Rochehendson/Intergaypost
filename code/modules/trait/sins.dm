/datum/sin
	var/name = "Default Sin"
	var/description = "A default sin."

/datum/sin/lust
	name = "lust"
	description = "I lust for the flesh of women."

/datum/sin/gluttony
	name = "gluttony"
	description = "I like to eat A LOT."

/datum/sin/greed
	name = "greed"
	description = "We need money, a lot of money."

/datum/sin/sloth
	name = "sloth"
	description = "Doing work is a fool's game."

/datum/sin/wrath
	name = "wrath"
	description = "DON'T FUCK AROUND WITH ME!"

/datum/sin/envy
	name = "envy"
	description = "That captain sure has a nicer salary than me..."

/datum/sin/pride
	name = "pride"
	description = "I am so proud of my own accomplishments!"

/mob/living/proc/has_sin(var/datum/sin/this_sin)
	return istype(sin, this_sin)

/mob/living/proc/set_sin(var/datum/sin/set_sin)
	sin = set_sin

/mob/living/proc/remove_sin()
	sin = null
