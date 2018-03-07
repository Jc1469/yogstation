// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				// Unknown plant seed - these shouldn't exist in-game.
	w_class = 1
	burn_state = FLAMMABLE
	var/plantname = "Plants"		// Name of plant when planted.
	var/product						// A type path. The thing that is created when the plant is harvested.
	var/species = ""				// Used to update icons. Should match the name in the sprites unless all icon_* are overriden.

	var/growing_icon = 'icons/obj/hydroponics/growing.dmi'
	var/icon_grow					// Used to override grow icon (default is "[species]-grow"). You can use one grow icon for multiple closely related plants with it.
	var/icon_dead					// Used to override dead icon (default is "[species]-dead"). You can use one dead icon for multiple closely related plants with it.
	var/icon_harvest				// Used to override harvest icon (default is "[species]-harvest"). If null, plant will use [icon_grow][growthstages].

	var/lifespan = 25				// How long before the plant begins to take damage from age.
	var/endurance = 15				// Amount of health the plant has.
	var/maturation = 6				// Used to determine which sprite to switch to when growing.
	var/production = 6				// Changes the amount of time needed for a plant to become harvestable.
	var/yield = 3					// Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/oneharvest = 0				// If a plant is cleared from the tray after harvesting, e.g. a carrot.
	var/potency = 10				// The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/growthstages = 6			// Amount of growth sprites the plant has.
	var/plant_type = PLANT_NORMAL	// 0 = PLANT_NORMAL; 1 = PLANT_WEED; 2 = PLANT_MUSHROOM; 3 = PLANT_ALIEN
	var/rarity = 0					// How rare the plant is. Used for giving points to cargo when shipping off to Centcom.
	var/list/mutatelist = list()	// The type of plants that this plant can mutate into.
	var/list/genes = list()			// Plant genes are stored here, see plant_genes.dm for more info.
	var/list/reagents_add = list()
	// A list of reagents to add to product.
	// Format: "reagent_id" = potency multiplier
	// Stronger reagents must always come first to avoid being displaced by weaker ones.
	// Total amount of any reagent in plant is calculated by formula: 1 + round(potency * multiplier)

	var/innate_yieldmod = 1 //modifier for yield, seperate to the one in Hydro trays, as that one is SPECIFICALLY for nutriment/chems (which means it's constantly reset)
	//This is added onto the yield mod of the hydro tray, yield *= (parent.yieldmod+innate_yieldmod)
	
	var/weed_rate = 1 //If the chance below passes, then this many weeds sprout during growth
	var/weed_chance = 5 //Percentage chance per tray update to grow weeds

/obj/item/seeds/New(loc, nogenes = 0)
	..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

	if(!icon_grow)
		icon_grow = "[species]-grow"

	if(!icon_dead)
		icon_dead = "[species]-dead"

	if(!icon_harvest && plant_type != PLANT_MUSHROOM && yield != -1)
		icon_harvest = "[species]-harvest"

	if(!nogenes) // not used on Copy()
		genes += new /datum/plant_gene/core/lifespan(lifespan)
		genes += new /datum/plant_gene/core/endurance(endurance)
		if(yield != -1)
			genes += new /datum/plant_gene/core/yield(yield)
			genes += new /datum/plant_gene/core/production(production)
		if(potency != -1)
			genes += new /datum/plant_gene/core/potency(potency)

		for(var/p in genes)
			if(ispath(p))
				genes -= p
				genes += new p

		for(var/reag_id in reagents_add)
			genes += new /datum/plant_gene/reagent(reag_id, reagents_add[reag_id])

/obj/item/seeds/proc/Copy()
	var/obj/item/seeds/S = new type(null, 1)
	// Copy all the stats
	S.lifespan = lifespan
	S.endurance = endurance
	S.maturation = maturation
	S.production = production
	S.yield = yield
	S.potency = potency
	S.genes = list()
	for(var/g in genes)
		var/datum/plant_gene/G = g
		S.genes += G.Copy()
	S.reagents_add = reagents_add.Copy() // Faster than grabbing the list from genes.
	return S

/obj/item/seeds/proc/get_gene(typepath)
	return (locate(typepath) in genes)

/obj/item/seeds/proc/reagents_from_genes()
	reagents_add = list()
	for(var/datum/plant_gene/reagent/R in genes)
		reagents_add[R.reagent_id] = R.rate

/obj/item/seeds/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25)
	adjust_lifespan(rand(-lifemut,lifemut))
	adjust_endurance(rand(-endmut,endmut))
	adjust_production(rand(-productmut,productmut))
	adjust_yield(rand(-yieldmut,yieldmut))
	adjust_potency(rand(-potmut,potmut))


