//This is for telling the ai behavior what is making it swap over to a new action to execute because of some new circumstances
#define REASON_FINISHED_NODE_MOVE "finished_moving_to_node" //We finished moving to a node
#define REASON_TARGET_KILLED "recently_killed_a_target" //We finished killing something
#define REASON_TARGET_SPOTTED "spotted_a_target_attacking_with_favorable conditions"  //We spotted a target and determined it's a good idea to attack
#define REASON_REFRESH_TARGET "picking_a_new_target_while_having_a_target" //Repick targets every so often so we don't get stuck on a single thing forever

//DEFINES for AI behavior to utilize to show off what it's currently doing
#define MOVING_TO_NODE "moving_to_a_node" //Move to a node
#define MOVING_TO_ATOM "moving_to_an_atom" //We want to move to this thing and probably hit it; can be just about anything like a mob or machinery

#define STANDBY "standby" //when the AI is required to wait for something to happen

/// AI-related signals
#define COMSIG_

<<<<<<< Updated upstream
/**
 * Identifier tags
 * Ultilized for having AI look at weights based on if they're a "marine human" or a "xenomorph" or something else
 * This is mainly used for deciding what weights are to be looked at when determing a node waypoint of going towards
 */
#define IDENTIFIER_XENO "identifies_xeno"
=======
#define FOLLOWING "following"
#define RETURNING "returning"
#define REPOSITIONING "repositioning"
#define REASON_FOLLOWER_MODE "follower_mode"
#define REASON_STANDBY "standby"
#define REASON_BASE_RETURN "base_return"
#define REASON_REPOSITIONING "repositioninng"
>>>>>>> Stashed changes
