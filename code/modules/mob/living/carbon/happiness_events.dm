/datum/happiness_event
	var/description
	var/happiness = 0
	var/timeout = 0

///For descriptions, use the span classes bold info, info, none, warning and boldwarning in order from great to horrible.

//thirst
/datum/happiness_event/thirst/filled
	description = "<span class='info'>I've had enough to drink for a while!</span>\n"
	happiness = 4

/datum/happiness_event/thirst/watered
	description = "<span class='info'>I have recently had something to drink.</span>\n"
	happiness = 2

/datum/happiness_event/thirst/thirsting
	description = "<span class='danger'>I'm starting to get thirsty.</span>\n"
	happiness = -3

/datum/happiness_event/thirst/thirsty
	description = "<span class='danger'>I'm getting a bit thirsty.</span>\n"
	happiness = -7

/datum/happiness_event/thirst/verythirsty
	description = "<span class='danger'>I'm getting thirsty!</span>\n"
	happiness = -10

/datum/happiness_event/thirst/dehydrated
	description = "<span class='danger'>I NEED WATER!</span>\n"
	happiness = -14

//nutrition
/datum/happiness_event/nutrition/fat
	description = "<span class='danger'><B>I'm so fat..</B></span>\n" //muh fatshaming
	happiness = -4

/datum/happiness_event/nutrition/wellfed
	description = "<span class='info'>My belly feels round and full.</span>\n"
	happiness = 4

/datum/happiness_event/nutrition/fed
	description = "<span class='info'>I have recently had some food.</span>\n"
	happiness = 2

/datum/happiness_event/nutrition/lilhungry
	description = "<span class='danger'>I'm getting a bit hungry.</span>\n"
	happiness = -2

/datum/happiness_event/nutrition/hungry
	description = "<span class='danger'>I'm getting hungry...</span>\n"
	happiness = -5

/datum/happiness_event/nutrition/veryhungry
	description = "<span class='danger'>I'm getting really hungry!</span>\n"
	happiness = -8

/datum/happiness_event/nutrition/starving
	description = "<span class='danger'>I WANT FOOD!</span>\n"
	happiness = -12


//Hygiene
/datum/happiness_event/hygiene/clean
	description = "<span class='info'>I feel so clean!\n"
	happiness = 2

/datum/happiness_event/hygiene/smelly
	description = "<span class='danger'>I smell like shit.\n"
	happiness = -5

/datum/happiness_event/hygiene/vomitted
	description = "<span class='danger'>Ugh, I've vomitted.\n"
	happiness = -5
	timeout = 1800

/datum/happiness_event/hygiene/shower
	description = "<span class='info'>I had a nice hot shower!\n"
	happiness = 5
	timeout = 1800

/datum/happiness_event/disgust/nocutlery
	description = "<span class='danger'>Did I really have to eat without any utensils?\n"
	happiness = -4
	timeout = 1800

//Disgust
/datum/happiness_event/disgust/gross
	description = "<span class='danger'>That was gross.</span>\n"
	happiness = -2
	timeout = 1800

/datum/happiness_event/disgust/verygross
	description = "<span class='danger'>I think I'm going to puke...</span>\n"
	happiness = -4
	timeout = 1800

/datum/happiness_event/disgust/disgusted
	description = "<span class='danger'>Oh god that's disgusting...</span>\n"
	happiness = -6
	timeout = 1800

//Generic events
/datum/happiness_event/favorite_food
	description = "<span class='info'>I really liked eating that.</span>\n"
	happiness = 3
	timeout = 2400

/datum/happiness_event/nice_shower
	description = "<span class='info'>I had a nice shower.</span>\n"
	happiness = 1
	timeout = 1800

/datum/happiness_event/handcuffed
	description = "<span class='danger'>I guess my antics finally caught up with me..</span>\n"
	happiness = -1

/datum/happiness_event/hot_food //Hot food feels good!
	description = "<span class='info'>I've eaten something warm.</span>\n"
	happiness = 3
	timeout = 1800

/datum/happiness_event/cold_drink //Cold drinks feel good!
	description = "<span class='info'>I've had something refreshing.</span>\n"
	happiness = 3
	timeout = 1800

