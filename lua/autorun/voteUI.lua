include("cappointbase.lua")

if SERVER then return false end

--[[
	Clientside UI files.


]]


function cappoint_ui_vote(maps, modes)
	
	-- Incase someone starts us with invalid or broken arguments.
	if !istable(maps) then
		maps = {} 
	end
	
	-- Incase someone starts us with invalid or broken arguments.
	if !istable(modes) then
		modes = {}
	end

	local userchoicemap = 1 -- Which map they picked.
	local userchoicemode = 1 -- Which mode they picked.
	local userchoicekillloss = false -- Whether or not they want deaths to count.
	
	local framewidth = 140
	local frameheight = 150

	local frame = vgui.Create("DFrame")
	frame:SetPos(20, ScrH() / 2 - (frameheight - 2))
	frame:SetSize(framewidth, frameheight)
	frame:SetTitle("Vote for the next map!")
	frame:SetVisible(true)
	frame:SetDraggable( true )
	frame:ShowCloseButton( true )
	frame:MakePopup()

	
	local maplist = vgui.Create("DComboBox", frame)
	maplist:SetPos( 10, 30)
	maplist:SetSize( 120, 20)
	maplist:SetValue("maps")
	
	for i = 1, #maps do
		maplist:AddChoice(maps[i])
	end
	
	maplist.OnSelect = function(self, index, value)
		userchoicemap = index
		
	end
	

	local modelist = vgui.Create("DComboBox", frame)
	modelist:SetPos( 10, 60)
	modelist:SetSize( 120, 20)
	modelist:SetValue("modes")
	
	for i = 1, #modes do
		modelist:AddChoice(modes[i][1])
	end
	
	modes.OnSelect = function(self, index, value)
		userchoicemode = index
		
	end
	
	local killdraincheck = vgui.Create("DCheckBoxLabel", frame)
	killdraincheck:SetPos(10, 90)
	killdraincheck:SetValue(0)
	killdraincheck:SetText("Drain points on kills?")
	
	function killdraincheck:OnChange(val)
		userchoicekillloss = val
	end
	
	local votebutton = vgui.Create("DButton", frame)
	votebutton:SetPos(10, 110)
	votebutton:SetSize(120, 30)
	votebutton:SetText("Vote!")
	
	votebutton.DoClick = function()
		net.Start("broadcastvoteuig")
			net.WriteInt(userchoicemap,32)
			net.WriteInt(userchoicemode, 32)
			net.WriteBool(userchoicekillloss)
		net.SendToServer()
		frame:Remove()
	end

end

net.Receive("broadcastvoteuig", function()
	local maps = net.ReadTable()
	local modes = net.ReadTable()
	cappoint_ui_vote(maps, modes)
	
	
end)

concommand.Add("cpvotetest", function(ply, cmd, args)
	maps2vote = {
		"gm_flatgrass",
		"gm_construct",
		"gm_spoon"
	}

	mapoptions = {
		"Classic Baikonour",
		"TDM",
		"Masturbation is a sin",
		"Conquest"
	}

	cappoint_ui_vote(maps2vote, mapoptions)

end)