/obj/item/seeds/bullet_act(obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj, /obj/item/projectile/energy/florayield))

		var/rating = 1
		if(istype(loc, /obj/machinery/hydroponics))
			var/obj/machinery/hydroponics/H = loc
			rating = H.rating

		if(yield == 0)//Oh god don't divide by zero you'll doom us all.
			adjust_yield(1 * rating)
		else if(prob(1/(yield * yield) * 100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			adjust_yield(1 * rating)
	else
		return ..()


// Harvest procs
/obj/item/seeds/proc/getYield()
	var/return_yield = yield

	var/obj/machinery/hydroponics/parent = loc
	if(istype(loc, /obj/machinery/hydroponics))
		if(parent.yieldmod == 0)
			return_yield = min(return_yield, 1)//1 if above zero, 0 otherwise
		else
			return_yield *= (parent.yieldmod+innate_yieldmod)

	return return_yield

/obj/item/seeds/proc/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0
	var/list/result = list()
	var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
	var/product_name
	while(t_amount < getYield())
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new product(output_loc, src)
		result.Add(t_prod) // User gets a consumable
		if(!t_prod)
			return
		t_amount++
		product_name = t_prod.name
	if(getYield() >= 1)
		feedback_add_details("food_harvested","[product_name]|[getYield()]")
	parent.update_tray()

	return result

/obj/item/seeds/proc/prepare_result(obj/item/weapon/reagent_containers/food/snacks/grown/T)
	if(!T.reagents)
		return 0
	var/total_volume = 0
	for(var/reagent_id in reagents_add)
		total_volume += max(1, reagents_add[reagent_id] * potency)
	var/sanity_multiplier = total_volume ? min(1, T.reagents.maximum_volume / total_volume) : 1

	for(var/reagent_id in reagents_add)
		var/add_amount = sanity_multiplier * max(1, reagents_add[reagent_id] * potency )
		if(reagent_id == "blood") // Hack to make blood in plants always O-
			T.reagents.add_reagent(reagent_id, add_amount, list("blood_type"="O-"), no_react = TRUE)
			continue

		T.reagents.add_reagent(reagent_id, add_amount, 1, no_react = TRUE)
	T.reagents.handle_reactions()
	return 1


/// Setters procs ///
/obj/item/seeds/proc/adjust_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = Clamp(yield + adjustamt, 0, 10)

		if(yield <= 0 && plant_type == PLANT_MUSHROOM)
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/obj/item/seeds/proc/adjust_lifespan(adjustamt)
	lifespan = Clamp(lifespan + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/obj/item/seeds/proc/adjust_endurance(adjustamt)
	endurance = Clamp(endurance + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/obj/item/seeds/proc/adjust_production(adjustamt)
	if(yield != -1)
		production = Clamp(production + adjustamt, 2, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/obj/item/seeds/proc/adjust_potency(adjustamt)
	if(potency != -1)
		potency = Clamp(potency + adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency


/obj/item/seeds/proc/get_analyzer_text()  //in case seeds have something special to tell to the analyzer
	var/text = ""
	switch(plant_type)
		if(PLANT_NORMAL)
			text += "- Plant type: Normal plant\n"
		if(PLANT_WEED)
			text += "- Plant type: Weed. Can grow in nutrient-poor soil.\n"
		if(PLANT_MUSHROOM)
			text += "- Plant type: Mushroom. Can grow in dry soil.\n"
		else
			text += "- Plant type: <span class='warning'>UNKNOWN</span> \n"
	if(potency != -1)
		text += "- Potency: [potency]\n"
	if(yield != -1)
		text += "- Yield: [yield]\n"
	text += "- Maturation speed: [maturation]\n"
	if(yield != -1)
		text += "- Production speed: [production]\n"
	text += "- Endurance: [endurance]\n"
	text += "- Lifespan: [lifespan]\n"
	if(rarity)
		text += "- Species Discovery Value: [rarity]\n"

	text += "*---------*"

	return text

/obj/item/seeds/proc/on_chem_reaction(datum/reagents/S)  //in case seeds have some special interaction with special chems
	return

/obj/item/seeds/attackby(obj/item/O, mob/user, params)
	if (is_plant_analyzer(O))
		to_chat(user, "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.</span>")
		var/text = get_analyzer_text()
		if(text)
			to_chat(user, "<span class='notice'>[text]</span>")

		return
	..() // Fallthrough to item/attackby() so that bags can pick seeds up







// Checks plants for broken tray icons. Use Advanced Proc Call to activate.
// Maybe some day it would be used as unit test.
/proc/check_plants_growth_stages_icons()
	var/list/states = icon_states('icons/obj/hydroponics/growing.dmi')
	var/list/paths = typesof(/obj/item/seeds) - /obj/item/seeds - typesof(/obj/item/seeds/sample)

	for(var/seedpath in paths)
		var/obj/item/seeds/seed = new seedpath

		for(var/i in 1 to seed.growthstages)
			if("[seed.icon_grow][i]" in states)
				continue
			to_chat(world, "[seed.name] ([seed.type]) lacks the [seed.icon_grow][i] icon!")

		if(!(seed.icon_dead in states))
			to_chat(world, "[seed.name] ([seed.type]) lacks the [seed.icon_dead] icon!")

		if(seed.icon_harvest) // mushrooms have no grown sprites, same for items with no product
			if(!(seed.icon_harvest in states))
				to_chat(world, "[seed.name] ([seed.type]) lacks the [seed.icon_harvest] icon!")