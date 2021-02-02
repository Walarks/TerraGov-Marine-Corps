/mob/living/simple_animal/ai_advanced
	name = "Assault Support Unit"
	desc = "The actual SL"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	var/icon_anchored = "asu_anchored"
	gender = NEUTER
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	density = TRUE
	health = 400
	maxHealth = 400
	flags_pass = PASSTABLE
	speech_span = SPAN_ROBOT
	dextrous = TRUE
	fire_resist = 0.25

	///The mob that the AI listens to
	var/mob/master_mob

	///For access-related matters
	var/unique_access = ACCESS_MARINE_DROPSHIP

	initial_language_holder = /datum/language_holder/synthetic

/mob/living/simple_animal/ai_advanced/Initialize()
	. = ..()
	builtInCamera = new(src)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/living/silicon)

/mob/living/silicon/ai_advanced/Destroy()
	QDEL_NULL(builtInCamera)
	return ..()

/mob/living/silicon/ai_advanced/attackby(obj/item/I, mob/user, params)

	if(isidcard(I))
		var/obj/item/card/id/card = I
		if(!(unique_access in card.access))
			say(src, "<span class='warning'>Access denied.</span>")
			return

		if(master_mob)
			switch(alert(user,"Do you want to reset [src]'s owner?",,"Yes","No"))
				if("Yes")
					say(src, "<span class='avoidharm'>[master_mob.name] has been unassigned. Standby function will commense shortly if no escort target has been assigned.</span>")
					master_mob = null
				if("No")
					return

		else
			var/list/possible_masters = GLOB.alive_human_list
			master_mob = input(user, "Target", "Select an escort target.") as null|anything in possible_masters
			if(!master_mob)
				return
			say(src, "<span class='avoidharm'>[master_mob.name] has been assigned as owner.</span>")

		message_admins("[master_mob]")
		SEND_SIGNAL(src, COMSIG_MASTER_MOB_CHANGED, master_mob)
		return

/datum/ai_behavior/living/silicon/late_initialize()
	RegisterSignal(src, COMSIG_MASTER_MOB_CHANGED, .proc/master_mob_changed)
	change_state(REASON_STANDBY)

	for(var/obj/docking_port/mobile/marine_dropship/ship in SSshuttle.mobile) //so it doesn't get squashed somehow
		RegisterSignal(ship, COMSIG_SHUTTLE_SETMODE, .proc/shuttle_movement)

	..()

/datum/ai_behavior/living/silicon/get_xeno_targets(range)
	for(var/xeno in cheap_get_xenos_near(src, range))
		var/mob/living/carbon/xenomorph/nearby_xeno = xeno
		if(nearby_xeno.hivenumber == XENO_HIVE_CORRUPTED)
			friendly_targets += xeno
			continue
		hostile_targets += xeno

///So that both get_targets don't need to always run for specific scenarios
/datum/ai_behavior/living/silicon/proc/get_friendly_targets()

/datum/ai_behavior/living/silicon/proc/get_hostile_targets()

/datum/ai_behavior/living/silicon/cleanup_current_action()
	unregister_action_signals(cur_action)
	src.RemoveElement(/datum/element/pathfinder)
	distance_to_maintain = initial(distance_to_maintain)

