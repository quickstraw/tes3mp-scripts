------------------
-- Version: 1.0 --
------------------

-- Script: Bounty Hunters
-- Created by: Quickstraw

--- Spawns bounty hunters to hunt those with decently high bounties.		---
--- Bounty hunters spawn behind a player with a bounty every so often.		---
--- If a bounty hunter kills a player with a bounty, that player loses gold	---
--- equal to their bounty, and that player's bounty is lowered by the		---
--- amount of gold lost Bounty hunters despawn on cell unload when no		---
--- more players are in the cell.											---

BountyTimers = {}
BountyPause = {}
UniqueIndexes = {}
RefIds = {}
TIMER_MIN = 600000
TIMER_MAX = 900000

--	Classes with a focus in destruction are commented out.
--	Magic causes player deaths to look like suicides.
Classes = {
	{name = "acrobat", 		ranged = "throwing",weapons = { "spear" }, 				hasShield = false, 	armor = "light"},
	{name = "agent", 		ranged = nil, 		weapons = { "short blade" }, 		hasShield = true, 	armor = "light"},
	{name = "archer", 		ranged = "bow", 	weapons = { "long blade" }, 		hasShield = true, 	armor = "light"},
	{name = "assassin", 	ranged = "throwing",weapons = { "short blade" }, 		hasShield = true, 	armor = "light"},
	{name = "barbarian",	ranged = nil, 		weapons = { "axe", "blunt" }, 		hasShield = true, 	armor = "medium"},
	{name = "bard", 		ranged = nil, 		weapons = { "long blade" }, 		hasShield = true, 	armor = "medium"},
--	{name = "battlemage",	ranged = nil, 		weapons = { "axe" }, 				hasShield = false, 	armor = "heavy"},
--	{name = "crusader", 	ranged = nil, 		weapons = { "blunt", "long blade" },hasShield = true, 	armor = "heavy"},
	{name = "healer", 		ranged = nil, 		weapons = { "unarmed" }, 			hasShield = false,	armor = "unarmored"},
	{name = "knight", 		ranged = nil, 		weapons = { "long blade", "axe" },	hasShield = true, 	armor = "heavy"},
--	{name = "mage", 		ranged = nil, 		weapons = { "short blade" }, 		hasShield = false, 	armor = "unarmored"},
	{name = "monk", 		ranged = nil, 		weapons = { "unarmed" }, 			hasShield = false, 	armor = "unarmored"},
--	{name = "nightblade", 	ranged = nil, 		weapons = { "short blade" }, 		hasShield = false, 	armor = "light"},
	{name = "pilgrim", 		ranged = nil, 		weapons = { "short blade" }, 		hasShield = true, 	armor = "medium"},
	{name = "rogue", 		ranged = nil, 		weapons = { "short blade", "axe" }, hasShield = true, 	armor = "light"},
	{name = "scout", 		ranged = nil, 		weapons = { "long blade" }, 		hasShield = true, 	armor = "medium"},
--	{name = "sorcerer", 	ranged = nil, 		weapons = { "short blade" }, 		hasShield = false,	armor = "medium"},
--	{name = "spellsword",	ranged = nil, 		weapons = { "long blade" }, 		hasShield = true, 	armor = "medium"},
	{name = "thief", 		ranged = nil, 		weapons = { "short blade" }, 		hasShield = false, 	armor = "light"},
	{name = "warrior", 		ranged = nil, 		weapons = { "long blade" }, 		hasShield = true, 	armor = "heavy"},
	{name = "witchhunter",	ranged = "bow", 	weapons = { "blunt" }, 				hasShield = true, 	armor = "light"}
}

local Methods = {}

