/datum/unit_test/backstory_json_loading
	name = "BACKSTORY: JSON loading and validation"

/datum/unit_test/backstory_json_loading/start_test()
	var/list/backstories = get_all_backstories()
	if(!backstories || !backstories.len)
		fail("No backstories loaded into registry.")
		return 1

	// Must at least contain "None" plus the 4 starting JSON backstories
	var/list/expected_backstories = list(
		"None",
		"Corporate Loyalist",
		"Frontier Colonist",
		"Academic Scholar",
		"Military Veteran"
	)

	var/missing_count = 0
	for(var/expected_name in expected_backstories)
		var/datum/backstory/BS = get_backstory(expected_name)
		if(!BS)
			log_bad("Missing expected backstory: [expected_name]")
			missing_count++
		else if(!BS.desc || !BS.category)
			log_bad("Backstory [expected_name] is missing desc or category.")
			missing_count++

	if(missing_count)
		fail("[missing_count] expected backstories missing or invalid.")
	else
		pass("All [expected_backstories.len] initial backstories loaded correctly ([backstories.len] total in registry).")

	return 1