//Embarassment
/datum/happiness_event/hygiene/shit
	description = "<span class='danger'>I shit myself. How embarassing.\n"
	happiness = -12
	timeout = 1800

/datum/happiness_event/hygiene/pee
	description = "<span class='danger'>I pissed myself. How embarassing.\n"
	happiness = -12
	timeout = 1800

//For when you get branded.
/datum/happiness_event/humiliated
	description = "<span class='danger'>I've been humiliated, and I am embarrassed.</span>\n"
	happiness = -10
	timeout = 1800

//And when you've seen someone branded
/datum/happiness_event/punished_heretic
	description = "<span class='info'>I've seen a punished heretic.</span>\n"
	happiness = 10
	timeout = 1800

//When you fulfill an AI request
/datum/happiness_event/request_fulfilled
	description = "<span class='info'>My god is pleased with me!</span>\n"
	happiness = 10
	timeout = 1800

//When you fulfill an AI request
/datum/happiness_event/request_failed
	description = "<span class='danger'>My god is disappointed with me!</span>\n"
	happiness = -20
	timeout = 1800

/datum/happiness_event/disturbing
	description = "<span class='danger'>I recently saw something disturbing.</span>\n"
	happiness = -2

/datum/happiness_event/clown
	description = "<span class='info'>I recently saw a funny clown!</span>\n"
	happiness = 1

/datum/happiness_event/cloned_corpse
	description = "<span class='danger'>I recently saw my own corpse...</span>\n"
	happiness = -6

/datum/happiness_event/surgery
	description = "<span class='danger'>HE'S CUTTING ME OPEN!!</span>\n"
	happiness = -8

/datum/happiness_event/bleedingout
	description = "<span class='danger'>I feel that I am bleeding out...</span>\n"
	happiness = -4
	timeout = 1800

/datum/happiness_event/bleedingouthard
	description = "<span class='danger'>I REALLY NEED TO STOP THIS BLEEDING!</span>\n"
	happiness = -6
	timeout = 1800

/datum/happiness_event/verymildpain
	description = "<span class='danger'>I feel some pain...</span>\n"
	happiness = -2
	timeout = 1800

/datum/happiness_event/mildpain
	description = "<span class='danger'>It hurts...a lot.</span>\n"
	happiness = -4
	timeout = 1800

/datum/happiness_event/pain
	description = "<span class='danger'>IT HURTS SO MUCH!</span>\n"
	happiness = -6
	timeout = 1800

/datum/happiness_event/cryo
	description = "<span class='danger'>Being in a metal coffin for so long doesn't feel good.</span>\n"
	happiness = -3
	timeout = 1800

//For when you see someone die and you're not hardcore.
/datum/happiness_event/dead
	description = "<span class='danger'>OH MY GOD THEY'RE DEAD!</span>\n"
	happiness = -10
	timeout = 5 MINUTES

/datum/happiness_event/overdose
	description = "<span class='danger'>I shouldn't have taken so much drugs!</span>\n"
	happiness = -15
	timeout = 1800

// Addiction Events

/datum/happiness_event/addiction/withdrawal_small
	description = "<span class='danger'>I don't indulge in my addiction.</span>\n"
	happiness = -3
	timeout = FALSE

/datum/happiness_event/addiction/withdrawal_medium
	description = "<span class='danger'>I don't indulge in my addiction, that makes me unhappy!</span>\n"
	happiness = -5
	timeout = FALSE

/datum/happiness_event/addiction/withdrawal_large
	description = "<span class='danger'>I don't indulge in my addiction, that makes me very unhappy!</span>\n"
	happiness = -10
	timeout = FALSE

/datum/happiness_event/addiction/withdrawal_extreme
	description = "<span class='danger'>I DON'T INDULGE IN MY ADDICTION, MY DAY IS SHIT!</span>\n"
	happiness = -12
	timeout = FALSE

/datum/happiness_event/high
	description = "<span class='binfo'>I'm high as fuck!</span>\n"
	happiness = 12

/datum/happiness_event/relaxed
	description = "<span class='binfo'>That cigarette was good.</span>\n"
	happiness = 10
	timeout = 1800

/datum/happiness_event/booze
	description = "<span class='binfo'>Alcohol makes the pain go away.</span>\n"
	happiness = 10
	timeout = 2400