-- Called when Bounty Hunters should spawn on a player with a bounty.
TimedNPC = function(pid)
	local outside = tes3mp.IsInExterior(pid)
	
	local bounty = tes3mp.GetBounty(pid)
	local decentBounty = bounty >= 500

	if Players[pid] ~= nil and outside and decentBounty then
	
		local seed = tonumber(tostring(os.time()):reverse():sub(1,6))
		math.randomseed(seed)
		math.random(); math.random(); math.random()
	
		-- Spawn Bounty Hunters
		local spawnedMulti = false
		
		local uniqueIndex = Methods.GenerateNPC(pid)
		
		local uniqueIndex2
		
		if bounty > 2000 then
			local rand = math.random(1, 10)
			if (bounty / 1000) > rand then
				uniqueIndex2 = Methods.GenerateNPC(pid)
				spawnedMulti = true
			end
		end
		
		-- Send the spawned bounty hunters message
		if spawnedMulti then
			tes3mp.MessageBox(pid, -1, "Some bounty hunters have come to collect the price on your head!")
		else
			tes3mp.MessageBox(pid, -1, "A bounty hunter has come to collect the price on your head!")
		end
		
		tes3mp.RestartTimer(BountyTimers[pid], math.random(TIMER_MIN, TIMER_MAX))
	elseif not outside and decentBounty then
		if BountyPause[pid] == nil then -- If a pause timer does not exist...
			BountyPause[pid] = tes3mp.CreateTimerEx("RestartBountyTimer", 5000, "i", pid)
			tes3mp.StartTimer(BountyPause[pid])
		else
			tes3mp.RestartTimer(BountyPause[pid], 5000)
		end
	elseif not decentBounty then
		Methods.ClearTimers(pid)
	end
end

-- Called when a player with a bounty goes inside.
RestartBountyTimer = function(pid)
	local outside = tes3mp.IsInExterior(pid)
	local bounty = tes3mp.GetBounty(pid)
	local decentBounty = bounty >= 500
	
	if not outside and decentBounty then
		tes3mp.RestartTimer(BountyPause[pid], 5000)
	elseif outside and decentBounty then
		tes3mp.RestartTimer(BountyTimers[pid], math.random(10000, 20000))
	elseif not decentBounty then
		Methods.ClearTimers(pid)
	end
	
end

-- Generates a character's body and adds them to a given table representing an npc record.
Methods.GenerateChar = function(npcTable)
	local genderVal = math.random(0, 4)
	if genderVal == 0 then
		npcTable.gender = 0
	else
		npcTable.gender = 1
	end
	
	local raceVal = math.random(1, 100)
	local hairVal
	local headVal
	local underscore = true
	if raceVal > 37 then
		npcTable.race = "dark elf"
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 24)
			headVal = math.random(1, 10)
		else
			hairVal = math.random(1, 26)
			headVal = math.random(1, 17)
		end
		
	elseif raceVal > 27 then
		npcTable.race = "imperial"
		
				if npcTable.gender == 0 then
			hairVal = math.random(1, 7)
			headVal = math.random(1, 7)
		else
			hairVal = math.random(1, 9)
			headVal = math.random(1, 7)
		end
		
	elseif raceVal > 19 then
		npcTable.race = "orc"		
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 5)
			headVal = math.random(1, 3)
			underscore = false
		else
			hairVal = math.random(1, 5)
			headVal = math.random(1, 4)
		end
		
	elseif raceVal > 11 then
		npcTable.race = "nord"		
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 6)
			headVal = math.random(1, 13)
		else
			hairVal = math.random(0, 8)
			headVal = math.random(1, 13)
			underscore = false
		end
		
	elseif raceVal > 7 then
		npcTable.race = "redguard"		
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 5)
			headVal = math.random(1, 6)
		else
			hairVal = math.random(1, 6)
			headVal = math.random(1, 6)
		end
		
	elseif raceVal > 3 then
		npcTable.race = "breton"	
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 5)
			headVal = math.random(1, 6)
		else
			hairVal = math.random(1, 5)
			headVal = math.random(1, 8)
		end
		
	elseif raceVal > 1 then
		npcTable.race = "wood elf"		
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 5)
			headVal = math.random(1, 6)
		else
			hairVal = math.random(1, 6)
			headVal = math.random(1, 8)
		end
		
	else
		npcTable.race = "high elf"	
		
		if npcTable.gender == 0 then
			hairVal = math.random(1, 4)
			headVal = math.random(1, 6)
		else
			hairVal = math.random(1, 5)
			headVal = math.random(1, 6)
		end
		
	end
	
	local hairNum = "" .. hairVal
	local headNum = "" .. headVal
	local genderStr = "m"
	local underscoreStr = "_hair_"
	
	if hairVal < 10 then hairNum = "0" .. hairNum end
	if headVal < 10 then headNum = "0" .. headNum end
	if npcTable.gender == 0 then genderStr = "f" end
	if not underscore then underscoreStr = "_hair" end
	
	local hairStr = "b_n_" .. npcTable.race .. "_" .. genderStr .. underscoreStr .. hairNum
	local headStr = "b_n_" .. npcTable.race .. "_" .. genderStr .. "_head_" .. headNum
	
	npcTable.hair = hairStr
	npcTable.head = headStr
