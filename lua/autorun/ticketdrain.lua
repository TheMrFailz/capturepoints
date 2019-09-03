--[[
	This file controls how cap points are drained depending on the gamemode. Also may control other functions.

	Mode:
		Baik - Classic "own a point drain the tickets"

		Conquest - Tickets don't drain, respawns do(?)
		
		Supremacy - Tickets drain like in baik mode.

		tdm - Tickets drain for kills. 

		CTF - Build up tickets via caps?
]]

-- Variables

local deathloss = 5 -- How many tickets are lost on death?

-- Switches between drain modes depending on the gamemode.
function drainswitcher()
	if gpoint_mode == 0 then
		drain_0()
	
	elseif gpoint_mode == 1 then
	
	elseif gpoint_mode == 2 then
	
	elseif gpoint_mode == 3 then
		drain_3()
	elseif gpoint_mode == 4 then

	else

		print("Error! Invalid mode!")

	end
	
end

-- Standard Baikonour Style Drain
function drain_0()

	if gpoint_TicketTimer < CurTime() then
		gpoint_TicketTimer = CurTime() + gpoint_TicketDelay
		local teamBPoints = 0
		local teamAPoints = 0

		local pointsinfo = ents.FindByClass("gpointcap")
		--PrintTable(pointsinfo)
		for i = 1, table.Count(pointsinfo) do
			
			if pointsinfo[i].OwnerTeam == gpoint_TeamAID then
				teamAPoints = teamAPoints + 1
			end
			if pointsinfo[i].OwnerTeam == gpoint_TeamBID then
				teamBPoints = teamBPoints + 1
			end
		end
		
		if teamATickets > 0 && teamBTickets > 0 then
			
			teamATickets = teamATickets - (1 * gpoint_TicketMulti * teamBPoints)
			teamBTickets = teamBTickets - (1 * gpoint_TicketMulti * teamAPoints)
		else
			if teamATickets <= 0 then
				gpoint_TicketTimer = CurTime() + 1000
				PrintMessage( HUD_PRINTCENTER, team.GetName(gpoint_TeamBID) .. " has won! Restart in 10 seconds...")
				gpoint_Battles_C = gpoint_Battles_C + 1
				local playerlist = player.GetAll()
				print("Current battles: " .. gpoint_Battles_C)

				if gpoint_Battles_C < gpoint_Battles then
					for i = 1, table.Count(playerlist) do
						if playerlist[i]:Team() != gpoint_TeamBID then
							
							playerlist[i]:Kill()
						end
						
					end
					
					timer.Simple(10, function()
						startuptickets()


					end)
				else
					print("Going to vote map.")
					gpoint_vote4newmap()
				end

			elseif teamBTickets <= 0 then
				gpoint_TicketTimer = CurTime() + 1000
				PrintMessage( HUD_PRINTCENTER, team.GetName(gpoint_TeamAID) .. " has won! Restart in 10 seconds...")
				gpoint_Battles_C = gpoint_Battles_C + 1
				local playerlist = player.GetAll()
				print("Current battles: " .. gpoint_Battles_C)
				
				if gpoint_Battles_C < gpoint_Battles then
					for i = 1, table.Count(playerlist) do
						if playerlist[i]:Team() != gpoint_TeamAID then
							playerlist[i]:Kill()
						end
						
					end
				

					timer.Simple(10, function()
						startuptickets()


					end)
				else
					print("Going to vote map.")
					gpoint_vote4newmap()
				end
			end
		end

		--print(teamATickets)

		net.Start("ticketsupdate")
			net.WriteInt(teamATickets, 32)
			net.WriteInt(teamBTickets, 32)
		net.Broadcast()
		
	end



end

local drainondeath = GetConVar("gpoints_killdrain")


hook.Add("PlayerDeath", "DeathTicketDrain", function(victim, weapon, killer)
	
	if drainondeath == "1" then

		if victim != killer and killer != nil then

			if victim:Team() == gpoint_TeamAID then
				teamATickets = teamATickets - deathloss
			elseif victim:Team() == gpoint_TeamBID then
				teamBTickets = teamBTickets - deathloss
			end

			net.Start("ticketsupdate")
				net.WriteInt(teamATickets, 32)
				net.WriteInt(teamBTickets, 32)
			net.Broadcast()

			
		if teamATickets > 0 && teamBTickets > 0 then
			
			teamATickets = teamATickets - (1 * gpoint_TicketMulti * teamBPoints)
			teamBTickets = teamBTickets - (1 * gpoint_TicketMulti * teamAPoints)
		else
			if teamATickets <= 0 then
				gpoint_TicketTimer = CurTime() + 1000
				PrintMessage( HUD_PRINTCENTER, team.GetName(gpoint_TeamBID) .. " has won! Restart in 10 seconds...")
				gpoint_Battles_C = gpoint_Battles_C + 1
				local playerlist = player.GetAll()
				print("Current battles: " .. gpoint_Battles_C)

				if gpoint_Battles_C < gpoint_Battles then
					for i = 1, table.Count(playerlist) do
						if playerlist[i]:Team() != gpoint_TeamBID then
							
							playerlist[i]:Kill()
						end
						
					end
					
					timer.Simple(10, function()
						startuptickets()


					end)
				else
					print("Going to vote map.")
					gpoint_vote4newmap()
				end

			elseif teamBTickets <= 0 then
				gpoint_TicketTimer = CurTime() + 1000
				PrintMessage( HUD_PRINTCENTER, team.GetName(gpoint_TeamAID) .. " has won! Restart in 10 seconds...")
				gpoint_Battles_C = gpoint_Battles_C + 1
				local playerlist = player.GetAll()
				print("Current battles: " .. gpoint_Battles_C)
				
				if gpoint_Battles_C < gpoint_Battles then
					for i = 1, table.Count(playerlist) do
						if playerlist[i]:Team() != gpoint_TeamAID then
							playerlist[i]:Kill()
						end
						
					end
				

					timer.Simple(10, function()
						startuptickets()


					end)
				else
					print("Going to vote map.")
					gpoint_vote4newmap()
				end
			end
		end
		end
	end
end) 

