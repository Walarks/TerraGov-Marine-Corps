/datum/xeno_caste/gourger
	caste_name = "Gourger"
	display_name = "Gourger"
	upgrade_name = ""
	caste_desc = "A frightening looking, bulky xeno that drips with a familiar red fluid."
	caste_type_path = /mob/living/carbon/xenomorph/gourger

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 15

	// *** Tackle *** //
	tackle_damage = 15

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 5

	// *** Health *** //
	max_health = 600

	// *** Evolution *** //
	upgrade_threshold = 250

	deevolves_to = list(/mob/living/carbon/xenomorph/warrior, /mob/living/carbon/xenomorph/hivelord)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	actions = list(
		/datum/action/xeno_action/activable/drain,
		/datum/action/xeno_action/activable/rejuvenate,
		/datum/action/xeno_action/activable/carnage,
		/datum/action/xeno_action/activable/feast
	)

/datum/xeno_caste/gourger/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/gourger/mature
	upgrade_name = "Mature"
	caste_desc = "A frightening looking, bulky xeno that drips with a familiar red fluid. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 15

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 5

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = 500

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

/datum/xeno_caste/gourger/elder
	upgrade_name = "Elder"
	caste_desc = "A frightening looking, bulky xeno that drips with a familiar red fluid. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 20

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 700

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

/datum/xeno_caste/gourger/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking, dripping monstrosity fills you with a deep, unshakeable sense of unease."
	ancient_message = "We are eternal. We will persevere where others will dry and wither."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 20

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 800

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)
