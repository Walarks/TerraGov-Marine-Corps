/mob/living/simple_animal/ai_advanced
	name = "Assault Support Unit"
	desc = "The actual SL"
	//Icons
	icon_state = "pink_slime"
	icon = 'icons/mob/animal.dmi'
	//Say
	speak = list()
	speak_chance = 0
	emote_hear = list()	//Hearable emotes
	emote_see = list()	//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	//Stats
	health = 400
	maxHealth = 400
	gender = NEUTER
	var/icon_anchored = "asu_anchored"
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	density = TRUE
	flags_pass = PASSTABLE
	speech_span = SPAN_ROBOT
	dextrous = TRUE
	//Movement
	turns_per_move = 1
	turns_since_move = 0
	stop_automated_movement = TRUE
	wander = FALSE	// Does the mob wander around when idle?
	speed = 4
	can_have_ai = TRUE
	shouldwakeup = TRUE //convenience var for forcibly waking up an idling AI on next check.
	damage_coeff = list(BRUTE = 0.7, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source

	//Special Vars
	///The mob that the AI listens to
	var/mob/master_mob
	var/obj/machinery/camera/builtInCamera = null
	var/mode = ASU_STANDBY
	initial_language_holder = /datum/language_holder/synthetic
	///Secondary checks for the AI that influence what it does
	var/behaviour_flags
	var/atom/destination

/mob/living/simple_animal/ai_advanced/Initialize()
	. = ..()
	builtInCamera = new(src)
	builtInCamera.network = list("military")
	builtInCamera.c_tag = "[name] ([rand(0, 1000)])"
	access_card = new(src)
	access_card.access = list(ACCESS_MARINE_DROPSHIP)

	//For checking to make sure it doesn't get squashed or getting on/off shuttles
	for(var/obj/docking_port/mobile/marine_dropship/ship in SSshuttle.mobile)
		RegisterSignal(ship, COMSIG_SHUTTLE_SETMODE, .proc/shuttle_movement)

/mob/living/simple_animal/ai_advanced/Destroy()
	QDEL_NULL(builtInCamera)
	return ..()

/mob/living/simple_animal/ai_advanced/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isidcard(I))
		var/obj/item/card/id/card = I
		if(!(access_card in card.access))
			say(src, "<span class='warning'>Access denied.</span>")
			return

		if(!master_mob)
			var/list/possible_masters = GLOB.alive_human_list
			master_mob = input(user, "Target", "Select an escort target.") as null|anything in possible_masters
			if(!master_mob)
				return
			say(src, "<span class='avoidharm'>[master_mob.name] has been assigned as owner.</span>")
			message_admins("[master_mob]")
			change_state(ASU_FOLLOWER)
			return

		switch(alert(user,"Do you want to reset [src]'s owner?",,"Yes","No"))
			if("Yes")
				say(src, "<span class='avoidharm'>[master_mob.name] has been unassigned. Standby function will commense shortly if no escort target has been assigned.</span>")
				master_mob = null
			if("No")
				return

/mob/living/simple_animal/ai_advanced/bullet_act(obj/projectile/proj)
	if(check_access(proj.projectile_iff))
		proj.damage += proj.damage*proj.damage_marine_falloff
		return FALSE

	return ..()

/mob/living/simple_animal/ai_advanced/proc/change_state(new_mode)
	switch(new_mode)
		if(ASU_STANDBY)
			state_cleanup()
			mode = ASU_STANDBY
			if(!is_mainship_level(mob_p.z) && cur_action != RETURNING)
				change_state(REASON_BASE_RETURN)
				return
			mob_p.say("Assuming standby at [get_area_name(mob_p)].")
			state_setup()

		if(ASU_FOLLOWER)
			state_cleanup()
			mode = ASU_FOLLOWER
			AddElement(/datum/element/pathfinder, master_mob, 2, 0)

		if(ASU_BASE_RETURN)
			state_cleanup()
			mode = ASU_BASE_RETURN

///Configures stuff related to next state
/mob/living/simple_animal/ai_advanced/proc/state_setup()
	switch(mode)
		if(ASU_STANDBY)

		if(ASU_FOLLOWER)
			RegisterSignal(master_mob, COMSIG_MOB_DEATH, .proc/master_killed)
			RegisterSignal(master_mob, COMSIG_MOVABLE_MOVED, .proc/follow_target)

