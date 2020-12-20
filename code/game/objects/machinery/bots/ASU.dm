/obj/machinery/ASU
	name = "Assault Support Unit"
	desc = "An AI-controlled machine responsible for maintaining offensive movement."
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry_base"
	layer = MOB_LAYER
	use_power = NO_POWER_USE
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	density = TRUE
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_LEADER)
	var/obj/item/card/id/botcard			// the ID card that the bot "holds"
	var/on = TRUE
	var/open = FALSE //Maint panel
	var/locked = TRUE
	a_intent = INTENT_HARM

	var/datum/effect_system/spark_spread/spark_system

	//mechanical parts
	var/obj/item/cell/cell = null
	var/obj/machinery/camera/camera
	var/obj/item/radio/radio
	obj_integrity = 400
	max_integrity = 400
	//behavior parts
	var/atom/target = null

/obj/machinery/ASU/Initialize()
	. = ..()
	radio = new(src)
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	cell = new /obj/item/cell/high(src)
	if(!camera)
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[name] ([rand(0, 1000)])"
	machine_stat = NONE
	update_icon()
	GLOB.marine_adv_AI += src
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon)

/obj/machinery/ASU/Destroy() //Clear these for safety's sake.
	QDEL_NULL(radio)
	QDEL_NULL(camera)
	QDEL_NULL(cell)
	target = null
	GLOB.marine_adv_AI -= src
	. = ..()
