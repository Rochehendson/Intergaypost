// READ: Don't use the apostrophe in name or desc. Causes script errors.

var/list/powers = typesof(/datum/power/changeling) - /datum/power/changeling	//needed for the badmin verb for now
var/list/datum/power/changeling/powerinstances = list()

/datum/power			//Could be used by other antags too
	var/name = "Power"
	var/desc = "Placeholder"
	var/icon = "genetics_closed"
	var/helptext = ""
	var/isVerb = 1 	// Is it an active power, or passive?
	var/verbpath // Path to a verb that contains the effects.

/datum/power/changeling
	var/allowduringlesserform = 0
	var/genomecost = 500000 // Cost for the changling to evolve this power.

/datum/power/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human. They become one with us, and we become stronger."
	genomecost = 0
	verbpath = /mob/proc/changeling_absorb_dna

/datum/power/changeling/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	genomecost = 0
	verbpath = /mob/proc/changeling_transform

/datum/power/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death."
	helptext = "Can be used before or after death. Duration varies greatly."
	genomecost = 0
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_fakedeath

// Hivemind

/datum/power/changeling/hive_upload
	name = "Hive Channel"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	helptext = "Allows other changelings to absorb the DNA you channel from the airwaves. Will not help them towards their absorb objectives."
	genomecost = 0
	verbpath = /mob/proc/changeling_hiveupload

/datum/power/changeling/hive_download
	name = "Hive Absorb"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	helptext = "Allows you to absorb a single DNA and use it. Does not count towards your absorb objective."
	genomecost = 0
	verbpath = /mob/proc/changeling_hivedownload

/datum/power/changeling/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	genomecost = 4
	verbpath = /mob/proc/changeling_lesser_form

/datum/power/changeling/deaf_sting
	name = "Deaf Sting"
	desc = "We silently sting a human, completely deafening them for a short time."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_deaf_sting

/datum/power/changeling/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 2
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_blind_sting

/datum/power/changeling/silence_sting
	name = "Silence Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they have been stung, until they try to speak and cannot."
	genomecost = 3
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_silence_sting

/datum/power/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this"
	genomecost = 1
	verbpath = /mob/proc/changeling_mimicvoice

/datum/power/changeling/extractdna
	name = "Extract DNA"
	desc = "We stealthily sting a target and extract the DNA from them."
	helptext = "Will give you the DNA of your target, allowing you to transform into them. Does not count towards absorb objectives."
	genomecost = 2
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_extract_dna_sting

/datum/power/changeling/transformation_sting
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	genomecost = 3
	verbpath = /mob/proc/changeling_transformation_sting
	icon = "sting_transform"

/datum/power/changeling/paralysis_sting
	name = "Paralysis Sting"
	desc = "We silently sting a human, paralyzing them for a short time."
	genomecost = 8
	verbpath = /mob/proc/changeling_paralysis_sting
	icon = "ling_para"

/datum/power/changeling/LSDSting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallunicationary chemical."
	helptext = "The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	genomecost = 3
	verbpath = /mob/proc/changeling_lsdsting
	icon = "ling_lsd"

/* I want to replace death sting with horror form
/datum/power/changeling/DeathSting
	name = "Death Sting"
	desc = "We sting a human, filling them with potent chemicals. Their rapid death is all but assured, but our crime will be obvious."
	helptext = "It will be clear to any surrounding witnesses if you use this power."
	genomecost = 10
	verbpath = /mob/proc/changeling_DEATHsting

//This ability is lame.
/datum/power/changeling/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	genomecost = 2
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_boost_range
*/

/datum/power/changeling/Epinephrine
	name = "Epinephrine sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Gives the ability to instantly recover from stuns.  High chemical cost."
	genomecost = 3
	verbpath = /mob/proc/changeling_unstun
	icon = "ling_nostun"

/datum/power/changeling/ChemicalSynth
	name = "Rapid Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 4
	isVerb = 0
	verbpath = /mob/proc/changeling_fastchemical

