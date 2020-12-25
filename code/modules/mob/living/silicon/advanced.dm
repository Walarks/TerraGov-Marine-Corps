/mob/living/silicon/ai_advanced
	name = "Assault Support Unit"
	desc = "The actual SL"
	icon = 'icons/mob/animal.dmi'
	icon_state = "asu"
	icon_living = "asu"
	icon_dead = "asu_dead"
	var/icon_anchored = "asu_anchored"
	gender = NEUTER
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	density = TRUE
	health = 400
	maxHealth = 400
	flags_pass = PASSTABLE|PASSMOB
	speech_span = SPAN_ROBOT
	dextrous = TRUE
	fire_resist = 0.25

	initial_language_holder = /datum/language_holder/synthetic

	var/obj/machinery/camera/builtInCamera = null
	var/obj/item/radio/headset/mainship/mcom/silicon/radio = null

	var/list/HUD_toggled = list(0, 0, 0)


/mob/living/silicon/ai_advanced/Initialize()
	. = ..()
	builtInCamera = new(src)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/silicon)

/mob/living/silicon/ai_advanced/Destroy()
	QDEL_NULL(builtInCamera)
	return ..()
