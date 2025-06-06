/datum
	var/weakref/weakref

//obtain a weak reference to a datum
/proc/weakref(datum/D)
	if(!istype(D))
		return
	if(QDELETED(D))
		return
	if(istype(D, /weakref))
		return D
	if(!D.weakref)
		D.weakref = new/weakref(D)
	return D.weakref

/weakref
	var/ref

	// Handy info for debugging
	var/ref_name
	var/ref_type

/weakref/New(datum/D)
	ref = "\ref[D]"
	ref_name = "[D]"
	ref_type = D.type

/weakref/Destroy()
	// A weakref datum should not be manually destroyed as it is a shared resource,
	//  rather it should be automatically collected by the BYOND GC when all references are gone.
	return QDEL_HINT_IWILLGC

/weakref/proc/resolve()
	var/datum/D = locate(ref)
	if(D && D.weakref == src)
		return D
	return null

/weakref/get_log_info_line()
	return "[ref_name] ([ref_type]) ([ref]) (WEAKREF)"