/*
/datum/power/changeling/AdvChemicalSynth
	name = "Advanced Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 8
	isVerb = 0
	verbpath = /mob/proc/changeling_fastchemical
*/
/datum/power/changeling/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals."
	genomecost = 4
	isVerb = 0
	verbpath = /mob/proc/changeling_engorgedglands

/datum/power/changeling/DigitalCamoflague
	name = "Digital Camoflauge"
	desc = "We evolve the ability to distort our form and proprtions, defeating common altgorthms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill.  However, humans looking at us will find us.. uncanny.  We must constantly expend chemicals to maintain our form like this."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /mob/proc/changeling_digitalcamo
	icon = "digital_camo"

/datum/power/changeling/rapidregeneration
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a moderate amount of damage every tick."
	genomecost = 7
	verbpath = /mob/proc/changeling_rapidregen
	icon = "regenerate"

//TODO: Make sure this works
/datum/power/changeling/buffstats
	name = "Buff Stats"
	desc = "We evolve our dna makeup to give us increased strength, dexterity, and intenlligence."
	helptext = "ST, DX and IT are all buffed by 5. Is one use only."
	genomecost = 4
	isVerb = 0
	verbpath = /mob/proc/changeling_buff_stats


// Modularchangling, totally stolen from the new player panel.  YAYY
/datum/changeling/proc/EvolutionMenu()//The new one
	set category = "Changeling"
	set name = "EvolutionMenu"
	set desc = "Level up!"

	if(!usr || !usr.mind || !usr.mind.changeling)	return
	src = usr.mind.changeling

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	var/dat = "<html><head><title>Changeling Evolution Menu</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,name,desc,helptext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+desc+"</b></font> <BR>"

					body += "<font size='2'><font color = 'red'><b>"+helptext+"</b></font></font><BR>"

					if(!ownsthis)
					{
						body += "<a href='byond://?src=\ref[src];P="+power+"'>Evolve</a>"
					}

					body += "</td><td align='center'>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Changling Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current evolution points left to evolve with: [geneticpoints]<br>
					Absorb genomes to acquire more evolution points
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1
	for(var/datum/power/changeling/P in powerinstances)
		var/ownsthis = 0

		if(P in purchasedpowers)
			ownsthis = 1


		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<span id='search[i]'><b>Evolve [P] - Cost: [ownsthis ? "Purchased" : P.genomecost]</b></span>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=powers;size=900x480")


/datum/changeling/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	if(href_list["P"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		purchasePower(M, href_list["P"])
		call(/datum/changeling/proc/EvolutionMenu)()



/datum/changeling/proc/purchasePower(var/datum/mind/M, var/Pname, var/remake_verbs = 1)
	if(!M || !M.changeling)
		return

	var/datum/power/changeling/Thepower = Pname


	for (var/datum/power/changeling/P in powerinstances)
//		log_debug("[P] - [Pname] = [P.name == Pname ? "True" : "False"]")

		if(P.name == Pname)
			Thepower = P
			break


	if(Thepower == null)
		to_chat(M.current, "This is awkward.  Changeling power purchase failed, please report this bug to a coder!")
		return

	if(Thepower in purchasedpowers)
		to_chat(M.current, "We have already evolved this ability!")
		return


	if(geneticpoints < Thepower.genomecost)
		to_chat(M.current, "We cannot evolve this... yet.  We must acquire more DNA.")
		return

	geneticpoints -= Thepower.genomecost

	purchasedpowers += Thepower
	//Trying to use the old ling ability manager code

	if(!M.current.ability_master)
		M.current.ability_master = new()
	//If it's a verb, add it.  If it's not, just call it once
	//if(Thepower.isVerb)
		//M.current.ability_master.add_ling_ability(M.current,Thepower.verbpath,Thepower.name,Thepower.icon,null)
	//else
		//call(M.current, Thepower.verbpath)()
	/*
	//What if we just... use ability manager
	//TODO: Completely replace the add verb part, and move completely to spells
	if(Thepower.spellpath)
		var/spell/new_sting = new Thepower.spellpath
		M.current.add_spell(new_sting)
	if(!Thepower.isVerb && Thepower.verbpath)
		call(M.current, Thepower.verbpath)()
	else if(remake_verbs)
		M.current.make_changeling()
	*/

