
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/eyes.dmi')
	var/prescription = FALSE
	var/toggleable = FALSE
	active = TRUE
	flags_inventory = COVEREYES
	flags_equip_slot = ITEM_SLOT_EYES
	flags_armor_protection = EYES
	var/deactive_state = "degoggles"
	var/vision_flags = 0
	var/darkness_view = 2 //Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	var/lighting_alpha


/obj/item/clothing/glasses/equipped(mob/user, slot)
	. = ..()

	if(slot != SLOT_GLASSES || !active)
		disable_vis_overlay(user)
		return ..()

	enable_vis_overlay(user)
	..()

/obj/item/clothing/glasses/dropped(mob/living/carbon/human/user)
	if(istype(user))
		if(src == user.glasses) //dropped is called before the inventory reference is updated.
			disable_vis_overlay(user)
	..() 

/obj/item/clothing/glasses/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_glasses()


/obj/item/clothing/glasses/attack_self(mob/user)
	toggle_item_state(user)

/obj/item/clothing/glasses/toggle_item_state(mob/user)
	. = ..()
	if(toggleable)
		toggle_glasses(user)

/obj/item/clothing/glasses/proc/toggle_glasses(mob/user)
	if(active)
		deactivate_glasses(user)
	else
		activate_glasses(user)

	update_action_button_icons()


/obj/item/clothing/glasses/proc/activate_glasses(mob/user, silent = FALSE)
	active = TRUE
	icon_state = initial(icon_state)
	user.update_inv_glasses()
	enable_vis_overlay(user)
	if(!silent)
		to_chat(user, "You activate the optical matrix on [src].")
		playsound(user, 'sound/items/googles_on.ogg', 15)


/obj/item/clothing/glasses/proc/deactivate_glasses(mob/user, silent = FALSE)
	active = FALSE
	icon_state = deactive_state
	user.update_inv_glasses()
	disable_vis_overlay(user)
	if(!silent)
		to_chat(user, "You deactivate the optical matrix on [src].")
		playsound(user, 'sound/items/googles_off.ogg', 15)


///Enables any additional visual elements that might be shown on the player's screen
/obj/item/clothing/glasses/proc/enable_vis_overlay(mob/user)
	return

///Disables any additional visual elements that might be shown on the player's screen
/obj/item/clothing/glasses/proc/disable_vis_overlay(mob/user)
	return

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "The goggles do nothing! Can be used as safety googles."
	icon_state = "purple"
	item_state = "glasses"

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	flags_armor_protection = 0

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	flags_armor_protection = 0

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	actions_types = list(/datum/action/item_action/toggle)
	toggleable = 1
	vision_flags = SEE_OBJS

/obj/item/clothing/glasses/regular
	name = "regulation prescription glasses"
	desc = "The Corps may call them Regulation Prescription Glasses but you know them as Rut Prevention Glasses."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = TRUE

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	item_state = "3d"
	flags_armor_protection = 0

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"
	flags_armor_protection = 0

/obj/item/clothing/glasses/mgoggles
	name = "marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	icon_state = "mgoggles"
	item_state = "mgoggles"
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 0, "energy" = 15, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 30, "acid" = 30)
	flags_equip_slot = ITEM_SLOT_EYES|ITEM_SLOT_MASK

/obj/item/clothing/glasses/mgoggles/prescription
	name = "prescription marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet. Contains prescription lenses in case you weren't sure if they were lame or not."
	icon_state = "mgoggles"
	item_state = "mgoggles"
	prescription = TRUE

/obj/item/clothing/glasses/m42_goggles
	name = "\improper M42 scout sight"
	desc = "A headset and goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	vision_flags = SEE_TURFS
	toggleable = 1
	actions_types = list(/datum/action/item_action/toggle)



//welding goggles

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	flags_inventory = COVEREYES
	flags_inv_hide = HIDEEYES
	eye_protection = 2

/obj/item/clothing/glasses/welding/Initialize()
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_5, TRUE)

/obj/item/clothing/glasses/welding/proc/flip_up()
	DISABLE_BITFIELD(flags_inventory, COVEREYES)
	DISABLE_BITFIELD(flags_inv_hide, HIDEEYES)
	DISABLE_BITFIELD(flags_armor_protection, EYES)
	eye_protection = 0
	icon_state = "[initial(icon_state)]up"

