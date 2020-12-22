//A generic mind for an object; currently has attacking, obstacle dealing and ability activation capabilities

/datum/ai_behavior/silicon
	var/obj/machinery/ai_silicon/obj_parent //Ref to the parent associated with this mind
	var/attack_range = 1 //How far away we gotta be before considering an attack
	var/list/ability_list = list() //List of abilities to consider doing every Process()

/datum/ai_behavior/silicon/late_initialize()
	RegisterSignal(obj_parent, COMSIG_OBSTRUCTED_MOVE, .proc/deal_with_obstacle)
	RegisterSignal(obj_parent, list(ACTION_GIVEN, ACTION_REMOVED), .proc/refresh_abilities)
	refresh_abilities()
	..() //Start random node movement

/datum/ai_behavior/carbon/New(loc, parent_to_assign)
	..()
	if(isnull(parent_to_assign))
		stack_trace("An ai behavior was initialized without a parent to assign it to; destroying mind. Mind type: [type]")
		qdel(src)
		return
	mob_parent = parent_to_assign
	START_PROCESSING(SSprocessing, src)

//Refresh abilities-to-consider list
/datum/ai_behavior/silicon/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()
	for(var/datum/action/action in obj_parent.robot_actions)
		if(action.ai_should_start_consider())
			ability_list += action

/datum/ai_behavior/silicon/change_state(reasoning_for)
	switch(reasoning_for)
		if(REASON_FINISHED_NODE_MOVE)
			cleanup_current_action()
			if(isainode(atom_to_walk_to)) //Cases where the atom we're walking to can be a mob to kill or turfs
				current_node = atom_to_walk_to
			atom_to_walk_to = pick(current_node.adjacent_nodes)
			obj_parent.AddElement(/datum/element/pathfinder/objs, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			cur_action = MOVING_TO_NODES
			register_action_signals(cur_action)

//Processing; this is for abilities so we don't need to make endless xeno types to code specifically for what abilities they spawn with
/datum/ai_behavior/silicon/process()
	if(obj_parent.robot_action_busy) //No activating more abilities if they're already in the progress of doing one
		return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue
		//xeno_action/activable is activated with a different proc for keybinded actions, so we gotta use the correct proc
		if(istype(action, /datum/action/xeno_action/activable))
			var/datum/action/xeno_action/activable/xeno_action = action
			xeno_action.use_ability(atom_to_walk_to)
		else
			action.action_activate()

/datum/ai_behavior/silicon/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			RegisterSignal(obj_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

/datum/ai_behavior/silicon/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			UnregisterSignal(obj_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
