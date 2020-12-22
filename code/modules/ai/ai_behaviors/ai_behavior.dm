/*
AI BEHAVIOR

The actual thinking brain that determines what it wants the mob to do
Registers signals, handles the pathfinding element addition/removal alongside making the mob do actions
*/

/datum/ai_behavior

	var/atom/atom_to_walk_to //An atom for the overall AI to walk to; this is a cache
	var/distance_to_maintain = 1 //Default distance to maintain from a target while in combat usually
	var/sidestep_prob = 0 //Prob chance of sidestepping (left or right) when distance maintained with target
	var/obj/effect/ai_node/current_node //Current node to use for calculating action states: this is the mob's node
	var/cur_action //Contains a defined term that tells us what we're doing; useful for switch() statements

/datum/ai_behavior/New(loc, parent_to_assign)
	..()

//Register any signals we want when this is called
/datum/ai_behavior/proc/late_initialize()
	cur_action = MOVING_TO_NODE
	register_action_signals(cur_action)

//We finished moving to a node, let's pick a random nearby one to travel to
/datum/ai_behavior/proc/finished_node_move()
	SIGNAL_HANDLER
	change_state(REASON_FINISHED_NODE_MOVE)

//Cleans up signals related to the action and element(s)
/datum/ai_behavior/proc/cleanup_current_action()
	unregister_action_signals(cur_action)
	RemoveElement(/datum/element/pathfinder)

//Cleanups variables related to current state then attempts to transition to a new state based on reasoning for interrupting the current action
/datum/ai_behavior/proc/change_state(reasoning_for)
	return

//Generic process(), this is used for mainly looking at the world around the AI and determining if a new action must be considered and executed
/datum/ai_behavior/process()
	return

/*
Registering and unregistering signals related to a particular cur_action
These are parameter based so the ai behavior can choose to (un)register the signals it wants to rather than based off of cur_action
*/

/datum/ai_behavior/proc/register_action_signals(action_type)
	return

/datum/ai_behavior/proc/unregister_action_signals(action_type)
	return
