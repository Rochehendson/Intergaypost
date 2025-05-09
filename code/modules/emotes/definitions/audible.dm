/decl/emote/audible
	key = "burp"
	emote_message_3p = "<span class='examinebold'>USER</span> burps."
	message_type = AUDIBLE_MESSAGE
	var/emote_sound

/decl/emote/audible/do_extra(var/mob/user)
	user.handle_emote_CD()
	if(emote_sound)
		playsound(user.loc, emote_sound, 50, 0)

/decl/emote/audible/deathgasp_alien
	key = "deathgasp"
	emote_message_3p = "<span class='examinebold'>USER</span> lets out a waning guttural screech, green blood bubbling from its maw."

/decl/emote/audible/whimper
	key ="whimper"

/decl/emote/audible/whimper/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/whimper_male[rand(1,3)].ogg"

	else
		emotesound = "sound/voice/emotes/whimper_female[rand(1,3)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"whimpers.")
	user.handle_emote_CD()

/decl/emote/audible/gasp
	key ="gasp"
	emote_message_3p = "<span class='examinebold'>USER</span> gasps."
	conscious = 0

/decl/emote/audible/scretch
	key ="scretch"
	emote_message_3p = "<span class='examinebold'>USER</span> scretches."

/decl/emote/audible/choke
	key ="choke"
	emote_message_3p = "<span class='examinebold'>USER</span> chokes."
	conscious = 0

/decl/emote/audible/gnarl
	key ="gnarl"
	emote_message_3p = "<span class='examinebold'>USER</span> gnarls and shows its teeth.."

/decl/emote/audible/chirp
	key ="chirp"
	emote_message_3p = "<span class='examinebold'>USER</span> chirps!"
	emote_sound = 'sound/misc/nymphchirp.ogg'

/decl/emote/audible/alarm
	key = "alarm"
	emote_message_1p = "You sound an alarm."
	emote_message_3p = "<span class='examinebold'>USER</span> sounds an alarm."

/decl/emote/audible/alert
	key = "alert"
	emote_message_1p = "You let out a distressed noise."
	emote_message_3p = "<span class='examinebold'>USER</span> lets out a distressed noise."

/decl/emote/audible/notice
	key = "notice"
	emote_message_1p = "You play a loud tone."
	emote_message_3p = "<span class='examinebold'>USER</span> plays a loud tone."

/decl/emote/audible/whistle
	key = "whistle"
	emote_message_1p = "You whistle."
	emote_message_3p = "<span class='examinebold'>USER</span> whistles."

/decl/emote/audible/boop
	key = "boop"
	emote_message_1p = "You boop."
	emote_message_3p = "<span class='examinebold'>USER</span> boops."

/decl/emote/audible/sneeze
	key = "sneeze"

/decl/emote/audible/sneeze/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/sneezem[rand(1,2)].ogg"

	else
		emotesound = "sound/voice/emotes/sneezef[rand(1,2)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"sneezes.")
	user.handle_emote_CD()


/decl/emote/audible/sniff
	key = "sniff"
	emote_message_3p = "<span class='examinebold'>USER</span> sniffs."
	emote_sound = 'sound/voice/emotes/sniff.ogg'

/decl/emote/audible/slap
	key = "slap"
	emote_message_3p = "<span class='examinebold'>USER</span> <span class='examine'>slaps his own face.</span>"
	emote_sound = 'sound/voice/emotes/slap.ogg'

/decl/emote/audible/snore
	key = "snore"
	emote_message_3p = "<span class='examinebold'>USER</span> snores."
	conscious = 0

/decl/emote/audible/whimper
	key = "whimper"
	emote_message_3p = "<span class='examinebold'>USER</span> whimpers."

/decl/emote/audible/yawn
	key = "yawn"

/decl/emote/audible/yawn/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/male_yawn[rand(1,2)].ogg"

	else
		emotesound = "sound/voice/emotes/female_yawn[rand(1,3)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"yawns.")
	user.handle_emote_CD()

/decl/emote/audible/clap
	key = "clap"
	emote_message_3p = "<span class='examinebold'>USER</span> claps."

/decl/emote/audible/chuckle
	key = "chuckle"
	emote_message_3p = "<span class='examinebold'>USER</span> chuckles."

/decl/emote/audible/cough
	key = "cough"
	conscious = 0

/decl/emote/audible/cough/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/male_cough[rand(1,4)].ogg"

	else
		emotesound = "sound/voice/emotes/female_cough[rand(1,6)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"coughs.")
	user.handle_emote_CD()

