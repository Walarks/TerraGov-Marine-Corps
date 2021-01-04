/datum/ai_behavior/living/silicon
	distance_to_maintain = 1 //Default distance to maintain from a target while in combat usually
	sidestep_prob = 0 //Prob chance of sidestepping (left or right) when distance maintained with target
	attack_range = 1 //How far away we gotta be before considering an attack

	var/maintained_reasoning
	var/obj/docking_port/designated_dock
	var/list/ai_memory
	var/list/friendly_targets = list()
	var/list/hostile_targets = list()

/datum/ai_behavior/living/silicon/late_initialize()
	RegisterSignal(mob_parent, COMSIG_MASTER_MOB_CHANGED, .proc/master_mob_changed)
	change_state(REASON_STANDBY)

	for(var/obj/docking_port/mobile/marine_dropship/ship in SSshuttle.mobile) //so it doesn't get squashed somehow
		RegisterSignal(ship, COMSIG_SHUTTLE_SETMODE, .proc/shuttle_movement)

	..()

/datum/ai_behavior/living/silicon/get_targets(range)
	for(var/xeno in cheap_get_xenos_near(mob_parent, range))
		var/mob/living/carbon/xenomorph/nearby_xeno = xeno
		if(nearby_xeno.hivenumber == XENO_HIVE_CORRUPTED)
			friendly_targets += xeno
			continue
		hostile_targets += xeno

///So that both get_targets don't need to always run for specific scenarios
/datum/ai_behavior/living/silicon/proc/get_friendly_targets()

/datum/ai_behavior/living/silicon/proc/get_hostile_targets()

/datum/ai_behavior/living/silicon/attack_target()

//Processing; this is for abilities so we don't need to make endless xeno types to code specifically for what abilities they spawn with
/datum/ai_behavior/living/silicon/process()
	if(mob_parent.action_busy) //No activating more abilities if they're already in the progress of doing one
		return ..()

/datum/ai_behavior/living/silicon/change_state(reasoning_for)
	var/mob/living/silicon/ai_advanced/mob_p = mob_parent
	message_admins("state change > [reasoning_for]")

	if(reasoning_for != REASON_REPOSITIONING)
		maintained_reasoning = reasoning_for

	switch(reasoning_for)
		if(REASON_STANDBY)
			cleanup_current_action()
			cur_action = STANDBY
			if(!is_mainship_level(mob_p.z) && cur_action != RETURNING)
				change_state(REASON_BASE_RETURN)
				return
			mob_p.say("Assuming standby at [get_area_name(mob_p)].")

		if(REASON_BASE_RETURN)
			cleanup_current_action()
			cur_action = RETURNING
			if(!istype(atom_to_walk_to, /obj/docking_port) && !is_mainship_level(mob_p))
				atom_to_walk_to = locate_nearby_transport()
				message_admins("[atom_to_walk_to]")
			mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			register_action_signals(cur_action)

		if(REASON_FOLLOWER_MODE)
			cleanup_current_action()
			cur_action = FOLLOWING
			atom_to_walk_to = mob_p.master_mob
			distance_to_maintain = 1
			mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			register_action_signals(cur_action)

		if(REASON_REPOSITIONING)
			cleanup_current_action()
			distance_to_maintain = 0
			cur_action = REPOSITIONING
			mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			register_action_signals(cur_action)
			return

/datum/ai_behavior/living/silicon/cleanup_current_action()
	unregister_action_signals(cur_action)
	mob_parent.RemoveElement(/datum/element/pathfinder)
	distance_to_maintain = initial(distance_to_maintain)

/datum/ai_behavior/living/silicon/register_action_signals(action_type)
	switch(action_type)
		if(REPOSITIONING)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(RETURNING)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(FOLLOWING)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
			RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, .proc/reason_target_killed)


/datum/ai_behavior/living/silicon/unregister_action_signals(action_type)
	switch(action_type)
		if(REPOSITIONING)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(RETURNING)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

		if(FOLLOWING)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
			UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, .proc/reason_target_killed)

