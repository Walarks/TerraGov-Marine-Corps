/datum/ai_behavior/living/silicon
	distance_to_maintain = 1 //Default distance to maintain from a target while in combat usually
	sidestep_prob = 0 //Prob chance of sidestepping (left or right) when distance maintained with target
	attack_range = 1 //How far away we gotta be before considering an attack
	var/list/friendly_targets = list()
	var/list/hostile_targets = list()

/datum/ai_behavior/living/silicon/late_initialize()
	..()
	cur_action = STANDBY
	RegisterSignal(mob_parent, COMSIG_MASTER_MOB_CHANGED, .proc/master_mob_changed)

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
	switch(reasoning_for)
		if(REASON_STANDBY)
			cleanup_current_action()
			for(var/mob/living/carbon/human/H in cheap_get_humans_near(mob_parent, 10))
				if(!ismarineleaderjob(H.job))
					continue
				var/mob/living/silicon/ai_advanced/A = mob_parent
				A.master_mob = H
				change_state(REASON_FOLLOWER_MODE)
				return
			if(is_ground_level(get_turf(A)))
				change_state(REASON_BASE_RETURN)

		if(REASON_BASE_RETURN)
			cleanup_current_action()
			atom_to_walk_to =

		if(REASON_FOLLOWER_MODE)
			cleanup_current_action()
			atom_to_walk_to = mob_parent.master_mob
			distance_to_maintain = 2
			cur_action = FOLLOWING
			mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			register_action_signals(cur_action)

		if(REASON_FINISHED_NODE_MOVE)
			cleanup_current_action()
			if(isainode(atom_to_walk_to)) //Cases where the atom we're walking to can be a mob to kill or turfs
				current_node = atom_to_walk_to
			atom_to_walk_to = pick(current_node.adjacent_nodes)
			distance_to_maintain = 0
			mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			cur_action = MOVING_TO_NODE
			register_action_signals(cur_action)

//Attempt to deal with a obstacle
/datum/ai_behavior/living/silicon/deal_with_obstacle()
	SIGNAL_HANDLER_DOES_SLEEP
	if(get_dist(mob_parent, atom_to_walk_to) == 1 && distance_to_maintain == 0) //if mob needs to be on top of the target, but target is obstructed
		distance_to_maintain = 1
		RemoveElement(/datum/element/pathfinder)
		mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)

/datum/ai_behavior/living/silicon/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
		if(FOLLOWING)
			return

/datum/ai_behavior/living/silicon/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		if(FOLLOWING)
			return

/datum/ai_behavior/living/silicon/proc/master_mob_changed(mob/master_mob)
	SIGNAL_HANDLER
	var/mob/living/silicon/ai_advanced/A = mob_parent
	if(A.master_mob)
		change_state(REASON_FOLLOWER_MODE)
	else
		change_state(REASON_STANDBY)
