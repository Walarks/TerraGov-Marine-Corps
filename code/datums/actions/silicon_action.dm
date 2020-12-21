/datum/action/silicon_action
	///Name of ability
	var/ability_name
	///Battery cost of ability
	var/energy_cost = 0
	///Description of ability
	var/mechanics_text = "This ability not found in codex."
	/// Bypass use limitations checked by can_use_action()
	var/use_state_flags = NONE
	///Last time the ability was used
	var/last_use
	///Ability cooldown support
	var/cooldown_timer
	var/cooldown_id
	///Cooldown image
	var/image/cooldown_image

/datum/action/silicon_action/New(Target)
	. = ..()
	