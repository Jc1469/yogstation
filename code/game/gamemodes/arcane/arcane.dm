/datum/game_mode
	var/list/datum/mind/arcane = list()
	var/list/arcane_objectives = list()

/proc/is_arcane(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.arcane)

/proc/is_arcane_golem_worthy(mob/living/M)
	if(is_arcane(M))
		return 0
	if(ishuman(M))
		if(M.mind.assigned_role in list("Captain", "Chaplain")) // Not sure if I want to remove these two or not. It's not technically a cult and all, but the chaplain is still a cunt, and the captain is an all access ezwin golem of mass resource, but should be hard to get to. Hmh.
			return 0
		return 1

/datum/game_mode/arcane
	name = "arcane"
	config_tag = "arcane"
	antag_flag = ROLE_ARCANIST
	restricted_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel") //Was considering removing all of the non-silicons becuase magic and mindshields aren't really a thing, but it'd still be pretty OP.
	protected_jobs = list()
	required_players = 24
	required_enemies = 3
	recommended_enemies = 3
	enemy_minimum_age = 14
	prob_traitor_ai = 18

	var/finished = 0
	var/portal_home = 1 //Var for the portal objective, seeing as at the time I'm typing this, it's the only one.

	var/arcane_living = 0
	var/list/roundstart_arcane = list() //The 3 meanies.


/datum/game_mode/arcane/announce()
	world << "<B>The current game mode is - Arcane!</B>"
	world << "<B>A few wizards that didn't quite make the cut have infiltrated the station hunting for supplies to further their magic.<BR>\nArcanists - Scavenge for resources to fuel your lesser magic, you will need to avoid detection while creating a lesser portal to the Arcane Sanctum. Ultimately, your end goal is to create a stable portal, well.. as stable as you can manage, back to the wizard's academy. Keep in mind there are only three of you, and there will only ever be three of you. All aid you can get is temporary.<BR>\nPersonnel - Do not let the arcanists loot your treasure trove of a station, full of <I>arcane</I> items. Who knows what will happen if a direct path to the wizard's academy is created on the station..!? All you can really do is fight back, no glasses of water will say you from these few.</B>"


/datum/game_mode/arcane/pre_setup()
	arcane_objectives += "portal_home"

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	recommended_enemies = 3

	var/list/datum/mind/arcane = pick_candidate(amount = recommended_enemies)
	update_not_chosen_candidates()

	for(var/v in arcane)
		var/datum/mind/arcane = v
		roundstart_arcane += arcane
		arcane.special_role = "Arcanist"
		arcane.restricted_roles = restricted_jobs
		log_game("[arcane.key] (ckey) has been selected as a Arcanist")

	if(roundstart_arcane.len < required_enemies)
		return 0

	return 1


/datum/game_mode/arcane/proc/memorize_arcane_objectives(datum/mind/arcane_mind)
	for(var/obj_count = 1,obj_count <= arcane_objectives.len,obj_count++)
		var/explanation
		switch(arcane_objectives[obj_count])
			if("portal_home")
				explanation = "Create a way back to the wizard academy with the use of your lesser magic. The Arcane Sanctum will aid you in doing this."
		arcane_mind.current << "<B>Objective #[obj_count]</B>: [explanation]"
		arcane_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"

/datum/game_mode/arcane/post_setup()
	modePlayer += roundstart_arcane
	for(var/datum/mind/arcane_mind in roundstart_arcane)
		equip_arcane(arcane_mind.current)
		update_arcane_icons_added(arcane_mind)
		arcane_mind.current << "<span class='userdanger'>You are an Arcanist, a master of magic.. in your own mind.</span>"
		add_arcane(arcane_mind, 0)
	..()

/datum/game_mode/proc/equip_arcane(mob/living/carbon/human/mob)
	if(!istype(mob))
		return
	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Years of being bullied at the wizard academy has broken your clownish nature into pieces. You are now ready to face whatever comes your way."
			mob.dna.remove_mutation(CLOWNMUT)
		switch(rand(1,3))
			if(1)
				. += arcane_give_item(/obj/item/clothing/shoes/arcane, mob)
			if(2)
				. += arcane_give_item(/obj/item/clothing/suit/arcane, mob)
			if(3)
				. += arcane_give_item(/obj/item/clothing/head/arcane, mob)
	mob << "A random piece of arcane clothing has been bestowed upon you. Remember to find and work with your fellow arcanists.</span>"

