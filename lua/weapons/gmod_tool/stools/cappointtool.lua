TOOL.Category = "CapturePoints"
TOOL.Name = "Point Spawner"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
TOOL.ClientConVar[ "myparameter" ] = "fubar"



if SERVER then
	util.AddNetworkString( "genpoint" )
end

local clickdelay = 0

function TOOL:LeftClick( trace )
	if !self:GetOwner():IsSuperAdmin() then return false end
	if clickdelay > CurTime() then return false end

	if CLIENT then
		--print("penis engaged")
		enterPointName(trace.HitPos)
	end

	clickdelay = CurTime() + 0.5

end

function enterPointName(clickpos)
	if CLIENT then
		local x = 250
		local y = 100
		local window = vgui.Create( "DFrame" )
		window:SetPos( ScrW() / 2 - (x / 2), ScrH() / 2 - (y / 2) )
		window:SetSize( 260, 100 )
		window:SetTitle( "Enter Point Name" )
		window:SetVisible( true )
		window:SetDraggable( true )
		window:ShowCloseButton( true )
		window:MakePopup()
		
		local nameadd = vgui.Create("DTextEntry", window)
		nameadd:SetPos(5,30)
		nameadd:SetSize(x, y - 35)
		nameadd:SetText("")
		nameadd.OnEnter = function(self)
			print("My name is: " .. self:GetValue())
			
			--
			
			net.Start("genpoint")
				net.WriteString(self:GetValue())
				net.WriteVector(clickpos)
			net.SendToServer()

			window:Remove()

		end
		
		
	end
end

if SERVER then

function generateNewPoint(name, pos)
	local newPoint = ents.Create("gpointcap")
	newPoint:SetPos(pos + Vector(0,0,20))
	newPoint:SetAngles(Angle(0,0,0))
	newPoint:DropToFloor()
	newPoint:Spawn()
	
	

	newPoint.pointName = name
		
	--table.insert(gpCapturePointTable, newPoint)
end

net.Receive("genpoint", function(length, ply)
	local namething = net.ReadString()
	local pos = net.ReadVector()

	generateNewPoint(namething, pos)
	
end)

end
if SERVER then 
function TOOL:RightClick( trace )
	if !self:GetOwner():IsSuperAdmin() then return false end
	
	local newPoint = ents.Create("gpointspawn")
	newPoint:SetPos(trace.HitPos + Vector(0,0,20))
	newPoint:SetAngles(Angle(0,0,0))
	newPoint:DropToFloor()
	newPoint:Spawn()
	
end

end

function TOOL:Reload( trace )
	if !self:GetOwner():IsSuperAdmin() then return false end
	if SERVER then
		saveCapPoints()
	end
end
 
function saveCapPoints()
	local mapName = game.GetMap()
	
	local pointFileName = "gpoints_" .. mapName .. ".txt"

	local pointData = ""

	local points = ents.FindByClass("gpointcap")

	for k, v in pairs( points ) do
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
	
	

	local pointFileName2 = "gpoints_" .. mapName .. "_sp.txt"

	local pointData2 = ""

	local spawnpoints = ents.FindByClass("gpointspawn")

	for k, v in pairs( spawnpoints ) do
		if v != nil then 
			local colorval = v:GetColor()

			colorval = Vector(colorval["r"], colorval["g"], colorval["b"])
			pointData2 = pointData2 .. "|"
			if colorval == Vector(255,0,0) then
				pointData2 = pointData2 .. "a" .. ";"
			elseif colorval == Vector(0,0,255) then
				pointData2 = pointData2 .. "b" .. ";"
			end

			pointData2 = pointData2 .. tostring(v:GetPos()) .. ";"
			pointData2 = pointData2 .. tostring(Vector(0,180,0))
		end
		
	end

	file.Write(pointFileName2, pointData2)

	local pointFile2r = file.Read(pointFileName2, "DATA")
	
	if not pointFile2r then
		print("[NOTE] No map spawn file found! (Failure to save?)")
		return
	end

	print("Done generating spawn file!")
end


function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "Cap Point Spawner", Description = "Mouse1 to spawn a point. Mouse 2 to spawn a spawnpoint. Reload to save all. DANGER: This tool can seriously fuck shit up." })
	panel:AddControl("Header", { Text = "Cap Point Spawner", Description = "If a spawnpoint is spawned, please color either 255,0,0 or 0,0,255 to set team." })
end