/decl/emote/audible/cry
	key = "cry"
	emote_message_3p = "<span class='examinebold'>USER</span> cries."

/decl/emote/audible/cry/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/male_cry[rand(1,2)].ogg"

	else
		emotesound = "sound/voice/emotes/female_cry[rand(1,2)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"cries.")
	user.handle_emote_CD()


/decl/emote/audible/sigh
	key = "sigh"

/decl/emote/audible/sigh/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = 'sound/voice/emotes/sigh_male.ogg'

	else
		emotesound = 'sound/voice/emotes/sigh_female.ogg'

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"sighs.")
	user.handle_emote_CD()

/decl/emote/audible/laugh
	key = "laugh"

/decl/emote/audible/laugh/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/male_laugh[rand(1,3)].ogg"

	else
		emotesound = "sound/voice/emotes/female_laugh[rand(1,3)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"laughs.")
	user.handle_emote_CD()

/decl/emote/audible/mumble
	key = "mumble"

/decl/emote/audible/charge
	key = "charge"

/decl/emote/audible/charge/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/angryscream2.ogg"

	else
		emotesound = "sound/voice/emotes/female_laugh[rand(1,3)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"charges.")
	user.handle_emote_CD()

/decl/emote/audible/hums
	key = "hums"

/decl/emote/audible/hums/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/malehumming.ogg"

	else
		emotesound = "sound/voice/emotes/femalehumming.ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"hums.")
	user.handle_emote_CD()

/decl/emote/audible/mumble/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = 'sound/voice/emotes/mumble_male.ogg'

	else
		emotesound = 'sound/voice/emotes/mumble_female.ogg'

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"mumbles.")
	user.handle_emote_CD()

/decl/emote/audible/grumble
	key = "grumble"

/decl/emote/audible/grumble/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = 'sound/voice/emotes/mumble_male.ogg'

	else
		emotesound = 'sound/voice/emotes/mumble_female.ogg'

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"grumbles.")
	user.handle_emote_CD()

/decl/emote/audible/groan
	key = "groan"
	emote_message_3p = "<span class='examinebold'>USER</span> groans!"
	conscious = 0

/decl/emote/audible/moan
	key = "moan"
	emote_message_3p = "<span class='examinebold'>USER</span> moans!"
	conscious = 0

/decl/emote/audible/giggle
	key = "giggle"

/decl/emote/audible/giggle/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == FEMALE)
		emotesound = "sound/voice/emotes/female_giggle[rand(1,2)].ogg"

	else
		emotesound = null

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"giggles.")
	user.handle_emote_CD()


/decl/emote/audible/hem
	key = "hem"

/decl/emote/audible/hem/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = 'sound/voice/emotes/hem_male.ogg'

	else
		emotesound = 'sound/voice/emotes/hem_female.ogg'

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"hems.")
	user.handle_emote_CD()

/decl/emote/audible/scream
	key = "scream"

/decl/emote/audible/scream/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = "sound/voice/emotes/male_scream[rand(1,2)].ogg"

	else
		emotesound = "sound/voice/emotes/female_scream[rand(1,2)].ogg"

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"screams!")
	user.handle_emote_CD()


/decl/emote/audible/clearthroat
	key = "clearthroat"

/decl/emote/audible/clearthroat/do_emote(var/mob/living/carbon/human/user)
	var/emotesound = null
	if(user.isMonkey())
		return

	else if(user.gender == MALE)
		emotesound = 'sound/voice/emotes/throatclear_male.ogg'

	else
		emotesound = 'sound/voice/emotes/throatclear_female.ogg'

	if(emotesound)
		playsound(user, emotesound, 50, 0, 1)

	user.custom_emote(2,"clears their throat.")
	user.handle_emote_CD()

/decl/emote/audible/grunt
	key = "grunt"
	emote_message_3p = "<span class='examinebold'>USER</span> grunts."

/decl/emote/audible/bug_hiss
	key ="hiss"
	emote_message_3p = "<span class='examinebold'>USER</span> hisses."
	emote_sound = 'sound/voice/BugHiss.ogg'

/decl/emote/audible/bug_buzz
	key ="buzz"
	emote_message_3p = "<span class='examinebold'>USER</span> buzzes its wings."
	emote_sound = 'sound/voice/BugBuzz.ogg'

/decl/emote/audible/bug_chitter
	key ="chitter"
	emote_message_3p = "<span class='examinebold'>USER</span> chitters."
	emote_sound = 'sound/voice/Bug.ogg'