/obj/item/clothing/glasses/welding/proc/flip_down()
	ENABLE_BITFIELD(flags_inventory, COVEREYES)
	ENABLE_BITFIELD(flags_inv_hide, HIDEEYES)
	ENABLE_BITFIELD(flags_armor_protection, EYES)
	eye_protection = initial(eye_protection)
	icon_state = initial(icon_state)

/obj/item/clothing/glasses/welding/verb/verbtoggle()
	set category = "Object"
	set name = "Adjust welding goggles"
	set src in usr

	if(!usr.incapacitated())
		toggle_item_state(usr)

/obj/item/clothing/glasses/welding/attack_self(mob/user)
	toggle_item_state(user)

/obj/item/clothing/glasses/welding/toggle_item_state(mob/user)
	. = ..()
	active = !active
	icon_state = "[initial(icon_state)][!active ? "up" : ""]"
	if(!active)
		flip_up()
	else
		flip_down()
	if(user)
		to_chat(usr, "You [active ? "flip [src] down to protect your eyes" : "push [src] up out of your face"].")

	update_clothing_icon()

	update_action_button_icons()

/obj/item/clothing/glasses/welding/flipped //spawn in flipped up.
	active = FALSE

/obj/item/clothing/glasses/welding/flipped/Initialize(mapload)
	. = ..()
	flip_up()
	AddComponent(/datum/component/clothing_tint, TINT_5, FALSE)

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"

/obj/item/clothing/glasses/welding/superior/Initialize()
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_4)

//sunglasses

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	eye_protection = 1

/obj/item/clothing/glasses/sunglasses/Initialize()
	. = ..()
	if(eye_protection)
		AddComponent(/datum/component/clothing_tint, TINT_3)

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	eye_protection = 2

/obj/item/clothing/glasses/sunglasses/blindfold/Initialize()
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_BLIND)

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/big/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake
	desc = "A pair of designer sunglasses. Doesn't seem like it'll block flashes."
	eye_protection = 0

/obj/item/clothing/glasses/sunglasses/fake/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake/big
	desc = "A pair of larger than average designer sunglasses. Doesn't seem like it'll block flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/fake/big/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/sa
	name = "spatial agent's sunglasses"
	desc = "Glasses worn by a spatial agent."
	eye_protection = 2
	darkness_view = 8
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

/obj/item/clothing/glasses/sunglasses/sa/Initialize()
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_NONE)

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	var/hud_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/sunglasses/sechud/eyepiece
	name = "Security HUD Sight"
	desc = "A standard eyepiece, but modified to display security information to the user visually. This makes it commonplace among military police, though other models exist."
	icon_state = "securityhud"
	item_state = "securityhud"


/obj/item/clothing/glasses/sunglasses/sechud/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLASSES)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.add_hud_to(user)
	..()

/obj/item/clothing/glasses/sunglasses/sechud/dropped(mob/living/carbon/human/user)
	if(istype(user))
		if(src == user.glasses) //dropped is called before the inventory reference is updated.
			var/datum/atom_hud/H = GLOB.huds[hud_type]
			H.remove_hud_from(user)
	..()

/obj/item/clothing/glasses/sunglasses/sechud/tactical
	name = "tactical HUD"
	desc = "Flash-resistant goggles with inbuilt combat and security information."
	icon_state = "swatgoggles"

/obj/item/clothing/glasses/sunglasses/aviator
	name = "aviator sunglasses"
	desc = "A pair of aviator sunglasses."
	icon_state = "aviator"
	item_state = "aviator"

/obj/item/clothing/glasses/sunglasses/aviator/yellow
	name = "aviator sunglasses"
	desc = "A pair of aviator sunglasses. Comes with yellow lens."
	icon_state = "aviator_yellow"
	item_state = "aviator_yellow"

/obj/item/clothing/glasses/thermals
	name = "thermal goggles"
	desc = "Specialized goggles able to see heat signatures. Has a built-in function to distinguish allies."
	icon_state = "swatgoggles"
	actions_types = list(/datum/action/item_action/toggle)
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	darkness_view = 28
	///Affects how floor is colored
	var/list/floor_color_mod = list(0.1,0.1,0.1,0, 0.3,0.3,0.3,0, 0.4,0.4,0.4,0, 0,0,0,3, -0.3,-0.3,-0.3,0)
	///Affects how any other things are colored
	var/list/game_color_mod = list(0.3,0.3,0.3,0, 0.59,0.59,0.59,0, 0.11,0.11,0.11,0, 0,0,0,3, -0.1,-0.1,-0.1,0)

