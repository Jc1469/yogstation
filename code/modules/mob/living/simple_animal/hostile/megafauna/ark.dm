/mob/living/simple_animal/hostile/megafauna/ark
	name = "ark"
	desc = "ark"
	health = 5000
	maxHealth = 5000
	attacktext = "ark"
	attack_sound = 'sound/items/PSHOOM_2.ogg'
	icon_state = "ark"
	icon_living = "ark"
	icon_dead = "ark"
	friendly = "h-arkens"
	icon = 'icons/mob/lavaland/ark.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("ark")
	armour_penetration = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = 1
	move_to_delay = 10
	ranged = 0
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -64 //TBD. I asked for a 96x96 sprite so it took up 3 tiles.
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
	var/activated = FALSE

/obj/structure/ark/pedestal/attackby(obj/item/W, mob/user)
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

/obj/structure/ark/button/attack_hand(mob/user)
	for(var/obj/structure/ark/pedestal/P in orange(3))
		if(P.activated)
			soulcount++
	if(soulcount == 4)
		user << "ay lmao u did it"
		user << "ay replace me with spawn crap"
		playsound(src,'sound/items/PSHOOM_2.ogg',40,1)
		icon_state = "button_active"
		var/mob/A = new /mob/living/simple_animal/pet/dog/corgi(src.loc)
		A.icon = 'icons/mob/lavaland/ark.dmi'
		A.icon_state = "ark"
	else
		user << "You must construct additional souls."
		soulcount = 0
		return
