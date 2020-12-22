//Moves to an atom, sends signals if a distance is maintained with the atom being walked to

/datum/element/pathfinder
	element_flags = ELEMENT_DETACH //Detach on attached's QDEL
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to = list() //All the targets some mobs gotta move to
	var/list/stutter_step_prob = list() //The prob() chance of a mob going left or right when distance is maintained with the target

/datum/element/pathfinder/New()
	. = ..()
	START_PROCESSING(SSpathfinding, src)

/datum/element/pathfinder/Destroy()
	STOP_PROCESSING(SSpathfinding, src)
	return ..()

/datum/element/pathfinder/process()
	for(var/atom/movable/mob_to_process in distances_to_maintain)
		if(!thing_can_move(mob_to_process))
			continue
		if(get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) == distances_to_maintain[mob_to_process])
			SEND_SIGNAL(mob_to_process, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(!(get_dir(mob_to_process, atoms_to_walk_to[mob_to_process]))) //We're right on top, move out of it
				if(!step(mob_to_process, pick(CARDINAL_ALL_DIRS)))
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			if(prob(stutter_step_prob[mob_to_process]))
				if(!step(mob_to_process, pick(LeftAndRightOfDir(get_dir(mob_to_process, atoms_to_walk_to[mob_to_process]), diagonal_check = TRUE)))) //Couldn't move, something in the way
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			continue

		if(get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) < distances_to_maintain[mob_to_process]) //We're too close, back it up
			if(!step_away(mob_to_process, atoms_to_walk_to[mob_to_process]))
				SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			mob_to_process.last_move_time = world.time
			continue
		if(!step_to(mob_to_process, atoms_to_walk_to[mob_to_process]))
			SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
		mob_to_process.last_move_time = world.time

/datum/element/pathfinder/proc/thing_can_move(var/M)
	return TRUE

/*
target: the mob that's getting the action state
atom_to_walk_to: target to move to
distance to maintain: mob will try to be at this distance away from the atom to walk to
stutter_step: a prob() chance to go left or right of the mob's direction towards the target when distance has been maintained
*/

/datum/element/pathfinder/Attach(atom/target, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	. = ..()
	if(QDELETED(target))
		return ELEMENT_INCOMPATIBLE
	if(!atom_to_walk_to)
		return ELEMENT_INCOMPATIBLE
	distances_to_maintain[target] = distance_to_maintain
	atoms_to_walk_to[target] = atom_to_walk_to
	stutter_step_prob[target] = stutter_step

/datum/element/pathfinder/Detach(datum/source)
	distances_to_maintain.Remove(source)
	atoms_to_walk_to.Remove(source)
	stutter_step_prob.Remove(source)
	return ..()

///Pathfinder mob code, for checks specific to mobs
/datum/element/pathfinder/mobs

/datum/element/pathfinder/mobs/thing_can_move(var/mob/M)
	if(!M.canmove || M.stat == DEAD)
		return FALSE
	//Okay it can actually physically move, but has it moved too recently?
	if(world.time <= M.last_move_time + M.cached_multiplicative_slowdown || M.action_busy)
		return FALSE
	return ..()

/datum/element/pathfinder/mobs/Attach(atom/target, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

///Pathfinder object code, for checks specific to objs
/datum/element/pathfinder/objs

/datum/element/pathfinder/objs/thing_can_move(var/smth)
	var/obj/machinery/ai_silicon/O = smth
	if(O.anchored || O.robot_action_busy)
		return FALSE

	//Okay it can actually physically move, but has it moved too recently?
	if(world.time <= O.last_move_time + O.movement_delay)
		return FALSE
	return ..()

/datum/element/pathfinder/objs/Attach(atom/target, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE
