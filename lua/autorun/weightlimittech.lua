--[[ 
	This file controls weight limits and the like.



]]

if CLIENT then return false end

print("Weight limit file initialized.")

-- Delay and timer to keep player's chat from being instantly nuked.
-- Will get screwy if one player on the server keeps trying to spam auto weapons on an overloaded chassis.


local wlalertdelay = 1
local wlalertdelaytimer = 0

local teamAweightlimit = 300 * 1000
local teamBweightlimit = 300 * 1000

local teamAcurrweight = 0
local teamBcurrweight = 0

function weightlimitcheck(gunent, bullet)
	
	-- If we don't have a weight set yet (example, if it's just been spawned), tell acf to generate one.
	if gunent.acftotal == nil then
		ACF_CalcMassRatio(gunent, true)

	end

	local totalmass = 0
	
	totalmass = gunent.acftotal

	if gmaxweightshoot == nil then
		gmaxweightshoot = GetConVar("gpoints_maxweight"):GetFloat() + 1
	end

	if totalmass > gmaxweightshoot then
		
		if CurTime() > wlalertdelaytimer then
			local gunowner = gunent:CPPIGetOwner()
			print(gunowner)
			gunowner:PrintMessage(HUD_PRINTTALK, "Your contraption is too heavy to fire (" .. totalmass .. " kg). The server / Map weightlimit is: " .. gmaxweightshoot .. " kg.")
			wlalertdelaytimer = CurTime() + wlalertdelay
		end

		return false -- Tell acf to not do anything.
	else
		return true
	end
	
end

hook.Add("ACF_FireShell", "WeightLimitCheckScript", weightlimitcheck)


--[[
local weightableclass = {
	"prop_physics",
	"acf_ammo",
	"acf_engine",
	"acf_fueltank",
	"acf_gearbox",
	"acf_gun",
	"acf_explosive",
	"acf_fakecrate2",
	"acf_glatgm",
	"acf_missile",
	"acf_missile_to_rack",
	"acf_missileradar",
	"acf_opticalcomputer",
	"acf_rack"
}
local isokclass = false


-- Team weight limit controller(s)
function addtoweightlimit(ent)
	if !SERVER then return false end 
	if ent:IsConstraint() then return false end
	-- Timer delay so that team has a chance to be set.
	timer.Simple(0.01, function()

		if ent == nil then return end
		if ent:IsWeapon() then return false end
		
		if string.StartWith(ent:GetClass(), "phy") then return false end

		--print(ent)
		for i = 1, #weightableclass do
			if ent:GetClass() == weightableclass[i] then
				isokclass = true
			end
		end

		if isokclass != true then return false end
		if ent:CPPIGetOwner() == nil then return false end

		local phys = ent:GetPhysicsObject()
		local plyteam = ent:CPPIGetOwner():Team()
		local newweight = 0


		if IsValid(phys) then
			newweight = phys:GetMass()
			
		end

		local mykids = ent:GetChildren()
		PrintTable(mykids)


		if table.IsEmpty(mykids) != true then
			print("I have kids!")
			for i = 1, #mykids do
				print(mykids[i])
			end
		end

		if plyteam == gpoint_TeamAID then
			if teamAcurrweight + newweight > teamAweightlimit then
				
				if checkifacfweapon(ent) then
					ent:Remove()
					ent:CPPIGetOwner():PrintMessage(HUD_PRINTTALK, "Team weightlimit hit! (" .. teamAweightlimit .. " kg). Removing gun...")
				end
			else
				teamAcurrweight = teamAcurrweight + newweight
				
			end
			print("Team A weight now: " .. teamAcurrweight)
			
		elseif plyteam == gpoint_TeamBID then
			if teamBcurrweight + newweight > teamBweightlimit then
				
				if checkifacfweapon(ent) then
					ent:Remove()
					ent:CPPIGetOwner():PrintMessage(HUD_PRINTTALK, "Team weightlimit hit! (" .. teamBweightlimit .. " kg). Removing gun...")
				end
			else
				teamBcurrweight = teamBcurrweight + newweight
				
			end
			print("Team B weight now: " .. teamBcurrweight)
			
		end
		isokclass = false
	end)
end

hook.Add("OnEntityCreated", "add2weightlimit", addtoweightlimit)


function quicktest(ply, tablething)
	--PrintTable(tablething)
end
hook.Add("AdvDupe_FinishPasting", "quickpastetest", quicktest)

function takefromweightlimit(ent)
	if !SERVER then return false end 
	if ent:IsConstraint() then return false end
	-- Timer delay so that team has a chance to be set.

	if ent == nil then return end
	if ent:IsWeapon() then return false end
	
	if string.StartWith(ent:GetClass(), "phy") then return false end

	for i = 1, #weightableclass do
		if ent:GetClass() == weightableclass[i] then
			isokclass = true
		end
	end

	if isokclass != true then return false end
	if ent:CPPIGetOwner() == nil then return false end

	local phys = ent:GetPhysicsObject()
	local plyteam = ent:CPPIGetOwner():Team()
	local newweight = 0


	if IsValid(phys) then
		newweight = phys:GetMass()
	end

	if plyteam == gpoint_TeamAID then
		if teamAcurrweight - newweight < 0 then
			
			print("Something weird happened, team weight almost went < 0")
		else
			teamAcurrweight = teamAcurrweight - newweight
			
		end
		print("Team A weight now: " .. teamAcurrweight)
		
	elseif plyteam == gpoint_TeamBID then
		if teamBcurrweight - newweight < 0 then
			
			print("Something weird happened, team weight almost went < 0")
		else
			teamBcurrweight = teamBcurrweight - newweight
			
		end
		print("Team B weight now: " .. teamBcurrweight)
		
	end

	isokclass = false
end

hook.Add("EntityRemoved", "takefromweightlimit", takefromweightlimit)

-- convience function
function checkifacfweapon(ent)
	
	if ent:GetClass() == "acf_gun" then
		return true
		
		
	else
		return false
	end
	
end

]]