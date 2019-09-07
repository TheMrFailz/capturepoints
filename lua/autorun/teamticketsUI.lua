include("cappointbase.lua")

--[[
	Clientside UI files.


]]



if CLIENT then


	local pointpostable

	local ticketwindow

	function maketicketwindow()

	
		local teamATick = 0
		local teamBTick = 0

		ticketwindow = vgui.Create( "DFrame" )
		ticketwindow:SetPos( (ScrW() / 2) - (310 / 2), 25 )
		ticketwindow:SetSize( 310, 100 )
		ticketwindow:SetTitle( "Tickets" )
		ticketwindow:SetVisible( true )
		ticketwindow:SetDraggable( true )
		ticketwindow:ShowCloseButton( false )
		--ticketwindow:MakePopup()
		
		local teamALabel = vgui.Create("DLabel", ticketwindow)
		teamALabel:SetPos(10,25)
		teamALabel:SetSize(200 - 20 / 2, 100 - 25 - 5)
		teamALabel:SetText("Team Red: " .. teamATick)
		teamALabel:SetFont("Trebuchet24")
		
		local teamBLabel = vgui.Create("DLabel", ticketwindow)
		teamBLabel:SetPos(60 + 200 / 2,25)
		teamBLabel:SetSize(200 - 10 / 2, 100 - 25 - 5)
		teamBLabel:SetText("Team Blue: " .. teamBTick)
		teamBLabel:SetFont("Trebuchet24")
		
		net.Receive("ticketsupdate", function(len, ply)
			teamATick = net.ReadInt(32)
			teamBTick = net.ReadInt(32)
			if teamALabel != nil and teamBLabel != nil then
				teamALabel:SetText("Team Red: " .. teamATick)
				teamBLabel:SetText("Team Blue: " .. teamBTick)
			end
		end)
	
	end

	concommand.Add("forcegenticketui", maketicketwindow)

	net.Receive("maketicketuithing", function(len, ply)

		pointpostable = net.ReadTable()

		if ticketwindow == nil then
			maketicketwindow()
			print("Initializing ticket window...")
		end
	end)
	

	function teamchooseg(act, bct)
		if act == nil then
			act = 0
		end
		if bct == nil then
			bct = 0
		end

		local spawnwindow = vgui.Create( "DFrame" )
		spawnwindow:SetPos( ScrW() / 2 - 150, ScrH() / 2 - 75 )
		spawnwindow:SetSize( 300, 150 )
		spawnwindow:SetTitle( "Teams" )
		spawnwindow:SetVisible( true )
		spawnwindow:SetDraggable( true )
		spawnwindow:ShowCloseButton( true )
		spawnwindow:MakePopup()
		
		local teamAButton = vgui.Create("DButton", spawnwindow)
		teamAButton:SetText("Join Team Red (" .. act .. ")")
		teamAButton:SetPos(5, 30)
		teamAButton:SetSize(300 / 2 - 10, 150 - 40)
		teamAButton.DoClick = function()
			RunConsoleCommand( "joinGTeamA" )
			spawnwindow:Remove()
		end
		
		local teamBButton = vgui.Create("DButton", spawnwindow)
		teamBButton:SetText("Join Team Blue (" .. bct .. ")")
		teamBButton:SetPos(300 / 2 + 5, 30)
		teamBButton:SetSize(300 / 2 - 10, 150 - 40)
		teamBButton.DoClick = function()
			RunConsoleCommand( "joinGTeamB" )
			spawnwindow:Remove()
		end
	end
	
	net.Receive("gpoint_teammenu", function(len, ply)
		local act = net.ReadInt(32)
		local bct = net.ReadInt(32)
		teamchooseg(act,bct)
		
	end)
	

	local function DrawName( ply )
		if ( !IsValid( ply ) ) then return end
		if ( ply == LocalPlayer() ) then return end -- Don't draw a name when the player is you
		if ( !ply:Alive() ) then return end -- Check if the player is alive

		local Distance = LocalPlayer():GetPos():Distance( ply:GetPos() ) --Get the distance between you and the player

			if ( Distance < 5000 ) then --If the distance is less than 1000 units, it will draw the name

				if ply:GetNWBool("teambool") == LocalPlayer():GetNWBool("teambool") then
					cam.Start3D() -- Start the 3D function so we can draw onto the screen.
						render.SetMaterial( Material( "engine/lightsprite" ) ) -- Tell render what material we want, in this case the flash from the gravgun
						render.DrawSprite( ply:GetPos() + Vector(0,0,40), 24, 24, Color(182,255,156,255) ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
					cam.End3D()
					
				end

				
			end
	end
	hook.Add( "PostPlayerDraw", "DrawName", DrawName )
	
	net.Receive("capturepointcaptured", function(len, ply)
		surface.PlaySound("ui/scored.wav")
		
		
		
	end)
	
end