/obj/item/clothing/glasses/thermals/enable_vis_overlay(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/hud_type = DATA_HUD_USSR_TEAM
	if(istype(user.job, /datum/job/natsf))
		hud_type = DATA_HUD_NATSF_TEAM
	var/datum/atom_hud/H = GLOB.huds[hud_type]

	var/obj/screen/plane_master/game_world/game_master = locate(/obj/screen/plane_master/game_world) in user.client?.screen
	var/obj/screen/plane_master/floor/floor_master = locate(/obj/screen/plane_master/floor) in user.client?.screen

	H.add_hud_to(user)
	user.overlay_fullscreen("thermals_overlay", /obj/screen/fullscreen/thermals)	
	if(user.client)
		animate(game_master, color = game_color_mod, time = 10)
		animate(floor_master, color = floor_color_mod, time = 10)

	..()

/obj/item/clothing/glasses/thermals/disable_vis_overlay(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/hud_type = DATA_HUD_USSR_TEAM
	if(istype(user.job, /datum/job/natsf))
		hud_type = DATA_HUD_NATSF_TEAM
	var/datum/atom_hud/H = GLOB.huds[hud_type]

	var/obj/screen/plane_master/game_world/game_master = locate(/obj/screen/plane_master/game_world) in user.client?.screen
	var/obj/screen/plane_master/floor/floor_master = locate(/obj/screen/plane_master/floor) in user.client?.screen

	H.remove_hud_from(user)
	user.clear_fullscreen("thermals_overlay")
	if(user.client)
		animate(game_master, color = list(), time = 10)
		animate(floor_master, color = list(), time = 10)

	..()

/obj/item/clothing/glasses/nv_goggles
	name = "night vision goggles"
	desc = "Specialized goggles able to see in the dark. Has a built-in function to distinguish allies."
	icon_state = "swatgoggles"
	actions_types = list(/datum/action/item_action/toggle)
	///Affects how floor is colored
	var/list/floor_color_mod = list(0,0.2,0,0, 0.2,0.2,0.2,0, 0,0.11,0,0, 0,0,0,3, -0.15,-0.15,-0.15,0)
	///Affects how any other things are colored
	var/list/game_color_mod = list(0.1,0.3,0.1,0, 0.4,0.2,0.4,0, 0.05,0.11,0.05,0, 0,0,0,6, -0.1,-0.1,-0.1,0)
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	darkness_view = 28

/obj/item/clothing/glasses/nv_goggles/enable_vis_overlay(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/hud_type = DATA_HUD_USSR_TEAM
	if(istype(user.job, /datum/job/natsf))
		hud_type = DATA_HUD_NATSF_TEAM
	var/datum/atom_hud/H = GLOB.huds[hud_type]

	var/obj/screen/plane_master/game_world/game_master = locate(/obj/screen/plane_master/game_world) in user.client?.screen
	var/obj/screen/plane_master/floor/floor_master = locate(/obj/screen/plane_master/floor) in user.client?.screen

	H.add_hud_to(user)
	user.overlay_fullscreen("night_vision_overlay", /obj/screen/fullscreen/night_vision)	
	if(user.client)
		animate(game_master, color = game_color_mod, time = 10)
		animate(floor_master, color = floor_color_mod, time = 10)

	..()

/obj/item/clothing/glasses/nv_goggles/disable_vis_overlay(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/hud_type = DATA_HUD_USSR_TEAM
	if(istype(user.job, /datum/job/natsf))
		hud_type = DATA_HUD_NATSF_TEAM
	var/datum/atom_hud/H = GLOB.huds[hud_type]

	var/obj/screen/plane_master/game_world/game_master = locate(/obj/screen/plane_master/game_world) in user.client?.screen
	var/obj/screen/plane_master/floor/floor_master = locate(/obj/screen/plane_master/floor) in user.client?.screen

	H.remove_hud_from(user)
	user.clear_fullscreen("night_vision_overlay")
	if(user.client)
		animate(game_master, color = list(), time = 10)
		animate(floor_master, color = list(), time = 10)

	..()
