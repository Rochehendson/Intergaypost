/datum/preferences
	var/list/alternate_languages //Secondary language(s)

/datum/category_item/player_setup_item/general/language
	name = "Language"
	sort_order = 2

/datum/category_item/player_setup_item/general/language/load_character(var/savefile/S)
	S["language"]			>> pref.alternate_languages

/datum/category_item/player_setup_item/general/language/save_character(var/savefile/S)
	S["language"]			<< pref.alternate_languages

/datum/category_item/player_setup_item/general/language/sanitize_character()
	if(!islist(pref.alternate_languages))	pref.alternate_languages = list()
	sanitize_alt_languages()

/datum/category_item/player_setup_item/general/language/content()
	. += "<b>Languages</b><br>"
	var/datum/species/S = all_species[pref.species]
	if(S.language)
		. += "- [S.language]<br>"
	if(S.default_language && S.default_language != S.language)
		. += "- [S.default_language]<br>"
	if(S.num_alternate_languages)
		if(pref.alternate_languages.len)
			for(var/i = 1 to pref.alternate_languages.len)
				var/lang = pref.alternate_languages[i]
				. += "- [lang] - <a href='byond://?src=\ref[src];remove_language=[i]'>remove</a><br>"

		if(pref.alternate_languages.len < S.num_alternate_languages)
			. += "- <a href='byond://?src=\ref[src];add_language=1'>add</a> ([S.num_alternate_languages - pref.alternate_languages.len] remaining)<br>"
	else
		. += "- [pref.species] cannot choose secondary languages.<br>"

/datum/category_item/player_setup_item/general/language/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["remove_language"])
		var/index = text2num(href_list["remove_language"])
		pref.alternate_languages.Cut(index, index+1)
		return TOPIC_REFRESH
	else if(href_list["add_language"])
		var/datum/species/S = all_species[pref.species]
		if(pref.alternate_languages.len >= S.num_alternate_languages)
			alert(user, "You have already selected the maximum number of alternate languages for this species!")
		else
			var/preference_mob = preference_mob()
			var/list/available_languages = S.secondary_langs.Copy()
			for(var/L in all_languages)
				var/datum/language/lang = all_languages[L]
				if(is_allowed_language(preference_mob, lang))
					available_languages |= L

			// make sure we don't let them waste slots on the default languages
			available_languages -= S.language
			available_languages -= S.default_language
			available_languages -= pref.alternate_languages

			if(!available_languages.len)
				alert(user, "There are no additional languages available to select.")
			else
				var/new_lang = input(user, "Select an additional language", "Character Generation", null) as null|anything in available_languages
				if(new_lang)
					pref.alternate_languages |= new_lang
					sanitize_alt_languages()
					return TOPIC_REFRESH
	return ..()

/datum/category_item/player_setup_item/general/language/proc/is_allowed_language(var/mob/user, var/datum/language/lang)
	if(!user)
		return TRUE
	var/datum/species/S = all_species[pref.species] || all_species[SPECIES_HUMAN]
	if(lang.name in S.secondary_langs)
		return TRUE
	if(!(lang.flags & RESTRICTED) && is_alien_whitelisted(user, lang))
		return TRUE
	return FALSE

/datum/category_item/player_setup_item/general/language/proc/sanitize_alt_languages()
	if(!istype(pref.alternate_languages)) pref.alternate_languages = list()

	var/preference_mob = preference_mob()
	for(var/L in pref.alternate_languages)
		var/datum/language/lang = all_languages[L]
		if(!lang || !is_allowed_language(preference_mob, lang))
			pref.alternate_languages -= L

	var/datum/species/S = all_species[pref.species] || all_species[SPECIES_HUMAN]
	if(pref.alternate_languages.len > S.num_alternate_languages)
		pref.alternate_languages.Cut(S.num_alternate_languages + 1)

	pref.alternate_languages = uniquelist(pref.alternate_languages)