///Cleans up stuff related to previous state
/mob/living/simple_animal/ai_advanced/proc/state_cleanup()
	switch(mode)
		if(ASU_STANDBY)

		if(ASU_FOLLOWER)
			UnregisterSignal(master_mob, COMSIG_MOB_DEATH, .proc/master_killed)
			UnregisterSignal(master_mob, COMSIG_MOVABLE_MOVED, .proc/follow_target)

/mob/living/simple_animal/ai_advanced/proc/check_access(list/access_tags)
	var/obj/item/card/id/src_card = get_idcard()
	for(var/access in access_tags)
		if(!(access in src_card.access))
			continue
		return TRUE
	return FALSE

/mob/living/simple_animal/ai_advanced/proc/follow_target()
	walk_towards()

/mob/living/simple_animal/ai_advanced/proc/master_killed(mob/source, gibbing)
	SIGNAL_HANDLER
	radio.talk_into(src, "Detected critical vital signs of owner [source]!", FREQ_COMMON)
	for(var/mob/living/carbon/human/H in cheap_get_humans_near(src, 10))
		if(!ismarineleaderjob(H.job))
			continue
		master_mob = H
		radio.talk_into(src, "[H.name] selected as emergency owner!", FREQ_COMMON)
		change_state(ASU_FOLLOWER)
	change_state(ASU_BASE_RETURN)

///Finds the closest landing zone or ship with marines near it
/mob/living/simple_animal/ai_advanced/proc/locate_nearby_transport()
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
/mob/living/simple_animal/ai_advanced/proc/shuttle_movement(obj/docking_port/mobile/source, mode)
	SIGNAL_HANDLER_DOES_SLEEP
	switch(mode)
		if(SHUTTLE_PREARRIVAL)
			while(locate(/obj/effect/abstract/ripple) in src.loc)
				for(var/mob/H in cheap_get_humans_near(src, 10))
					for(var/turf/T as() in RANGE_TURFS(1, H))
						if(locate(/obj/effect/abstract/ripple) in T)
							continue
						walk_to(src, T, 0)
						message_admins("ripple repositioning")
						continue

				for(var/turf/T as() in RANGE_TURFS(10, src))
					if(locate(/obj/effect/abstract/ripple) in T.loc)
						continue
					walk_to(src, T, 0)
					message_admins("ripple repositioning")
					continue
		//Handles the AI going into the shuttle groundside and out of it at shipside
		if(SHUTTLE_RECHARGING && CHECK_BITFIELD(behaviour_flags, ASU_SHUTTLE_TRANSPORT))
			message_admins("shuttle recharging > proc")
			if(is_mainship_level(src))
				message_admins("shuttle recharging > mainship")
				for(var/mob/living/carbon/human/H in GLOB.humans_by_zlevel["[src.z]"])
					if(!istype(H.job, /datum/job/terragov/requisitions))
						continue
					walk_to(src, H, 1)
					message_admins("heading to RO present > [H]")
					radio.talk_into(src, "Heading to H in [get_area(H)]", FREQ_COMMON)
					return

				//If there is no RO shipside to bother, it returns to req
				for(var/computer in GLOB.machines)
					if(!istype(computer, /obj/machinery/computer/supplycomp))
						continue
					message_admins("heading to req computer > [computer]")
					walk_to(src, computer, 1)
					radio.talk_into(src, "Assuming standby at [computer] in [get_area(computer)]", FREQ_COMMON)
					break
				return
			message_admins("shuttle recharging > groundside")
			var/obj/S = source
			if(S.z != src.z)
				return
			if(get_dist(source, src) >= 10)
				return
			walk_to(src, S, 2)

/mob/living/simple_animal/ai_advanced/proc/get_xeno_targets(range)
	for(var/xeno in cheap_get_xenos_near(mob_parent, range))
		var/mob/living/carbon/xenomorph/nearby_xeno = xeno
		if(nearby_xeno.hivenumber == XENO_HIVE_CORRUPTED)
			friendly_targets += xeno
			continue
		hostile_targets += xeno
