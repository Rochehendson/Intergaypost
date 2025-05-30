// Pre-made cassetes
/obj/item/music_tape/cosmic
	name = "tape - \"Cosmic\""
	track = new /datum/track("Cosmic", 'sound/jukebox/barsong5.ogg')
	rewrites_left = 0

/obj/item/music_tape/starter
	name = "tape - \"Firestarter\""
	track = new /datum/track("Firestarter", 'sound/jukebox/barsong1.ogg')
	rewrites_left = 0

/obj/item/music_tape/custom
	name = "dusty tape"
	desc = "A dusty tape, which can hold anything. Only what you need is blow the dust away and you will be able to play it again."

/obj/item/music_tape/custom/attack_self(mob/user)
	if(!ruined && !track)
		if(setup_tape(user))
			log_and_message_admins("uploaded new sound <a href='byond://?_src_=holder;listen_tape_sound=\ref[track.GetTrack()]'>(preview)</a> in <a href='byond://?_src_=holder;adminplayerobservefollow=\ref[src]'>\the [src]</a> with track name \"[track.title]\". <a href='byond://?_src_=holder;wipe_tape_data=\ref[src]'>Wipe</A> data.")
		return
	..()

/obj/item/music_tape/custom/proc/setup_tape(mob/user)
	var/new_sound = input(user, "Select a sound to upload. You should use only those audio formats which are supported by BYOND. .ogg and .midi files are usually a good choice.", "Song Reminiscence: File") as null|sound
	if(isnull(new_sound))
		return FALSE

	var/new_name = input(user, "Name \the [src]:", "Song Reminiscence: Name", "Untitled") as null|text
	if(isnull(new_name))
		return FALSE

	new_name = sanitizeSafe(new_name)

	SetName("tape - \"[new_name]\"")

	if(new_sound && new_name && !track)
		track = new /datum/track(new_name, new_sound)
		uploader_ckey = user.ckey
		return TRUE
	return FALSE

/obj/item/music_tape/custom/ruin()
	QDEL_NULL(track)
	..()