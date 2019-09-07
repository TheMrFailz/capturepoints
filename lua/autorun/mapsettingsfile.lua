--[[
	This file controls loading map settings. These include:
		Capture point locations.
		Spawnpoints.
		
]]



if CLIENT then return false end

print("Map loader file initialized.")


if enableCapturePointGamemode == true then

	
	-- Function to check for existing cap points.
	function loadExistingCapPoint()
		-- Grab the current map.
		local mapName = game.GetMap()

		-- All capture point data files will be saved in this name format.
		local pointFileName = "gpoints_" .. mapName .. ".txt"

		-- File loading
		local pointFile = file.Read(pointFileName, "DATA")
		
		-- Check if it loaded
		if not pointFile then
			print("[NOTE] No map capture point file found! Disabling gamemode.")
			enableCapturePointGamemode = false
			return
		end

		if enableCapturePointGamemode == false then return end

		-- Split the data up into a table.
		pointFile = string.Split(pointFile, "|")


		-- Sub-Table each dataline
		pointFileData = {}
		
		for i = 1, table.Count(pointFile) do
			local lineData = string.Split(pointFile[i], ";")
			pointFileData[i] = {}
			-- Get and set name
			pointFileData[i][1] = lineData[1]
			-- Get and set position
			pointFileData[i][2] = util.StringToType(lineData[2], "Vector")
			-- Get and set angles
			pointFileData[i][3] = util.StringToType(lineData[3], "Angle")
			
			
		end


		
		for i = 1, table.Count(pointFileData) do
			-- Doing a safety check because dumb things happen.
			if pointFileData[i][1] != "" then
				
				local newPoint = ents.Create("gpointcap")
				newPoint:SetPos(pointFileData[i][2])
				newPoint:SetAngles(pointFileData[i][3])
				newPoint:DropToFloor()
				newPoint:Spawn()
				newPoint.pointName = pointFileData[i][1]

				newPoint:SetNWString("PointNameG", newPoint.pointName)


				table.insert(gpCapturePointTable, newPoint)
				
				newPointVal = {newPoint.pointName, newPoint:GetPos(), Color(200,200,200)}

				table.insert(cappostable, newPointVal)


			end
		end 
		
		
		

	end

	hook.Add("InitPostEntity", "loadGCapPoints", loadExistingCapPoint)
	


	-- Function to check for existing spawn points.
	function loadExistingSpawnPoint()
		-- Grab the current map.
		local mapName = game.GetMap()
		
		-- All spawn point data files will be saved in this name format.
		local spawnFileName = "gpoints_" .. mapName .. "_sp.txt"

		-- File loading
		local pointFile = file.Read(spawnFileName, "DATA")
		
		-- Check if it loaded
		if not pointFile then
			print("[NOTE] No map spawn point file found! Disabling gamemode.")
			enableCapturePointGamemode = false
			return
		end

		if enableCapturePointGamemode == false then return end

		-- Split the data up into a table.
		pointFile = string.Split(pointFile, "|")
		table.remove(pointFile, 1)

		-- Sub-Table each dataline
		spawnpostable = {}
		for i = 1, table.Count(pointFile) do
			local lineData = string.Split(pointFile[i], ";")
			spawnpostable[i] = {}
			-- Get and set owner
			spawnpostable[i][1] = lineData[1]
			-- Get and set position
			spawnpostable[i][2] = util.StringToType(lineData[2], "Vector")
			-- Get and set angles
			spawnpostable[i][3] = util.StringToType(lineData[3], "Angle")
			
			
		end

		for i = 1, table.Count(spawnpostable) do
			if spawnpostable[i][1] == "a" then
				table.insert(spawnpostableA, spawnpostable[i])
			elseif spawnpostable[i][1] == "b" then
				table.insert(spawnpostableB, spawnpostable[i])
			end 
			
		end

	end
	concommand.Add("loadSP", loadExistingSpawnPoint)
	hook.Add("InitPostEntity", "loadGSpawnPoints", loadExistingSpawnPoint)

	

	-- Save all existing spawn points.
	function saveExistingSpawnPoint()
		local mapName = game.GetMap()
		
		local pointFileName = "gpoints_" .. mapName .. "_sp.txt"

		local pointData = ""

		for k, v in pairs( spawnpostableA ) do
			if v != nil then 
				pointData = pointData .. "|"
				pointData = pointData .. "a" .. ";"
				pointData = pointData .. tostring(spawnpostableA[k][1]) .. ";"
				pointData = pointData .. tostring(spawnpostableA[k][2])
			end
			
		end

		for k, v in pairs( spawnpostableB ) do
			if v != nil then 
				pointData = pointData .. "|"
				pointData = pointData .. "b" .. ";"
				pointData = pointData .. tostring(spawnpostableB[k][1]) .. ";"
				pointData = pointData .. tostring(spawnpostableB[k][2])
			end
			
		end

		file.Write(pointFileName, pointData)

		local pointFile = file.Read(pointFileName, "DATA")
		
		if not pointFile then
			print("[NOTE] No map spawn file found! (Failure to save?)")
			return
		end

		print("Done generating spawn file!")
		
		
	end

	-- Function to generate demo file
	function genDemoCapPointFile()
		
		local mapName = game.GetMap()
		
		local pointFileName = "gpoints_" .. mapName .. ".txt"

		local demoData = ""
		demoData = demoData .. "Sewage Treatment Plant" .. ";"
		demoData = demoData .. tostring(Vector(5064.678223, 6183.981445, -11079.968750)) .. ";"
		demoData = demoData .. tostring(Angle(0, 0, 0.000000)) .. ";"
		demoData = demoData .. "|"

		demoData = demoData .. "Park" .. ";"
		demoData = demoData .. tostring(Vector(-2196.038086, -656.194824, -11071.968750)) .. ";"
		demoData = demoData .. tostring(Angle(0, 0, 0.000000)) .. ";"

		
		demoData = demoData .. "Hotel" .. ";"
		demoData = demoData .. tostring(Vector(-4112.035645, -8567.748047, -11079.968750)) .. ";"
		demoData = demoData .. tostring(Angle(0, 0, 0.000000)) .. ";"

		file.Write(pointFileName, demoData)

		local pointFile = file.Read(pointFileName, "DATA")
		
		if not pointFile then
			print("[NOTE] No map capture point file found! (Failure to save?)")
			return
		end

		print("Done generating point file!")
	end

	-- Save all currently loaded cap points.
	function saveExistingCapPoint()
		local mapName = game.GetMap()
		
		local pointFileName = "gpoints_" .. mapName .. ".txt"

		local pointData = ""

		for k, v in pairs( gpCapturePointTable ) do
			if v != nil then 
				pointData = pointData .. "|"
				pointData = pointData .. v.pointName .. ";"
				pointData = pointData .. tostring(v:GetPos()) .. ";"
				pointData = pointData .. tostring(v:GetAngles())
			end
			
		end

		file.Write(pointFileName, pointData)

		local pointFile = file.Read(pointFileName, "DATA")
		
		if not pointFile then
			print("[NOTE] No map capture point file found! (Failure to save?)")
			return
		end

		print("Done generating point file!")
		
		
	end

	-- Spawn a particular cap point.
	function spawnCapPoint(ply, args)
		

		local newPoint = ents.Create("gpointcap")
		newPoint:SetPos(ply:GetPos())
		newPoint:SetAngles(Angle(0,0,0))
		newPoint:DropToFloor()
		newPoint:Spawn()
		
		

		local nameforcap = ""

		for i = 1, table.Count(args) do
			nameforcap = nameforcap .. args[i] .. " "
		end
		newPoint.pointName = nameforcap

		

		table.insert(gpCapturePointTable, newPoint)


	end

	-- load custom map settings for a particular map. 
	-- format: Ticket multiplier integer, Total battles before map change, max tickets for each team
	function loadmapsettingsfile()
		local mapName = game.GetMap()
		local mapsettingsfile = file.Read("gpoints_" .. mapName .. "_settings.txt", "DATA")

		if mapsettingsfile == nil then
			print("No custom map settings file found! Create one using the 'gpoint_newmapsetting' command!")
			print("Loading default gamemode settings...")
		else
			print("Loaded custom map settings.")
			mapsettingsfile = string.Split(mapsettingsfile, ";")
			PrintTable(mapsettingsfile)
			gpoint_TicketMulti = util.StringToType(mapsettingsfile[1],"int")
			gpoint_Battles = util.StringToType(mapsettingsfile[2],"int")
			teamATickets = util.StringToType(mapsettingsfile[3],"int")
			teamBTickets = util.StringToType(mapsettingsfile[3],"int")

		end
	end

	function newmapsettings()
		file.Write("gpoints_" .. mapName .. "_settings.txt", "2;4;300")
		if file.Read("gpoints_" .. mapName .. "_settings.txt", "DATA") != nil then
			print("New map settings file created successfully! Reboot for effect.")
		else
			print("An error has occurred while saving your map settings.")
		end

	end
	
end