/datum/ai_behavior/living/silicon/proc/master_mob_changed(mob/master_mob)
	SIGNAL_HANDLER
	var/mob/living/silicon/ai_advanced/mob_p = mob_parent
	if(mob_p.master_mob)
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
	var/mob/living/silicon/ai_advanced/mob_p = mob_parent
	switch(cur_action)
		if(FOLLOWING)
			mob_p.radio.talk_into(mob_p, "Detected critical vital signs of owner [source]!", FREQ_COMMON)
			for(var/mob/living/carbon/human/H in cheap_get_humans_near(mob_p, 10))
				if(!ismarineleaderjob(H.job))
					continue
				mob_p.master_mob = H
				mob_p.radio.talk_into(mob_p, "[H.name] selected as emergency owner!", FREQ_COMMON)
				change_state(REASON_FOLLOWER_MODE)
			change_state(REASON_TARGET_KILLED)

//Attempt to deal with a obstacle
/datum/ai_behavior/living/silicon/deal_with_obstacle()
	SIGNAL_HANDLER_DOES_SLEEP
	if(get_dist(mob_parent, atom_to_walk_to) == 1 && distance_to_maintain == 0) //if mob needs to be on top of the target, but target is obstructed
		distance_to_maintain = 1
		mob_parent.RemoveElement(/datum/element/pathfinder)
		mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)

///Finds the closest landing zone or ship with marines near it
/datum/ai_behavior/living/silicon/proc/locate_nearby_transport()
	var/list/all_docks = SSshuttle.stationary + SSshuttle.mobile
	designated_dock = all_docks[1]
	for(var/obj/D in all_docks)
		if(D.z != mob_parent.z)
			continue
		if((istype(D, /obj/docking_port/stationary/marine_dropship) && !istype(D, /obj/docking_port/stationary/marine_dropship/crash_target)) || istype(D, /obj/docking_port/mobile/marine_dropship/minidropship))
			if(length(cheap_get_humans_near(D, 8)) < 2)
				continue
			if(get_dist(mob_parent, D) >= get_dist(mob_parent, designated_dock))
				continue
			designated_dock = D
		if(get_dist(mob_parent, D) < 6)
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
	var/mob/living/silicon/ai_advanced/mob_p = mob_parent
	switch(mode)
		if(SHUTTLE_PREARRIVAL || )
			if(!locate(/obj/effect/abstract/ripple) in mob_p.loc)
				return
			var/skip_turf_check = FALSE
			for(var/mob/H in cheap_get_humans_near(mob_p, 10))
				for(var/obj/T in range(1, H))
					if(locate(/obj/effect/abstract/ripple) in T.loc)
						continue
					message_admins("shuttle_movement walk to person")
					atom_to_walk_to = T
					skip_turf_check = TRUE
					break

			if(!skip_turf_check)
				message_admins("skip_turf_check = FALSE")
				for(var/turf/T in range(10, mob_p))
					if(locate(/obj/effect/abstract/ripple) in T.loc)
						continue
					atom_to_walk_to = T
					break
			message_admins("ripple repositioning")
			change_state(REASON_REPOSITIONING)

		if(SHUTTLE_RECHARGING) // handles the AI going into the shuttle groundside and out of it at shipside
			message_admins("shuttle recharging > proc")
			if(is_mainship_level(mob_p))
				message_admins("shuttle recharging > mainship")
				for(var/mob/living/carbon/human/H in GLOB.humans_by_zlevel["[mob_parent.z]"])
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
				mob_p.radio.talk_into(mob_p, "Assuming standby at [atom_to_walk_to] in [get_area(atom_to_walk_to)]", FREQ_COMMON)
			else
				message_admins("shuttle recharging > groundside")
				var/obj/S = source
				if(S.z != mob_p.z)
					return
				if(get_dist(source, designated_dock) >= 10)
					return
				atom_to_walk_to = source
			change_state(REASON_BASE_RETURN)
