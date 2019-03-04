------------------
-- Version: 1.0 --
------------------

-- Script: Bounty Board
-- Created by: Quickstraw

local Methods = {}
Methods.DisplayBounties = function(pid)
	local list = ""
	local highPlayer
	local highPid = -1
	local highBounty = 0
	local prevPlayers = {}
	local stopLooping = true
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
		else
			stopLooping = true
		end
	until(stopLooping)
	
	if list == "" then
		list = "There are currently no bounties."
	end
	
	tes3mp.ListBox(pid, 8201, "Current Most Wanted", list)
end

return Methods