/datum/game_mode/proc/arcane_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		mob << "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1). And also @johncena1469 on discord about it, but probably not mention the gamemode or what's actually wrong.</span>"
		return 0
	else
		mob << "<span class='danger'>You have a [item_name] in your [where]."
		mob.update_icons()
		if(where == "backpack")
			var/obj/item/weapon/storage/B = mob.back
			B.orient2hud(mob)
			B.show_to(mob)
		return 1

/datum/game_mode/proc/add_arcane(datum/mind/arcane_mind, golem)
	if (!istype(arcane_mind))
		return 0
	if(!(arcane_mind in arcane) && is_arcane_golem_worthy(arcane_mind))
		if(!golem)
			arcane += arcane_mind
			arcane_mind.current.faction |= "arcane"
			arcane_mind.current.verbs += /mob/living/proc/arcane_help
			update_arcane_icons_added(arcane_mind)
		else
			/* Here will be a bunch of shit that happens to golems/people hit by the golem-making-staff/spell. */
			arcane_mind.current.attack_log += "\[[time_stamp()]\] <span class='arcane'>arcane pewpew now ur a golem</span>"
	if(jobban_isbanned(arcane_mind.current, ROLE_ARCANE))
		replace_jobbaned_player(arcane_mind.current, ROLE_ARCANE, ROLE_ARCANE)
	return 1


/datum/game_mode/arcane/add_arcane(datum/mind/arcane_mind, golem)
	if (!..(arcane_mind))
		return
	memorize_arcane_objectives(arcane_mind)


/datum/game_mode/proc/remove_arcane(datum/mind/arcane_mind, golem)
	if(!golem)
		arcane -= arcane_mind
		arcane_mind.current.faction -= "arcane"
		arcane_mind.current.verbs -= /mob/living/proc/arcane_help
		arcane_mind.current << "<span class='userdanger'>You suddenly feel like you're not a drop-out from some school for magical idiots.</span>"
		arcane_mind.memory = ""
		update_arcane_icons_removed(arcane_mind)
	else
		/* Here will be the opposite of the other thing. */
		arcane_mind.current.attack_log += "\[[time_stamp()]\] <span class='arcane'>uh oh elmo not a golem no more</span>"

/datum/game_mode/proc/update_arcane_icons_added(datum/mind/arcane_mind)
	var/datum/atom_hud/antag/arcanehud = huds[ANTAG_HUD_ARCANE]
	arcanehud.join_hud(arcane_mind.current)
	set_antag_hud(arcane_mind.current, "arcane")

/datum/game_mode/proc/update_arcane_icons_removed(datum/mind/arcane_mind)
	var/datum/atom_hud/antag/arcanehud = huds[ANTAG_HUD_ARCANE]
	arcanehud.leave_hud(arcane_mind.current)
	set_antag_hud(arcane_mind.current, null)
	
/datum/game_mode/arcane/proc/check_arcane_victory()
	var/arcane_fail = 0

	if(arcane_objectives.Find("portal_home"))
		arcane_fail += portal_home //1 by default, 0 if the portal is created
	return arcane_fail



/datum/game_mode/arcane/declare_completion()

	if(!check_arcane_victory())
		feedback_set_details("round_end_result","win - arcanists win")
		world << "<span class='greentext'>The arcanists succeeded! Now they can finally return to school and probably get kicked out again!</span>"
	else
		feedback_set_details("round_end_result","loss - staff stopped the arcanists")
		world << "<span class='redtext'>The staff managed to stop the angsty rejects! Wow.. I guess.</span>"

	var/text = ""

	if(arcane_objectives.len)
		text += "<br><b>The Arcanist's objective was, obviously:</b>"
		for(var/obj_count=1, obj_count <= arcane_objectives.len, obj_count++)
			var/explanation
			switch(arcane_objectives[obj_count])
				if("portal_home")
					if(!portal_home)
						explanation = "Create a way back to the wizard academy with the use of your lesser magic. <span class='greenannounce'>Success, I guess!</span>"
						feedback_add_details("arcane_objective","arcane_portal_home|SUCCESS")
					else
						explanation = "Create a way back to the wizard academy with the use of your lesser magic. <span class='boldannounce'>Fail. Wow.</span>"
						feedback_add_details("arcane_objective","arcane_portal_home|FAIL")
			text += "<br><B>Objective #[obj_count]</B>: [explanation]"
	world << text
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_arcane()
	if( arcane.len || (ticker && istype(ticker.mode,/datum/game_mode/arcane)) )
		var/text = "<br><font size=3><b>The arcanists were:</b></font>"
		for(var/datum/mind/arcane in arcane)
			text += printplayer(arcane)

		text += "<br>"

		world << text
