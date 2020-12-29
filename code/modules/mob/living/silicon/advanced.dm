/mob/living/silicon/ai_advanced
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

/mob/living/silicon/ai_advanced/Initialize()
	. = ..()
	builtInCamera = new(src)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/living)

/mob/living/silicon/ai_advanced/Destroy()
	QDEL_NULL(builtInCamera)
	return ..()

/mob/living/silicon/ai_advanced/attackby(obj/item/I, mob/user, params)

	if(isidcard(I))
		var/obj/item/card/id/card = I
		if(!(unique_access in card.access))
			say("<span class='warning'>Access denied.</span>")
			return

		if(master_mob)
			switch(alert(user,"Do you want to reset [src]'s owner?",,"Yes","No"))
				if("Yes")
					say("<span class='avoidharm'>[master_mob.name] has been unassigned. Standby function will commense shortly if no escort target has been assigned.</span>")
					master_mob = null
				if("No")
					return

		else
			var/list/possible_masters = GLOB.alive_human_list
			master_mob = input(user, "Target", "Select an escort target.") as null|anything in possible_masters
			if(!master_mob)
				return
			say("<span class='avoidharm'>[master_mob.name] has been assigned as owner.</span>")

		SEND_SIGNAL(src, COMSIG_MASTER_MOB_CHANGED, master_mob)
		return
