
AddCSLuaFile( "teamticketsUI.lua" )

include("ticketdrain.lua")
include("weightlimittech.lua")
include("mapsettingsfile.lua")

-- Enable / disable the whole thing.
enableCapturePointGamemode = true 
gpointEditorMode = true


-- HEY CHANGE THIS SHIT HERE OR NOTHING WILL WORK:
-- Team IDs
gpoint_TeamAID = 100 -- Team A's id, make it something unique.
gpoint_TeamBID = 101 -- Team B's id, make it something unique.
gpoint_TicketDelay = 5 -- Time between losing tickets.
gpoint_TicketMulti = 2 -- Points * this = tickets lost per ticket loss tick.
gpoint_VoteTime = 60

gpoint_Battles = 4 -- How many wins / losses before map vote 
gpoint_Battles_C = 0 -- counter for the above. Do not touch.

-- setting up each team
team.SetUp(gpoint_TeamAID, "Red Team", Color(255,0,0))
team.SetUp(gpoint_TeamBID, "Blue Team", Color(0,0,255))


-- todo: fix mode set

if SERVER && enableCapturePointGamemode == true then

	print("GPOINTS Main File Loaded.")

	gpCapturePointTable = {} -- Table of all the points for this given instance.
	cappostable = {} -- NGL I don't actually remember what the point of this variable is.

	spawnpostable = {}
	spawnpostableA = {}
	spawnpostableB = {}

	if ConVarExists("gpoints_maxweight") == false then
		CreateConVar("gpoints_maxweight", 60000, FCVAR_ARCHIVE, "Maximum tank weightlimit.")
	end
	
	local settingsfile = file.Read("gpoint_settings.txt", "DATA")

	if settingsfile == nil then
		print("Failed to read settings file, creating a new one...")
		file.Write("gpoint_settings.txt", "0;0")
		if file.Read("gpoint_settings.txt", "DATA") != nil then
			print("New settings file created successfully!")

			settingsfiledat = string.Split(settingsfile, ";")
		else
			print("An error has occurred while saving your settings.")
		end
	else

		settingsfile = string.Split(settingsfile, ";")

	end

	

	gpoint_mode = tonumber(settingsfile[1]) -- Gameplay mode. 0 = normal baik, 1 = conquest, 2 = supremacy, 3 = tdm, 4 = capture the flag
	gpoint_killdrain = tonumber(settingsfile[2])

	print("Capture Points Initialized")
	print("starting w/ caps: " .. gpoint_Battles_C .. " max is " .. gpoint_Battles)
	
	-- Team ticket stuff
	teamATickets = 300
	teamBTickets = 300
	
	loadmapsettingsfile()
	
	if gpoint_MapWeightLimit != nil then
		gmaxweightshoot = gpoint_MapWeightLimit + 1
	end

	-- Maps that are getting voted on (used for counting votes) 
	local votedmapslist = {}
	
	-- Modes, used for voting later.
	local modes2send = {
		{"Classic Baikonour", 0},
		{"FILLERDOESNOTWORK", 0},
		{"TDM", 0}
	}

	-- Vote counters for kill drains.
	local killdrainyes = 0
	local killdrainno = 0

	-- networking precache
	util.AddNetworkString( "ticketsupdate" )
	util.AddNetworkString( "maketicketuithing" )
	util.AddNetworkString( "gpoint_teammenu" )
	util.AddNetworkString( "capturepointcaptured" )
	util.AddNetworkString( "broadcastvoteuig" )

	


	-- Start up the UI
	function maketicketui(ply)
		if enableCapturePointGamemode == false then return end
		net.Start("maketicketuithing")
			net.WriteTable(cappostable)
		net.Send(ply)
		
		if ply:Team() == gpoint_TeamAID then
			local telepos = table.Random(spawnpostableA)[2]

			if telepos != nil then
				ply:SetPos(telepos)
			end

			
			ply:SetNWBool("teambool", false)

		elseif ply:Team() == gpoint_TeamBID then
			local telepos = table.Random(spawnpostableB)[2]

			if telepos != nil then
				ply:SetPos(telepos)
			end
			
			
			ply:SetNWBool("teambool", true)


		else
			
			net.Start("gpoint_teammenu")
			local acnt, bcnt = getTeamCounts()
			net.WriteInt(acnt, 32)
			net.WriteInt(bcnt, 32)
			net.Send(ply)
		end
		
		net.Start("ticketsupdate")
			net.WriteInt(teamATickets, 32)
			net.WriteInt(teamBTickets, 32)
		net.Broadcast()

	end
	hook.Add("PlayerSpawn", "maketicketwindow", maketicketui)
	
	-- Disable picking up the capture points with physgun.
	function disallowcappickup(ply, ent)
		if ent:GetClass() == "gpointcap" || ent:GetClass() == "floatymarker" then
			return false
			
		end
		
	end
	hook.Add("PhysgunPickup", "cappick", disallowcappickup)

	-- Disable the drive command. 
	hook.Add( "CanProperty", "omghedrove", function( ply, property )
		if( property == "drive" ) then
			return false;
		end 
		

	end )


	-- Ticket drain

	gpoint_TicketTimer = 0

	function startuptickets()
		if enableCapturePointGamemode == false then return end
		print("Starting tickets...")
		local playerlist = player.GetAll()
					
		for i = 1, table.Count(playerlist) do
			playerlist[i]:Kill()
			
		end
		
		teamATickets = 300
		teamBTickets = 300
		
		gpoint_TicketTimer = 0
	
		for k, v in pairs( gpCapturePointTable ) do
			if v != nil then 
				print(v)
				v.OwnerTeam = 0
				v.CapVal = 0
				v.ColorState = Color(200,200,200)
				v.marker:SetColor(Color(200,200,200))
			end
		end

	end

	-- Initiate a new votemap. Probably going to make my own vote.
	function gpoint_vote4newmap()
		local mapname = game.GetMap()
		local maps2add = file.Find("gpoints_*", "DATA")
		local maps2remove = {}
		local executestring = ""
		
		-- find duplicate maps.
		for i = 1, #maps2add do
			if string.EndsWith(maps2add[i], "_sp.txt") then
				table.insert(maps2remove, maps2add[i])
			end
		end

		for i = 1, #maps2add do
			if string.EndsWith(maps2add[i], "_settings.txt") then
				table.insert(maps2remove, maps2add[i])
			end
		end
		
		-- remove duplicate maps.
		for i = 1, #maps2remove do
			table.RemoveByValue(maps2add, maps2remove[i])
		end

		-- clean out any extensions or prefixes so we get the raw map name.
		for i = 1, #maps2add do
			maps2add[i] = string.StripExtension(maps2add[i])
			maps2add[i] = string.Replace( maps2add[i], "gpoints_", "")
			votedmapslist[i] = {maps2add[i], 1}
		end
		
		

		-- Network: Broadcast Yourself
		net.Start("broadcastvoteuig")
			net.WriteTable(maps2add)
			net.WriteTable(modes2send)
		net.Broadcast()

		timer.Simple(gpoint_VoteTime, gpoint_finalvotecount)
		
	end
	concommand.Add("gpoint_votemap", gpoint_vote4newmap)


	-- Function for each vote that comes in.
	function gpoint_receivevote(mapvote, modevote, drainvote)
		votedmapslist[mapvote][2] = votedmapslist[mapvote][2] + 1
		--modes2send[modevote][2] = modes2send[modevote][2] + 1
		
		if drainvote == false then
			--killdrainno = killdrainno + 1
		elseif drainvote == true then
			--killdrainyes = killdrainyes + 1
		end
		
	end

	net.Receive("broadcastvoteuig", function(len, ply)
		gpoint_receivevote(net.ReadInt(32),net.ReadInt(32), net.ReadBool())
		print(ply:Nick() .. " voted!")
	end)

	-- Final vote counting!
	function gpoint_finalvotecount()
		
		local winningmapid = 1
		local winningmodeid = 1
		
		for i = 1, #votedmapslist do
			
			if votedmapslist[i][2] > votedmapslist[winningmapid][2] then
				winningmapid = i
			end
		end
		
		for i = 1, #modes2send do
			if modes2send[i][2] > modes2send[winningmodeid][2] then
				--winningmodeid = i
			end
		end
			
		winningmodeid = 0

		if killdrainno > killdrainyes then
			--file.Write("gpoint_settings", (winningmodeid .. ";0"))
		elseif killdrainyes > killdrainno then
			--file.Write("gpoint_settings", (winningmodeid .. ";1"))
		end
		
		print("Winning map: " .. votedmapslist[winningmapid][1])
		print("Winning mode: " .. modes2send[winningmodeid][1])

		RunConsoleCommand("changelevel", votedmapslist[winningmapid][1])
	end

	concommand.Add("gpoint_tally", gpoint_finalvotecount)

	-- Drain tickets.
	function draintickets()
		if enableCapturePointGamemode == false then return end

		drainswitcher()
		
	end

	hook.Add("Think", "draintickets", draintickets)

	function getTeamCounts()
		local acount = #team.GetPlayers(gpoint_TeamAID)
		local bcount = #team.GetPlayers(gpoint_TeamBID)

		
		return acount, bcount
		
	end

	function joinGTeamA(ply)
		ply:SetTeam(gpoint_TeamAID)
		ply:Kill()
	end
	function joinGTeamB(ply)
		ply:SetTeam(gpoint_TeamBID)
		ply:Kill()
	end

	function openupteammenu(ply, numb)
		if numb == KEY_F4 then
			net.Start("gpoint_teammenu")
			local acnt, bcnt = getTeamCounts()
			net.WriteInt(acnt, 32)
			net.WriteInt(bcnt, 32)

			
			net.Send(ply)
		end
	end

	hook.Add("PlayerButtonDown", "openteammenug", openupteammenu)



	function addSpawnPointA(ply, args)
		local spawnposargs = {}
		spawnposargs[1] = ply:GetPos()
		spawnposargs[2] = ply:GetAngles()
		table.insert(spawnpostableA, spawnposargs)
		
	end

	function addSpawnPointB(ply, args)
		local spawnposargs = {}
		spawnposargs[1] = ply:GetPos()
		spawnposargs[2] = ply:GetAngles()
		table.insert(spawnpostableB, spawnposargs)
		
	end

	-- Add the commands if we're in editor mode:
	if gpointEditorMode == true then
		concommand.Add("genDemoCapPointFile", genDemoCapPointFile)
		concommand.Add("forceLoadExistingCapPoint", loadExistingCapPoint)
		concommand.Add("forceSaveExistingCapPoint", saveExistingCapPoint)
		concommand.Add("forceSpawnExistingCapPoint", function(ply, cmd, args)
			spawnCapPoint(ply, args)
			
		end)
		concommand.Add("joinGTeamA", joinGTeamA)
		concommand.Add("joinGTeamB", joinGTeamB)
		concommand.Add("addSpawnPointA", addSpawnPointA)
		concommand.Add("addSpawnPointB", addSpawnPointB)
		concommand.Add("saveExistingSpawnPoint", saveExistingSpawnPoint)
		concommand.Add("gpoint_newmapsetting", newmapsettings)

	end


else
	--print("Capture points not enabled")

end



