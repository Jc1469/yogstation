/mob/living/simple_animal/hostile/megafauna/ark
	name = "ark"
	desc = "ark"
	health = 5000
	maxHealth = 5000
	attacktext = "ark"
	attack_sound = 'sound/items/PSHOOM_2.ogg'
	icon_state = "inorix"
	icon_living = "inorix"
	icon_dead = "inorix"
	friendly = "h-arkens"
	icon = 'icons/mob/lavaland/ark.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("ark")
	armour_penetration = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	AIStatus = AI_OFF
	stop_automated_movement = 1
	wander = 0
	anchored = 1
	speed = 1
	move_to_delay = 10
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	pixel_y = -32
	aggro_vision_range = 18
	idle_vision_range = 5
	del_on_death = 0
	loot = list()

	damage_coeff = list(BRUTE = 1, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)



/obj/structure/ark
	name = "ark"
	desc = "ark"
	var/soullist = list(/obj/item/weapon/soul/colossus, /obj/item/weapon/soul/bubblegum, /obj/item/weapon/soul/ashdrake, /obj/item/weapon/soul/legion)
	anchored = 1


/obj/structure/ark/pedestal
	name = "pedestal"
	desc = "A time-worn pedestal with a slot for something to go in it..."
	icon = 'icons/obj/ark.dmi'
	icon_state = "pedestal"
	density = 1
	var/activated = FALSE

/obj/structure/ark/pedestal/attackby(obj/item/W, mob/user)
	if(activated)
		user << "The pedestal already contains a soul."
		return
	if(!is_type_in_list(W, soullist))
		user << "The pedestal refuses to accept that item."
		return
	user << "You insert [W] into the pedestal."
	W.dropped()
	qdel(W)
	activated = TRUE
	icon_state = "pedestal_active"


/obj/structure/ark/button
	name = "ominous button"
	desc = "A time-worn button which concerns you just thinking about it..."
	icon = 'icons/obj/ark.dmi'
	icon_state = "button"
	var/soulcount = 0
	var/activated = FALSE

/obj/structure/ark/button/attack_hand(mob/living/carbon/user)
	if(activated)
		user.Weaken(1)
		user.apply_damage(35, BURN)
		user << "The [src] blasts you with pure energy as you try to mess with it."
		return
	for(var/obj/structure/ark/pedestal/P in orange(3))
		if(P.activated)
			soulcount++
	if(soulcount == 4)
		for(var/mob/M in orange(20))
			shake_camera(M, 50, 1)
		playsound(src,'sound/items/PSHOOM_2.ogg',50,1)
		icon_state = "button_active"
		activated = TRUE
		for(var/obj/structure/ark/pedestal/P in orange(3))
			qdel(P)
		for(var/turf/open/indestructible/ark/F in get_area_turfs(/area/lavaland/ark))
			F.icon_state = "[F.on_state]"
		spawn(50)
			for(var/turf/open/indestructible/ark/exterior/E in get_area_turfs(/area/lavaland/ark))
				E.ChangeTurf(/turf/closed/indestructible/ark/vertical)
				E.icon_state = "[E.on_state]"
			new /mob/living/simple_animal/hostile/megafauna/ark(src.loc)
			qdel(src)
	else
		user << "You must construct additional souls."
		soulcount = 0
		return

/turf/open/indestructible/ark
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "arkfloor"
	var/on_state = "arkfloor_on"

/turf/open/indestructible/ark/light
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "arklight"
	on_state = "arklight_on"
	luminosity = 5
	
/turf/open/indestructible/ark/exterior
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "arkfloor"

/turf/closed/indestructible/ark
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "arkwall"
	var/on_state = "arkwall_on"
	
/turf/closed/indestructible/ark/vertical
	name = "wall"
	icon ='icons/turf/walls.dmi'
	icon_state = "arkwall1"
	on_state = "arkwall1_on"

/turf/closed/indestructible/ark/Destroy()
	ChangeTurf(/turf/open/indestructible/ark)
	icon_state = "[on_state]"
	return