------------------
-- Version: 1.1 --
------------------

-- Script: Bounty Board
-- Created by: Quickstraw

local bountyID = 8210
local bountyIDList = {}
local bountyPids = {}
local amountOfBounties = 0

local Methods = {}
Methods.DisplayBounties = function(pid, cmd)
	local list = ""
	local highPlayer
	local highPid = -1
	local highBounty = 0
	local prevPlayers = {}
	local stopLooping = true
	local k
	
	local k = amountOfBounties -- Empties bountyIDList and bountyPids
	while k >= 1 do
		table.remove(bountyIDList, k)
		table.remove(bountyPids, k)
		k = k - 1
	end
	
	amountOfBounties = 0
	
	repeat
		highBounty = 0
		for i, p in pairs(Players) do -- For each active player
			local currPid = p.pid
			local bounty = tes3mp.GetBounty(currPid)
			if bounty > highBounty then
				local listed = false
				for j = 0, #prevPlayers do -- For each player already found
					local prevPlayer = prevPlayers[j]
					if p == prevPlayer then
						listed = true
						break
					end
				end
				if not listed then
					highPlayer = p
					highPid = currPid
					highBounty = bounty
				end
			end
		end
		if highBounty > 0 then
			table.insert(prevPlayers, highPlayer)
			local highName = tes3mp.GetName(highPid)
			list = list .. highName .. ":" .. " " .. highBounty .. " gold" .. "\n"
			stopLooping = false
			
			amountOfBounties = amountOfBounties + 1
			table.insert(bountyIDList, bountyID + amountOfBounties)
			table.insert(bountyPids, highPid)
		else
			stopLooping = true
		end
	until(stopLooping)
	
	if list == "" then
		list = "There are currently no bounties."
	end
	
	tes3mp.ListBox(pid, bountyID, "Current Most Wanted", list)
end

Methods.OnGuiAction = function(eventStatus, pid, idGui, data)
	if idGui == bountyID then
	
		local checkBountyButtons = false
		local i = 0
		repeat
			
			if tonumber(data) == i then
				local selectedPid = bountyPids[i+1]
			
				local name = tes3mp.GetName(selectedPid) -- Check if the player is connected. name will be nil if the player disconnected while the bounty board is active.
				
				if name == nil then
					tes3mp.ListBox(pid, bountyIDList[i + 1], "Criminal Has Vanished", "The selected criminal cannot be found!")
					break
				else
				
					local race = tes3mp.GetRace(selectedPid)
					local class
					local bounty = tes3mp.GetBounty(selectedPid)
					local gender
				
					if tes3mp.IsClassDefault(selectedPid) then
						class = tes3mp.GetDefaultClass(selectedPid)
					else
						class = tes3mp.GetClassName(selectedPid)
					end
					
					class = class:sub(1,1):upper() .. class:sub(2) -- Capitalize first letter of the class.
					
					if tes3mp.GetIsMale(selectedPid) then
						gender = "Male"
					else
						gender = "Female"
					end
					
					local bountyMessage = "Up to " .. bounty .. " coins " .. "reward for the capture of:\n" .. name .. ".\n\n"
					local bountyMessage2 = "DESCRIPTION: " .. gender .. " " .. race .. " " .. class
					
					tes3mp.ListBox(pid, bountyIDList[i + 1], "Wanted: " .. name, bountyMessage .. bountyMessage2)
					break
				
				end
			end
			
			i = i + 1
			if i >= amountOfBounties then
				checkBountyButtons = true
			end
			
		until(checkBountyButtons)
		
	else
		local idGuiMatch = false
		
		for k = 1, amountOfBounties, 1 do
			if idGui == bountyIDList[k] then
				idGuiMatch = true
				break
			end
		end
		
		if idGuiMatch then
			Methods.DisplayBounties(pid, "bounties")
		end	
	end
	
	return eventStatus
	
end

customEventHooks.registerHandler("OnGUIAction", Methods.OnGuiAction)
customCommandHooks.registerCommand("bounties", Methods.DisplayBounties)

return Methods
