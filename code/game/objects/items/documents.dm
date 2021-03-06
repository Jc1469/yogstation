/obj/item/documents
	name = "secret documents"
	desc = "\"Top Secret\" documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	item_state = "paper"
	throwforce = 0
	w_class = 1
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	pressure_resistance = 1

/obj/item/documents/syndicate/red
	name = "red secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. The red seal looks as if it was made of plastic."
	icon_state = "docs_red"

/obj/item/documents/secret

/obj/item/documents/secret/nanotrasen
	desc = "\"Top Secret\" Nanotrasen documents, filled with complex diagrams and lists of names, dates and coordinates."
	icon_state = "docs_verified"

/obj/item/documents/secret/syndicate
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence."

/obj/item/documents/secret/syndicate/red
	name = "red secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a red wax seal."
	icon_state = "docs_red"

/obj/item/documents/secret/syndicate/blue
	name = "blue secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a blue wax seal."
	icon_state = "docs_blue"

/obj/item/documents/secret/syndicate/mining
	desc = "\"Top Secret\" documents detailing Syndicate plasma mining operations."

/obj/item/documents/secret/photocopy
	desc = "A copy of some top-secret documents. Nobody will notice they aren't the originals... right?"
	var/forgedseal = 0
	var/copy_type = null

/obj/item/documents/secret/photocopy/New(loc, obj/item/documents/copy=null)
	..()
	if(copy)
		copy_type = copy.type
		if(istype(copy, /obj/item/documents/secret/photocopy)) // Copy Of A Copy Of A Copy
			var/obj/item/documents/secret/photocopy/C = copy
			copy_type = C.copy_type

/obj/item/documents/secret/photocopy/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/toy/crayon/red) || istype(O, /obj/item/toy/crayon/blue))
		if (forgedseal)
			to_chat(user, "<span class='warning'>You have already forged a seal on [src]!</span>")
		else
			var/obj/item/toy/crayon/C = O
			name = "[C.item_color] secret documents"
			icon_state = "docs_[C.item_color]"
			forgedseal = C.item_color
			to_chat(user, "<span class='notice'>You forge the official seal with a [C.item_color] crayon. No one will notice... right?</span>")
			update_icon()