/datum/ai_behavior/living/silicon/register_action_signals(action_type)
	switch(action_type)
		if(REPOSITIONING)
			RegisterSignal(src, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(RETURNING)
			RegisterSignal(src, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(FOLLOWING)
			RegisterSignal(src, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
			RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, .proc/reason_target_killed)


/datum/ai_behavior/living/silicon/unregister_action_signals(action_type)
	switch(action_type)
		if(REPOSITIONING)
			UnregisterSignal(src, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(RETURNING)
			UnregisterSignal(src, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(FOLLOWING)
			UnregisterSignal(src, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
			UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, .proc/reason_target_killed)

/datum/ai_behavior/living/silicon/proc/master_mob_changed(mob/master_mob)
	SIGNAL_HANDLER
	if(master_mob)
		change_state(REASON_FOLLOWER_MODE)
	else
		change_state(REASON_STANDBY)

/datum/ai_behavior/living/silicon/finished_node_move()
	SIGNAL_HANDLER
	switch(cur_action)
		if(REPOSITIONING)
			change_state(maintained_reasoning)

/datum/ai_behavior/living/silicon/reason_target_killed(mob/source, gibbing)
	SIGNAL_HANDLER
	switch(cur_action)
		if(FOLLOWING)
			src.radio.talk_into(src, "Detected critical vital signs of owner [source]!", FREQ_COMMON)
			for(var/mob/living/carbon/human/H in cheap_get_humans_near(src, 10))
				if(!ismarineleaderjob(H.job))
					continue
				src.master_mob = H
				src.radio.talk_into(src, "[H.name] selected as emergency owner!", FREQ_COMMON)
				change_state(REASON_FOLLOWER_MODE)
			change_state(REASON_TARGET_KILLED)

//Attempt to deal with a obstacle
/datum/ai_behavior/living/silicon/deal_with_obstacle()
	SIGNAL_HANDLER_DOES_SLEEP
	if(get_dist(src, atom_to_walk_to) == 1 && distance_to_maintain == 0) //if mob needs to be on top of the target, but target is obstructed
		distance_to_maintain = 1
		src.RemoveElement(/datum/element/pathfinder)
		src.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)

///Finds the closest landing zone or ship with marines near it
/datum/ai_behavior/living/silicon/proc/locate_nearby_transport()
	var/list/all_docks = SSshuttle.stationary + SSshuttle.mobile
	designated_dock = all_docks[1]
	for(var/obj/D in all_docks)
		if(D.z != src.z)
			continue
		if((istype(D, /obj/docking_port/stationary/marine_dropship) && !istype(D, /obj/docking_port/stationary/marine_dropship/crash_target)) || istype(D, /obj/docking_port/mobile/marine_dropship/minidropship))
			if(length(cheap_get_humans_near(D, 8)) < 2)
				continue
			if(get_dist(src, D) >= get_dist(src, designated_dock))
				continue
			designated_dock = D
		if(get_dist(src, D) < 6)
			break

	designated_dock = get_turf(designated_dock) // obj/docking_port/stationary/marine_dropship gets deleted when the alamo lands, so a different reference needs to be saved
	message_admins("dock turf > [designated_dock]")
	return designated_dock

/*
 * Handles how the AI recognises and reacts to shuttle movement.
 * Should be called when it needs to get on or off a shuttle, or to dodge one landing on top of it
 */
/datum/ai_behavior/living/silicon/proc/shuttle_movement(obj/docking_port/mobile/source, mode)
	SIGNAL_HANDLER_DOES_SLEEP
	switch(mode)
		if(SHUTTLE_PREARRIVAL || )
			if(!locate(/obj/effect/abstract/ripple) in src.loc)
				return
			var/skip_turf_check = FALSE
			for(var/mob/H in cheap_get_humans_near(src, 10))
				for(var/obj/T in range(1, H))
					if(locate(/obj/effect/abstract/ripple) in T.loc)
						continue
					message_admins("shuttle_movement walk to person")
					atom_to_walk_to = T
					skip_turf_check = TRUE
					break

			if(!skip_turf_check)
				message_admins("skip_turf_check = FALSE")
				for(var/turf/T in range(10, src))
					if(locate(/obj/effect/abstract/ripple) in T.loc)
						continue
					atom_to_walk_to = T
					break
			message_admins("ripple repositioning")
			change_state(REASON_REPOSITIONING)

		if(SHUTTLE_RECHARGING) // handles the AI going into the shuttle groundside and out of it at shipside
			message_admins("shuttle recharging > proc")
			if(is_mainship_level(src))
				message_admins("shuttle recharging > mainship")
				for(var/mob/living/carbon/human/H in GLOB.humans_by_zlevel["[src.z]"])
					if(!istype(H.job, /datum/job/terragov/requisitions))
						continue
					atom_to_walk_to = H
					message_admins("heading to RO present > [H]")
					break

				if(!istype(atom_to_walk_to, /datum/job/terragov/requisitions)) // if there is no RO shipside to bother, it returns to req
					for(var/computer in GLOB.machines)
						if(!istype(computer, /obj/machinery/computer/supplycomp))
							continue
						message_admins("heading to req computer > [computer]")
						atom_to_walk_to = computer
						break
				src.radio.talk_into(src, "Assuming standby at [atom_to_walk_to] in [get_area(atom_to_walk_to)]", FREQ_COMMON)
			else
				message_admins("shuttle recharging > groundside")
				var/obj/S = source
				if(S.z != src.z)
					return
				if(get_dist(source, designated_dock) >= 10)
					return
				atom_to_walk_to = source
			change_state(REASON_BASE_RETURN)