end

-- Selects a level based on a player.
Methods.CreateLevel = function(pid)
	local playerLevel = tes3mp.GetLevel(pid)
	
	local bounty = tes3mp.GetBounty(pid)
	
	-- Extra levels per 1000 on the player's bounty.
	local extraLevel = math.floor(bounty / 1000)
	
	local level
	
	if playerLevel <= 5 then
		level = 5
	elseif playerLevel < 20 then
		level = playerLevel
	else
		local intermediatelvl = playerLevel - 20
		intermediatelvl = (intermediatelvl * 2) / 3
		intermediatelvl = math.floor(intermediatelvl + 0.5)
		
		level = 20 + intermediatelvl
	end
	
	level = level + extraLevel
	
	return level
end

-- Selects a default class and adds it to a given table. Returns the selected class's relevant equipment.
Methods.CreateClass = function(npcTable)
	local class = Classes[math.random(1, #Classes)]
	npcTable.class = class.name
	return class
end

-- Add class relevant items to a given table representing an npc record.
Methods.AddItems = function(class, npcTable)
	local gold = {id = "gold_001", count = math.random(80, 150)}
	
	local rangedWeapon = {id, count}
	
	local weapon = {id, count = 1}
	local weaponId
	local weaponQuality = math.random(0, 3)
	
	-- Find ranged weapon to add
	if class.ranged ~= nil then
		if class.ranged == "bow" then
			rangedWeapon.id = "long bow"
			rangedWeapon.count = 1
			local ammo = { id = "iron arrow", count = 20 }
			table.insert(npcTable.items, rangedWeapon)
			table.insert(npcTable.items, ammo)
		elseif class.ranged == "throwing" then
			rangedWeapon.id = "iron throwing knife"
			rangedWeapon.count = 20
			table.insert(npcTable.items, rangedWeapon)
		end
	end
	
	-- Find weapon type to add
	local weaponType
	
	if #class.weapons > 1 then
		weaponType = class.weapons[math.random(1, #class.weapons)]
	else
		weaponType = class.weapons[1]
	end
	
	if weaponType == "long blade" then
		weaponId = "iron longsword"
	elseif weaponType == "short blade" then
		weaponId = "iron dagger"
	elseif weaponType == "blunt" then
		weaponId = "iron mace"
	elseif weaponType == "axe" then
		weaponId = "iron war axe"
	elseif weaponType == "spear" then
		weaponId = "iron long spear"
	end
	
	if weaponId ~= nil then
		weapon.id = weaponId
		table.insert(npcTable.items, weapon)
	end
	
	-- Find armor type
	local armorType = class.armor
	local armor = {}
	
	if armorType == "light" then
		local rand = math.random(1, 2)
		if rand == 1 then
			armor[1] = { id = "netch_leather_helm" , count = 1 }
			armor[2] = { id = "netch_leather_cuirass" , count = 1 }
			armor[3] = { id = "netch_leather_pauldron_left" , count = 1 }
			armor[4] = { id = "netch_leather_pauldron_right" , count = 1 }
			armor[5] = { id = "netch_leather_gauntlet_left" , count = 1 }
			armor[6] = { id = "netch_leather_gauntlet_right" , count = 1 }
			armor[7] = { id = "netch_leather_greaves" , count = 1 }
			armor[8] = { id = "netch_leather_boots" , count = 1 }
		end
		
		for i = 1, #armor + 1 do
			table.insert(npcTable.items, armor[i])
		end
		
		if class.hasShield then
			local shield = { id = "netch_leather_shield", count = 1 }
			table.insert(npcTable.items, shield)
		end
		
	elseif armorType == "medium" then
		armor[1] = { id = "bonemold_helm" , count = 1 }
		armor[2] = { id = "bonemold_cuirass" , count = 1 }
		armor[3] = { id = "bonemold_pauldron_l" , count = 1 }
		armor[4] = { id = "bonemold_pauldron_r" , count = 1 }
		armor[5] = { id = "bonemold_bracer_left" , count = 1 }
		armor[6] = { id = "bonemold_bracer_right" , count = 1 }
		armor[7] = { id = "bonemold_greaves" , count = 1 }
		armor[8] = { id = "bonemold_boots" , count = 1 }
		
		for i = 1, #armor + 1  do
			table.insert(npcTable.items, armor[i])
		end
		
		if class.hasShield then
			local shield = { id = "bonemold_shield", count = 1 }
			table.insert(npcTable.items, shield)
		end
		
	elseif armorType == "heavy" then
		armor[1] = { id = "iron_helmet" , count = 1 }
		armor[2] = { id = "iron_cuirass" , count = 1 }
		armor[3] = { id = "iron_pauldron_left", count = 1 }
		armor[4] = { id = "iron_pauldron_right", count = 1}
		armor[5] = { id = "iron_gauntlet_left", count = 1 }
		armor[6] = { id = "iron_gauntlet_right", count = 1 }
		armor[7] = { id = "iron_greaves", count = 1 }
		armor[8] = { id = "iron boots", count = 1 }
		
		for i = 1, #armor + 1 do
			table.insert(npcTable.items, armor[i])
		end
		
		if class.hasShield then
			local shield = { id = "iron_shield", count = 1 }
			table.insert(npcTable.items, shield)
		end
		
	elseif armorType == "unarmored" then
	
		local commonRobes = {
			"common_robe_01",
			"common_robe_02",
			"common_robe_02_h",
			"common_robe_02_hh",
			"common_robe_02_r",
			"common_robe_02_rr",
			"common_robe_02_t",
			"common_robe_02_tt",
			"common_robe_03",
			"common_robe_03_a",
			"common_robe_03_b",
			"common_robe_04",
			"common_robe_05",
			"common_robe_05_a",
			"common_robe_05_b",
			"common_robe_05_c",
			"BM_Nordic01_Robe",
			"BM_Wool01_Robe"
		}
		local commonShoes = {
			"common_shoes_01",
			"common_shoes_02",
			"common_shoes_03",
			"common_shoes_04",
			"common_shoes_05",
			"common_shoes_06",
			"common_shoes_07",
			"BM_Nordic01_shoes",
			"BM_Nordic02_shoes",
			"BM_Wool01_shoes",
			"BM_Wool02_shoes"
		}
		local robe
		local shoes
		if npcTable.race == "nord" then
			robe = { id = commonRobes[math.random(1,18)], count = 1 }
			shoes = { id = commonShoes[math.random(1, #commonShoes)], count = 1 }
		else
			robe = { id = commonRobes[math.random(1,16)], count = 1 }
			shoes = { id = commonShoes[math.random(1, #commonShoes - 4)], count = 1 }
		end
		table.insert(npcTable.items, robe)
	end
	
	-- Add clothes
	local commonShirts = {
		"common_shirt_01",
		"common_shirt_01_a",
		"common_shirt_01_e",
		"common_shirt_01_u",
		"common_shirt_01_z",
		"common_shirt_02",
		"common_shirt_02_h",
		"common_shirt_02_hh",
		"common_shirt_02_r",
		"common_shirt_02_rr",
		"common_shirt_02_t",
		"common_shirt_02_tt",
		"common_shirt_03",
		"common_shirt_03_b",
		"common_shirt_03_c",
		"common_shirt_04",
		"common_shirt_04_a",
		"common_shirt_04_b",
		"common_shirt_04_c",
		"common_shirt_05",
		"common_shirt_06",
		"common_shirt_07",
		"BM_Nordic01_shirt",
		"BM_Nordic02_shirt",
		"BM_Wool01_shirt",
		"BM_Wool02_shirt"
	}
	local commonPants = {
		"common_pants_01",
		"common_pants_01_a",
		"common_pants_01_e",
		"common_pants_01_u",
		"common_pants_01_z",
		"common_pants_02",
		"common_pants_03",
		"common_pants_03_b",
		"common_pants_03_c",
		"common_pants_04",
		"common_pants_04_b",
		"common_pants_05",
		"common_pants_06",
		"common_pants_07",
		"BM_Nordic01_pants",
		"BM_Nordic02_pants",
		"BM_Wool01_pants",
		"BM_Wool02_pants"
	}
	local shirt
	local pants
	
	if npcTable.race == "nord" then
		shirt = { id = commonShirts[math.random(1, #commonShirts)], count = 1 }
		pants = { id = commonPants[math.random(1, #commonPants)], count = 1 }
	else
		shirt = { id = commonShirts[math.random(1, #commonShirts - 4)], count = 1 }
		pants = { id = commonPants[math.random(1, #commonPants - 4)], count = 1 }
	end
	
	table.insert(npcTable.items, shirt)
	table.insert(npcTable.items, pants)
	table.insert(npcTable.items, shoes)
	
	table.insert(npcTable.items, gold)
end

-- Create a generated record given a table representing an npc record. Returns the id.
Methods.CreateRecord = function(pid, npcTable)
	local recordStore = RecordStores["npc"]
	local id = recordStore:GenerateRecordId()
	
	local savedTable = tableHelper.shallowCopy(npcTable)
	
	recordStore.data.generatedRecords[id] = savedTable
	
	tes3mp.ClearRecords()
	tes3mp.SetRecordType(enumerations.recordType["NPC"])
	packetBuilder.AddNpcRecord(id, savedTable)
	tes3mp.SendRecordDynamic(pid, true, false)
	
	return id
end

-- Uses several functions to generate and spawn a custom npc.
Methods.GenerateNPC = function(pid)

	local npcTable = {
		baseId = "BM_berserker_m1_lvl5",
		name = "Bounty Hunter",
		gender,
		race,
		hair,
		head,
		class = "battlemage",
		autoCalc = 1,
		aiFight = 90,
		level = 1,
		items = {}
	}
	
	local seed = tonumber(tostring(os.time()):reverse():sub(1,6))
	
	math.randomseed(seed)
	math.random(); math.random(); math.random()
	
	-- Generate character's race, gender, and head
	Methods.GenerateChar(npcTable)
	
	-- Select a level
	npcTable.level = Methods.CreateLevel(pid)
	
	-- Choose Class
	local class = Methods.CreateClass(npcTable)
	
	-- Add items
	Methods.AddItems(class, npcTable)

	-- Create Record
	local id = Methods.CreateRecord(pid, npcTable)
	
	local uniqueIndex = Methods.SpawnObjectBehindPlayer(pid, id)
	
	table.insert(UniqueIndexes, uniqueIndex)
	table.insert(RefIds, id)

	return uniqueIndex
end

Methods.CreateTimer = function(eventStatus, pid)
	local bounty = tes3mp.GetBounty(pid)
	local decentBounty = bounty >= 500
	
	local seed = tonumber(tostring(os.time()):reverse():sub(1,6))
	math.randomseed(seed)
	math.random(); math.random(); math.random()
	
	if decentBounty then
		if BountyTimers[pid] == nil then
			BountyTimers[pid] = tes3mp.CreateTimerEx("TimedNPC", math.random(TIMER_MIN, TIMER_MAX), "i", pid)
			tes3mp.StartTimer(BountyTimers[pid])
		end
	else
		Methods.ClearTimers(pid)
	end
end

Methods.ClearTimers = function(pid)
	BountyTimers[pid] = nil
	BountyPause[pid] = nil
end

Methods.SpawnObjectBehindPlayer = function(pid, id)
	local currCell = tes3mp.GetCell(pid)
    local location = {
        posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid),
        rotX = tes3mp.GetRotX(pid), rotY = 0, rotZ = tes3mp.GetRotZ(pid)
    }
	local newLocation = {
        posX, posY, posZ,
        rotX, rotY = 0, rotZ
    }
	local corAngle = location.rotZ + (math.pi / 2)
	local stepX = -math.cos(corAngle)
	local stepY = math.sin(corAngle)
	newLocation.posX = location.posX - (stepX * 500)
	newLocation.posY = location.posY - (stepY * 500)
	newLocation.posZ = location.posZ + 100
	newLocation.rotX = location.rotX
	newLocation.rotY = location.rotY
	newLocation.rotZ = location.rotZ
	
	return logicHandler.CreateObjectAtLocation(currCell, newLocation, id, "spawn")
end

-- Process death similar to the Criminals script
Methods.BountyHunterKill = function(eventStatus, pid)
	
	if not tes3mp.DoesPlayerHavePlayerKiller(pid) then
		local killerName = tes3mp.GetPlayerKillerName(pid)
		if killerName == "Bounty Hunter" then
		
			local bountyItem = "gold_001"
			local itemIndex
			local itemCount
			local newBounty
			local reward
			local message
			local playerName = tes3mp.GetName(pid)
			local currentBounty = tes3mp.GetBounty(pid)
		
			if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", bountyItem, true) then
				itemIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", bountyItem)
				itemCount = Players[pid].data.inventory[itemIndex].count -- find how much gold the player has
			else
				itemCount = 0
			end
			
			if itemCount >= currentBounty then -- if a bounty can be fully cleared, do so
				newBounty = 0
				reward = currentBounty
			else
				newBounty = currentBounty - itemCount -- otherwise, clear it only partially
				reward = itemCount
			end
			
			if itemCount ~= 0 then -- if the player actually has gold
				Players[pid].data.inventory[itemIndex].count = Players[pid].data.inventory[itemIndex].count - reward --remove the gold
				if Players[pid].data.inventory[itemIndex].count == 0 then
					Players[pid].data.inventory[itemIndex] = nil
				end
				Players[pid].data.fame.bounty = newBounty -- set new bounty
				tes3mp.SetBounty(pid, Players[pid].data.fame.bounty)
				tes3mp.SendBounty(pid)
				Players[pid]:LoadInventory() -- save inventories for both players
				Players[pid]:LoadEquipment()
				Players[pid]:Save()
			eventHandler.OnPlayerBounty(pid) -- Fire OnPlayerBounty to signal that the player's bounty has changed.
				tes3mp.MessageBox(pid, -1, reward .. " gold was taken by the bounty hunter.")
			end				
		end
	end
end

Methods.CleanupHunters = function(eventStatus, pid, cellDesc)
	local currCell = LoadedCells[cellDesc]
	local visitors = currCell.visitors

        if tableHelper.getCount(visitors) <= 1 then
            for i = 1, #UniqueIndexes + 1 do
				local currIndex = UniqueIndexes[i]
				local currId = RefIds[i]
				if currCell:ContainsObject(currIndex) then
					currCell:DeleteObjectData(currIndex)
					currCell:RemoveLinkToRecord(enumerations.recordType["NPC"], currId, currIndex)
				end
			end
        end
end

customEventHooks.registerHandler("OnPlayerFinishLogin", Methods.CreateTimer)
customEventHooks.registerHandler("OnPlayerBounty", Methods.CreateTimer)
customEventHooks.registerHandler("OnPlayerDeath", Methods.BountyHunterKill)
customEventHooks.registerValidator("OnCellUnload", Methods.CleanupHunters)

return Methods
