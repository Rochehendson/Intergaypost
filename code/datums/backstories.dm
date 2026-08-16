/**
 * Backstory datums and JSON auto-parser system
 * Loads backstory definitions dynamically from JSON files in config/backstories/
 */

GLOBAL_LIST_EMPTY(all_backstories)
GLOBAL_LIST_EMPTY(all_backstories_by_id)
GLOBAL_LIST_EMPTY(all_backstory_names)

/datum/backstory
	var/id = "none"
	var/name = "None"
	var/category = "General"
	var/desc = "No specific background."
	var/fluff = ""
	var/suggested_faction = ""
	var/suggested_home_system = ""
	var/suggested_citizenship = ""
	var/suggested_records = ""

/datum/backstory/proc/load_from_json_data(var/list/data)
	if(!islist(data))
		return FALSE
	if(data["id"])
		id = data["id"]
	if(data["name"])
		name = data["name"]
	if(data["category"])
		category = data["category"]
	if(data["desc"])
		desc = data["desc"]
	if(data["fluff"])
		fluff = data["fluff"]
	if(data["suggested_faction"])
		suggested_faction = data["suggested_faction"]
	if(data["suggested_home_system"])
		suggested_home_system = data["suggested_home_system"]
	if(data["suggested_citizenship"])
		suggested_citizenship = data["suggested_citizenship"]
	if(data["suggested_records"])
		suggested_records = data["suggested_records"]
	return TRUE

/proc/load_backstories_from_json(var/directory = "config/backstories/")
	GLOB.all_backstories.Cut()
	GLOB.all_backstories_by_id.Cut()
	GLOB.all_backstory_names.Cut()

	// Always provide standard "None" fallback
	var/datum/backstory/none/BS_none = new()
	GLOB.all_backstories[BS_none.name] = BS_none
	GLOB.all_backstories_by_id[BS_none.id] = BS_none
	GLOB.all_backstory_names += BS_none.name

	var/list/files = flist(directory)
	for(var/filename in files)
		// Check for .json extension
		if(length(filename) < 5 || copytext(filename, -4) != "json")
			continue
		var/filepath = "[directory][filename]"
		var/raw_text = file2text(filepath)
		if(!raw_text)
			continue
		var/list/json_data = json_decode(raw_text)
		if(!islist(json_data))
			continue
		var/datum/backstory/BS = new()
		if(BS.load_from_json_data(json_data))
			GLOB.all_backstories[BS.name] = BS
			GLOB.all_backstories_by_id[BS.id] = BS
			GLOB.all_backstory_names |= BS.name

	return GLOB.all_backstories

/proc/get_all_backstories()
	if(!GLOB.all_backstories || !GLOB.all_backstories.len)
		load_backstories_from_json()
	return GLOB.all_backstories

/proc/get_all_backstory_names()
	if(!GLOB.all_backstories || !GLOB.all_backstories.len)
		load_backstories_from_json()
	return GLOB.all_backstory_names

/proc/get_backstory(var/name_or_id)
	if(!name_or_id)
		return null
	if(!GLOB.all_backstories || !GLOB.all_backstories.len)
		load_backstories_from_json()
	if(GLOB.all_backstories[name_or_id])
		return GLOB.all_backstories[name_or_id]
	if(GLOB.all_backstories_by_id[name_or_id])
		return GLOB.all_backstories_by_id[name_or_id]
	return null

/datum/backstory/none
	id = "none"
	name = "None"
	category = "General"
	desc = "No specific background. Blank slate."
	fluff = "A person of standard background, without remarkable ties to any specific institution, colony, or faction."
