//Overpowered ark stuff.

/obj/item/organ/cyberimp/eyes/shield/ark_eyes
	name = "enhanced eyes"
	eye_color = null
	implant_overlay = null
	slot = "eye_ling"
	status = ORGAN_ORGANIC



/obj/item/weapon/reality_prime
	name = "Reality Prime"
	desc = "This glowing orb is brimming with strange words and data."
	icon = 'icons/obj/ark.dmi'
	icon_state = "reality"
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC)
	var/list/mutations = list(XRAY, TK)

/obj/item/weapon/reality_prime/attack_self(mob/living/carbon/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		user << "<span class='danger'>You feel a great pressure on your head as you hold [src], as if your brain has suddenly expanded!</span>"
		for(var/hudtype in datahuds)
			var/datum/atom_hud/HUD = huds[hudtype]
			HUD.add_hud_to(user)
		var/obj/item/organ/cyberimp/eyes/O = new /obj/item/organ/cyberimp/eyes/shield/ark_eyes()
		O.Insert(user, 1)
		if(H.dna)
			for(var/M in mutations)
				H.dna.add_mutation(M)
		H.visible_message("[src] is absorbed into [H]'s body!</span>")
		H.unEquip(src)
		qdel(src)
	else
		user <<"<span class='warning'>[src] suddenly heats up in your hands, forcing you to drop it! Something tells you that you won't be able to use it.</span>"
		user.apply_damage(5, BURN)
		user.unEquip(src)
		return

/obj/item/weapon/augment_prime
	name = "Augment Prime"
	desc = "A semi-solid orb with small hooks on it. It looks like it can attach to things."
	icon = 'icons/obj/ark.dmi'
	icon_state = "reality"
	var/enhancement = 30


/obj/item/weapon/augment_prime/afterattack(obj/item/I, mob/user)
	if(I.force) //to prevent things that are useless, like pens, being augmented
		if(istype(I, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/TH = I
			if(TH.wielded)
				user << "<span class='notice'>[TH] must be unwielded before it can be enhanced.</span>"
				return
			TH.force_wielded = TH.force_wielded + enhancement
		user.visible_message("<span class='notice'>[user] attaches [src] to [I] !</span>", "<span class='notice'>You attach [src] to [I]. It feels much more dangerous now.</span>")
		I.force = I.force + enhancement
		I.throwforce = I.throwforce + enhancement
		I.name = "/improper Augmented [I.name]"
	else
		user << "<span class='warning'>[src] refuses to attach to [I].</span>"
		return

//Megafauna souls.

/obj/item/weapon/soul/colossus
	name = "soul of a colossus"
	desc = "An orb containing the soul of a colossus."
	icon = 'icons/obj/ark.dmi'
	icon_state = "orb1"

/obj/item/weapon/soul/ashdrake
	name = "soul of an ash drake"
	desc = "An orb containing the soul of ash drake."
	icon = 'icons/obj/ark.dmi'
	icon_state = "orb2"

/obj/item/weapon/soul/legion
	name = "souls of legion"
	desc = "An orb containing a some souls of legion."
	icon = 'icons/obj/ark.dmi'
	icon_state = "orb3"

/obj/item/weapon/soul/bubblegum
	name = "soul fragment of bubblegum"
	desc = "An orb containing a fragment of bubblegum's soul."
	icon = 'icons/obj/ark.dmi'
	icon_state = "orb4"

